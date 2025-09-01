/*
 * SPDX-FileCopyrightText: 2023 Espressif Systems (Shanghai) CO LTD
 *
 * SPDX-License-Identifier: Unlicense OR CC0-1.0
 */

#include <string.h>
#include <stdint.h>
#include "sdkconfig.h"
#include "protocol_examples_common.h"
#include "example_common_private.h"

#include "esp_log.h"
#include "esp_netif.h"
#include "esp_netif_ppp.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#define CONFIG_EXAMPLE_CONNECT_PPP_DEVICE_USB 1

#include "tinyusb.h"
#include "tusb_cdc_acm.h"

static int s_itf;
static uint8_t buf[CONFIG_TINYUSB_CDC_RX_BUFSIZE];


static const char *TAG = "example_connect_ppp";
static int s_retry_num = 0;
static EventGroupHandle_t s_event_group = NULL;
static esp_netif_t *s_netif;
static const int GOT_IPV4 = BIT0;
static const int CONNECTION_FAILED = BIT1;
static const int GOT_IPV6 = BIT2;
#define CONNECT_BITS (GOT_IPV4|GOT_IPV6|CONNECTION_FAILED)

static esp_err_t transmit(void *h, void *buffer, size_t len)
{
    ESP_LOG_BUFFER_HEXDUMP(TAG, buffer, len, ESP_LOG_VERBOSE);

    tinyusb_cdcacm_write_queue(s_itf, buffer, len);
    tinyusb_cdcacm_write_flush(s_itf, 0);

    return ESP_OK;
}

static esp_netif_driver_ifconfig_t driver_cfg = {
        .handle = (void *)1,    // singleton driver, just to != NULL
        .transmit = transmit,
};
const esp_netif_driver_ifconfig_t *ppp_driver_cfg = &driver_cfg;

static void on_ip_event(void *arg, esp_event_base_t event_base,
                        int32_t event_id, void *event_data)
{

    if (event_id == IP_EVENT_PPP_GOT_IP) {
        ip_event_got_ip_t *event = (ip_event_got_ip_t *)event_data;
        if (!example_is_our_netif(EXAMPLE_NETIF_DESC_PPP, event->esp_netif)) {
            return;
        }
        esp_netif_t *netif = event->esp_netif;
        esp_netif_dns_info_t dns_info;
        ESP_LOGI(TAG, "Got IPv4 event: Interface \"%s\" address: " IPSTR, esp_netif_get_desc(event->esp_netif), IP2STR(&event->ip_info.ip));
        esp_netif_get_dns_info(netif, ESP_NETIF_DNS_MAIN, &dns_info);
        ESP_LOGI(TAG, "Main DNS server : " IPSTR, IP2STR(&dns_info.ip.u_addr.ip4));
        xEventGroupSetBits(s_event_group, GOT_IPV4);
    } else if (event_id == IP_EVENT_GOT_IP6) {
        ip_event_got_ip6_t *event = (ip_event_got_ip6_t *)event_data;
        if (!example_is_our_netif(EXAMPLE_NETIF_DESC_PPP, event->esp_netif)) {
            return;
        }
        esp_ip6_addr_type_t ipv6_type = esp_netif_ip6_get_addr_type(&event->ip6_info.ip);
        ESP_LOGI(TAG, "Got IPv6 event: Interface \"%s\" address: " IPV6STR ", type: %s", esp_netif_get_desc(event->esp_netif),
                 IPV62STR(event->ip6_info.ip), example_ipv6_addr_types_to_str[ipv6_type]);
        if (ipv6_type == EXAMPLE_CONNECT_PREFERRED_IPV6_TYPE) {
            xEventGroupSetBits(s_event_group, GOT_IPV6);
        }
    } else if (event_id == IP_EVENT_PPP_LOST_IP) {
        ESP_LOGI(TAG, "Disconnect from PPP Server");
        s_retry_num++;
        if (s_retry_num > CONFIG_EXAMPLE_PPP_CONN_MAX_RETRY) {
            ESP_LOGE(TAG, "PPP Connection failed %d times, stop reconnecting.", s_retry_num);
            xEventGroupSetBits(s_event_group, CONNECTION_FAILED);
        } else {
            ESP_LOGI(TAG, "PPP Connection failed %d times, try to reconnect.", s_retry_num);
            esp_netif_action_start(s_netif, 0, 0, 0);
            esp_netif_action_connected(s_netif, 0, 0, 0);
        }

    }
}

