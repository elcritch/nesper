##
##     FreeRTOS V8.2.0 - Copyright (C) 2015 Real Time Engineers Ltd.
##     All rights reserved
##
##     VISIT http://www.FreeRTOS.org TO ENSURE YOU ARE USING THE LATEST VERSION.
##
##     This file is part of the FreeRTOS distribution.
##
##     FreeRTOS is free software; you can redistribute it and/or modify it under
##     the terms of the GNU General Public License (version 2) as published by the
##     Free Software Foundation >>!AND MODIFIED BY!<< the FreeRTOS exception.
##
## **************************************************************************
##     >>!   NOTE: The modification to the GPL is included to allow you to     !<<
##     >>!   distribute a combined work that includes FreeRTOS without being   !<<
##     >>!   obliged to provide the source code for proprietary components     !<<
##     >>!   outside of the FreeRTOS kernel.                                   !<<
## **************************************************************************
##
##     FreeRTOS is distributed in the hope that it will be useful, but WITHOUT ANY
##     WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
##     FOR A PARTICULAR PURPOSE.  Full license text is available on the following
##     link: http://www.freertos.org/a00114.html
##
## **************************************************************************
##                                                                        *
##     FreeRTOS provides completely free yet professionally developed,    *
##     robust, strictly quality controlled, supported, and cross          *
##     platform software that is more than just the market leader, it     *
##     is the industry's de facto standard.                               *
##                                                                        *
##     Help yourself get started quickly while simultaneously helping     *
##     to support the FreeRTOS project by purchasing a FreeRTOS           *
##     tutorial book, reference manual, or both:                          *
##     http://www.FreeRTOS.org/Documentation                              *
##                                                                        *
## **************************************************************************
##
##     http://www.FreeRTOS.org/FAQHelp.html - Having a problem?  Start by reading
## 	the FAQ page "My application does not run, what could be wrong?".  Have you
## 	defined configASSERT()?
##
## 	http://www.FreeRTOS.org/support - In return for receiving this top quality
## 	embedded software for free we request you assist our global community by
## 	participating in the support forum.
##
## 	http://www.FreeRTOS.org/training - Investing in training allows your team to
## 	be as productive as possible as early as possible.  Now you can receive
## 	FreeRTOS training directly from Richard Barry, CEO of Real Time Engineers
## 	Ltd, and the world's leading authority on the world's leading RTOS.
##
##     http://www.FreeRTOS.org/plus - A selection of FreeRTOS ecosystem products,
##     including FreeRTOS+Trace - an indispensable productivity tool, a DOS
##     compatible FAT file system, and our tiny thread aware UDP/IP stack.
##
##     http://www.FreeRTOS.org/labs - Where new FreeRTOS products go to incubate.
##     Come and try FreeRTOS+TCP, our new open source TCP/IP stack for FreeRTOS.
##
##     http://www.OpenRTOS.com - Real Time Engineers ltd. license FreeRTOS to High
##     Integrity Systems ltd. to sell under the OpenRTOS brand.  Low cost OpenRTOS
##     licenses offer ticketed support, indemnification and commercial middleware.
##
##     http://www.SafeRTOS.com - High Integrity Systems also provide a safety
##     engineered and independently SIL3 certified version for use in safety and
##     mission critical applications that require provable dependability.
##
##     1 tab == 4 spaces!
##

##  "mux" data structure (spinlock)

type
  portMUX_TYPE* {.importc: "portMUX_TYPE", header: "projdefs.h", bycopy.} = object
    owner* {.importc: "owner".}: uint32_t ##  owner field values:
                                      ##  0                - Uninitialized (invalid)
                                      ##  portMUX_FREE_VAL - Mux is free, can be locked by either CPU
                                      ##  CORE_ID_PRO / CORE_ID_APP - Mux is locked to the particular core
                                      ##
                                      ##  Any value other than portMUX_FREE_VAL, CORE_ID_PRO, CORE_ID_APP indicates corruption
                                      ##
    ##  count field:
    ##  If mux is unlocked, count should be zero.
    ##  If mux is locked, count is non-zero & represents the number of recursive locks on the mux.
    ##
    count* {.importc: "count".}: uint32_t ##  #ifdef CONFIG_FREERTOS_PORTMUX_DEBUG
                                      ##  const char *lastLockedFn;
                                      ##  int lastLockedLine;
                                      ##  #endif


##
##  Defines the prototype to which task functions must conform.  Defined in this
##  file to ensure the type is known before portable.h is included.
##

type
  TaskFunction_t* = proc (a1: pointer) {.cdecl.}

##  Converts a time in milliseconds to a time in ticks.

template pdMS_TO_TICKS*(xTimeInMs: untyped): untyped =
  (((TickType_t)(xTimeInMs) * configTICK_RATE_HZ) div cast[TickType_t](1000))

const
  pdFALSE* = (cast[BaseType_t](0))
  pdTRUE* = (cast[BaseType_t](1))
  pdPASS* = (pdTRUE)
  pdFAIL* = (pdFALSE)
  errQUEUE_EMPTY* = (cast[BaseType_t](0))
  errQUEUE_FULL* = (cast[BaseType_t](0))

##  Error definitions.

const
  errCOULD_NOT_ALLOCATE_REQUIRED_MEMORY* = (-1)
  errQUEUE_BLOCKED* = (-4)
  errQUEUE_YIELD* = (-5)

##  Macros used for basic data corruption checks.

when not defined(configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES):
  const
    configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES* = 0
when (configUSE_16_BIT_TICKS == 1):
  const
    pdINTEGRITY_CHECK_VALUE* = 0x00005A5A
else:
  const
    pdINTEGRITY_CHECK_VALUE* = 0x5A5A5A5A