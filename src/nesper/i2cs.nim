import ./consts

when ESP_IDF_VERSION < ESP_IDF_VERSION_VAL(5, 0, 0):
  import legacy/i2cs as i2cs_legacy
  export i2cs_legacy
else:

  import esp/driver_v5/i2c_master
