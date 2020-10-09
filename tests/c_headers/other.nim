type
  system_event_handler_t* = proc (event: ptr system_event_t): esp_err_t {.cdecl.}
