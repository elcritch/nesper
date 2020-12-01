
ESP_IDF_VERSION ?= ESP_IDF_V4_0 
# ESP_IDF_VERSION ?= ESP_IDF_V4_1

all: clean build

esp_v40:
	nim prepare main/wifi_example_main.nim -d:release -d:ESP_IDF_V4_0 && idf.py reconfigure 

esp_v41:
	nim prepare main/wifi_example_main.nim -d:release -d:ESP_IDF_V4_1 && idf.py reconfigure 

nim:
	nim prepare main/wifi_example_main.nim -d:release -d:$(ESP_IDF_VERSION) && idf.py reconfigure 

build: clean nim
	idf.py build

clean:
	rm -Rf main/nimcache/

fullclean: clean
	rm -Rf build/
	# idf.py fullclean

