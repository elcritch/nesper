all: clean build


esp_v40:
	nim prepare main/wifi_example_main.nim -d:release -D:ESP_IDF_V4_0 && idf.py reconfigure 

esp_v41:
	nim prepare main/wifi_example_main.nim -d:release -D:ESP_IDF_V4_1 && idf.py reconfigure 

build: clean esp_v40
	idf.py build

clean:
	rm -Rf main/nimcache/

fullclean: clean
	idf.py fullclean

