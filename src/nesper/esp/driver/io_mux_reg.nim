# Entry-point for the board-specific io_mux_reg.h ports

when not defined(esp32s3):
  include ./esp32/io_mux_reg
else:
  include ./esp32s3/io_mux_reg