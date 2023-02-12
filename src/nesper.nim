# This is just an example to get you started. A typical library package
# exports the main API in this file. Note that you cannot rename this file
# but you can remove it if you wish.

import strutils

import nesper/consts
import nesper/general
import nesper/esp/esp_log

export consts
export general
export esp_log

#{.emit: """/*TYPESECTION*/
##include <freertos/FreeRTOS.h>
#""".}

# type
#   Submodule* = object
#     name*: string

# proc initSubmodule*(): Submodule =
#   ## Initialises a new ``Submodule`` object.
#   Submodule(name: "Anonymous")
