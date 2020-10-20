
#pragma once

#include <stdio.h>
#include <stddef.h>

#define SOC_SPI_PERIPH_NUM 3
// #define esp_err_to_name(id) ("ERROR" ## id)

typedef uint32_t TickType_t;
typedef int esp_err_t;

typedef void * spi_host_device_t;

typedef void * QueueHandle_t;

typedef void * spi_hal_timing_conf_t ;
typedef void * spi_host_t;
typedef void * SemaphoreHandle_t;



