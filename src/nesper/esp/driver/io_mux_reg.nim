# Entry-point for the board-specific io_mux_reg.h ports
const esp32c3=true
when defined(esp32s3):
  include ./esp32s3/io_mux_reg
elif defined(esp32c3):
  include ./esp32c3/io_mux_reg
else:
  include ./esp32/io_mux_reg