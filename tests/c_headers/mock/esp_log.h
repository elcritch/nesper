
#include <stdio.h>

#define ESP_LOGI(fmt, args...) { printf("INFO: "); printf(fmt, args); printf("\n");}
// #define ESP_LOGD(fmt, args...) { printf("DEBUG: "); printf(fmt, args); printf("\n");}

#define ESP_LOGD(fmt, args...) {}

// #define esp_err_to_name(id) ("ERROR" ## id)
