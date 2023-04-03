# This is just an example to get you started. A typical library package
# exports the main API in this file. Note that you cannot rename this file
# but you can remove it if you wish.

import nesper/consts
import nesper/general
import nesper/esp/esp_log
import nesper/gpios
import nesper/nimy/button

export consts
export general
export esp_log

# nimmy wrapper
import nesper/nimy/errors
import nesper/nimy/gpio

export errors
export gpio

#{.emit: """/*TYPESECTION*/
##include <freertos/FreeRTOS.h>
#""".}

# type
#   Submodule* = object
#     name*: string

# proc initSubmodule*(): Submodule =
#   ## Initialises a new ``Submodule`` object.
#   Submodule(name: "Anonymous")
