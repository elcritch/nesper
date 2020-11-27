
all:
	nim prepare main/wifi_example_main.nim -d:release -D:ESP_IDF_V4_0 && idf.py reconfigure 

build:
	idf.py build

clean:
	rm -Rf main/nimcache/

fullclean: clean
	idf.py fullclean

