/*
 * Dual-CDC PPPoS over USB example
 * - CDC ACM 0: PPP data channel (PPPoS)
 * - CDC ACM 1: Console/log output via TinyUSB console
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

#include "tinyusb.h"
#include "tusb_cdc_acm.h"
#include "tusb_console.h"

static const char *TAG = "pppos_dualcdc";

/* PPP state */
static esp_netif_t *s_netif;
static EventGroupHandle_t s_event_group;
static const int GOT_IPV4 = BIT0;
static const int CONNECTION_FAILED = BIT1;
static const int GOT_IPV6 = BIT2;
#define CONNECT_BITS (GOT_IPV4|GOT_IPV6|CONNECTION_FAILED)

/* USB-CDC state */
static int s_ppp_itf = TINYUSB_CDC_ACM_0;   /* PPP on CDC0 */
static int s_log_itf = TINYUSB_CDC_ACM_1;   /* Console on CDC1 */
static uint8_t s_rx_buf[CONFIG_TINYUSB_CDC_RX_BUFSIZE];

/* PPP transmit: push bytes onto PPP CDC interface */
static esp_err_t transmit(void *h, void *buffer, size_t len)
{
    (void)h;
    ESP_LOG_BUFFER_HEXDUMP(TAG, buffer, len, ESP_LOG_VERBOSE);
    tinyusb_cdcacm_write_queue(s_ppp_itf, buffer, len);
    tinyusb_cdcacm_write_flush(s_ppp_itf, 0);
    return ESP_OK;
}

static esp_netif_driver_ifconfig_t s_driver_cfg = {
    .handle = (void *)1, /* singleton driver, just != NULL */
    .transmit = transmit,
};

/* IP events */
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
        ESP_LOGI(TAG, "Got IPv4: %s " IPSTR, esp_netif_get_desc(netif), IP2STR(&event->ip_info.ip));
        esp_netif_get_dns_info(netif, ESP_NETIF_DNS_MAIN, &dns_info);
        ESP_LOGI(TAG, "DNS: " IPSTR, IP2STR(&dns_info.ip.u_addr.ip4));
        xEventGroupSetBits(s_event_group, GOT_IPV4);
    } else if (event_id == IP_EVENT_GOT_IP6) {
        ip_event_got_ip6_t *event = (ip_event_got_ip6_t *)event_data;
        if (!example_is_our_netif(EXAMPLE_NETIF_DESC_PPP, event->esp_netif)) {
            return;
        }
        esp_ip6_addr_type_t ipv6_type = esp_netif_ip6_get_addr_type(&event->ip6_info.ip);
        ESP_LOGI(TAG, "Got IPv6: %s " IPV6STR ", type: %d", esp_netif_get_desc(event->esp_netif),
                 IPV62STR(event->ip6_info.ip), ipv6_type);
        xEventGroupSetBits(s_event_group, GOT_IPV6);
    } else if (event_id == IP_EVENT_PPP_LOST_IP) {
        ESP_LOGI(TAG, "PPP disconnected");
        xEventGroupSetBits(s_event_group, CONNECTION_FAILED);
    }
}

/* CDC RX for PPP interface: push to esp_netif */
static void cdc_rx_callback(int itf, cdcacm_event_t *event)
{
    size_t rx_size = 0;
    if (itf != s_ppp_itf) {
        return; /* not our PPP channel */
    }
    if (tinyusb_cdcacm_read(itf, s_rx_buf, sizeof(s_rx_buf), &rx_size) == ESP_OK) {
        if (rx_size) {
            ESP_LOG_BUFFER_HEXDUMP(TAG, s_rx_buf, rx_size, ESP_LOG_VERBOSE);
            esp_netif_receive(s_netif, s_rx_buf, rx_size, NULL);
        }
    } else {
        ESP_LOGE(TAG, "CDC read error");
    }
}

