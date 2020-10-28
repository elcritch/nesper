
import nesper
import nesper/general
import nesper/timers


const TAG = "main"

logi(TAG, "Initializing device...")
logd(TAG, "Initializing device: %d", 23)
    
echo "ESP_OK: " & $ESP_OK
echo ""

var portTICK_PERIOD_MS* {.importc: "portTICK_PERIOD_MS", header: "<freertos/FreeRTOS.h>".}: cint

discard delayMillis(100)
delay(Millis(100))
discard delayMicros(100)
delay(Micros(100))
esp_restart()

# vTaskDelete*( handle: any )

echo "ESP_ERR_FLASH_BASE: " & $esp_err_to_name(ESP_ERR_FLASH_BASE)

ESP_ERROR_CHECK(ESP_OK)
ESP_ERROR_CHECK(ESP_ERR_INVALID_ARG)

ESP_ERROR_CHECK_WITHOUT_ABORT(ESP_OK)
ESP_ERROR_CHECK_WITHOUT_ABORT(ESP_ERR_INVALID_ARG)