static void cdc_rx_callback(int itf, cdcacm_event_t *event)
{
    size_t rx_size = 0;
    if (itf != s_itf) {
        // Not our channel
        return;
    }
    esp_err_t ret = tinyusb_cdcacm_read(itf, buf, CONFIG_TINYUSB_CDC_RX_BUFSIZE, &rx_size);
    if (ret == ESP_OK) {
        ESP_LOG_BUFFER_HEXDUMP(TAG, buf, rx_size, ESP_LOG_VERBOSE);
        // pass the received data to the network interface
        esp_netif_receive(s_netif, buf, rx_size, NULL);
    } else {
        ESP_LOGE(TAG, "Read error");
    }
}

static void line_state_changed(int itf, cdcacm_event_t *event)
{
    s_itf = itf; // use this channel for the netif communication
    ESP_LOGI(TAG, "Line state changed on channel %d", itf);
}

esp_err_t example_ppp_connect(void)
{
    ESP_LOGI(TAG, "Start example_connect.");

    ESP_LOGI(TAG, "USB initialization");
    const tinyusb_config_t tusb_cfg = {
            .device_descriptor = NULL,
            .string_descriptor = NULL,
            .external_phy = false,
            .configuration_descriptor = NULL,
    };

    ESP_ERROR_CHECK(tinyusb_driver_install(&tusb_cfg));

    tinyusb_config_cdcacm_t acm_cfg = {
            .usb_dev = TINYUSB_USBDEV_0,
            .cdc_port = TINYUSB_CDC_ACM_0,
            .callback_rx = &cdc_rx_callback,
            .callback_rx_wanted_char = NULL,
            .callback_line_state_changed = NULL,
            .callback_line_coding_changed = NULL
    };

    ESP_ERROR_CHECK(tusb_cdc_acm_init(&acm_cfg));
    /* the second way to register a callback */
    ESP_ERROR_CHECK(tinyusb_cdcacm_register_callback(
            TINYUSB_CDC_ACM_0,
            CDC_EVENT_LINE_STATE_CHANGED,
            &line_state_changed));

    s_event_group = xEventGroupCreate();

    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, ESP_EVENT_ANY_ID, on_ip_event, NULL));

    esp_netif_inherent_config_t base_netif_cfg = ESP_NETIF_INHERENT_DEFAULT_PPP();
    base_netif_cfg.if_desc = EXAMPLE_NETIF_DESC_PPP;
    esp_netif_config_t netif_ppp_config = { .base = &base_netif_cfg,
            .driver = ppp_driver_cfg,
            .stack = ESP_NETIF_NETSTACK_DEFAULT_PPP
    };

    s_netif = esp_netif_new(&netif_ppp_config);
    assert(s_netif);
    esp_netif_action_start(s_netif, 0, 0, 0);
    esp_netif_action_connected(s_netif, 0, 0, 0);

    ESP_LOGI(TAG, "Waiting for IP address");
    EventBits_t bits = xEventGroupWaitBits(s_event_group, CONNECT_BITS, pdFALSE, pdFALSE, portMAX_DELAY);
    if (bits & CONNECTION_FAILED) {
        ESP_LOGE(TAG, "Connection failed!");
        return ESP_FAIL;
    }
    ESP_LOGI(TAG, "Connected!");

    return ESP_OK;
}

void example_ppp_shutdown(void)
{
    ESP_ERROR_CHECK(esp_event_handler_unregister(IP_EVENT, ESP_EVENT_ANY_ID, on_ip_event));

    esp_netif_action_disconnected(s_netif, 0, 0, 0);

    vEventGroupDelete(s_event_group);
    esp_netif_action_stop(s_netif, 0, 0, 0);
    esp_netif_destroy(s_netif);
    s_netif = NULL;
    s_event_group = NULL;
}