/* Optionally track line state for PPP interface */
static void line_state_changed(int itf, cdcacm_event_t *event)
{
    ESP_LOGI(TAG, "Line state changed on itf %d", itf);
}

/* Public helpers to start/stop PPP over CDC0 and console on CDC1 */
esp_err_t example_ppp_connect_dualcdc(void)
{
    ESP_LOGI(TAG, "Starting dual-CDC PPPoS (PPP on CDC0, console on CDC1)");

    /* Install TinyUSB */
    const tinyusb_config_t tusb_cfg = {
        .device_descriptor = NULL,
        .string_descriptor = NULL,
        .external_phy = false,
#if (TUD_OPT_HIGH_SPEED)
        .fs_configuration_descriptor = NULL,
        .hs_configuration_descriptor = NULL,
        .qualifier_descriptor = NULL,
#else
        .configuration_descriptor = NULL,
#endif
    };
    ESP_ERROR_CHECK(tinyusb_driver_install(&tusb_cfg));

    /* Init CDC0 for PPP */
    tinyusb_config_cdcacm_t acm_ppp = {
        .usb_dev = TINYUSB_USBDEV_0,
        .cdc_port = TINYUSB_CDC_ACM_0,
        .callback_rx = &cdc_rx_callback,
        .callback_rx_wanted_char = NULL,
        .callback_line_state_changed = &line_state_changed,
        .callback_line_coding_changed = NULL,
    };
    ESP_ERROR_CHECK(tusb_cdc_acm_init(&acm_ppp));

    /* Init CDC1 for console/logs */
    tinyusb_config_cdcacm_t acm_log = {
        .usb_dev = TINYUSB_USBDEV_0,
        .cdc_port = TINYUSB_CDC_ACM_1,
    };
    ESP_ERROR_CHECK(tusb_cdc_acm_init(&acm_log));

    /* Route console/log output to CDC1 */
    ESP_ERROR_CHECK(esp_tusb_init_console(TINYUSB_CDC_ACM_1));

    /* Events and PPP netif */
    s_event_group = xEventGroupCreate();
    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, ESP_EVENT_ANY_ID, on_ip_event, NULL));

    esp_netif_inherent_config_t base_cfg = ESP_NETIF_INHERENT_DEFAULT_PPP();
    base_cfg.if_desc = EXAMPLE_NETIF_DESC_PPP;
    esp_netif_config_t netif_cfg = {
        .base = &base_cfg,
        .driver = &s_driver_cfg,
        .stack = ESP_NETIF_NETSTACK_DEFAULT_PPP,
    };

    s_netif = esp_netif_new(&netif_cfg);
    assert(s_netif);

    /* Bring interface up and signal connected */
    esp_netif_action_start(s_netif, 0, 0, 0);
    esp_netif_action_connected(s_netif, 0, 0, 0);

    ESP_LOGI(TAG, "Waiting for IP...");
    EventBits_t bits = xEventGroupWaitBits(s_event_group, CONNECT_BITS, pdFALSE, pdFALSE, portMAX_DELAY);
    if (bits & CONNECTION_FAILED) {
        ESP_LOGE(TAG, "PPP connection failed");
        return ESP_FAIL;
    }
    ESP_LOGI(TAG, "PPP connected");
    return ESP_OK;
}

void example_ppp_shutdown_dualcdc(void)
{
    ESP_LOGI(TAG, "Shutting down PPP and console");

    esp_event_handler_unregister(IP_EVENT, ESP_EVENT_ANY_ID, on_ip_event);
    if (s_netif) {
        esp_netif_action_disconnected(s_netif, 0, 0, 0);
        esp_netif_action_stop(s_netif, 0, 0, 0);
        esp_netif_destroy(s_netif);
        s_netif = NULL;
    }
    if (s_event_group) {
        vEventGroupDelete(s_event_group);
        s_event_group = NULL;
    }
    /* Restore console to UART if desired */
    esp_tusb_deinit_console(TINYUSB_CDC_ACM_1);
}

