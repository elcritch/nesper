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

##
##  Include the generic headers required for the FreeRTOS port being used.
##


##
##  If stdint.h cannot be located then:
##    + If using GCC ensure the -nostdint options is *not* being used.
##    + Ensure the project's include path includes the directory in which your
##      compiler stores stdint.h.
##    + Set any compiler options necessary for it to support C99, as technically
##      stdint.h is only mandatory with C99 (FreeRTOS does not require C99 in any
##      other way).
##    + The FreeRTOS download includes a simple stdint.h definition that can be
##      used in cases where none is provided by the compiler.  The files only
##      contains the typedefs required to build FreeRTOS.  Read the instructions
##      in FreeRTOS/source/stdint.readme for more information.
##

##  Application specific configuration options.


##  Basic FreeRTOS definitions.

import consts


# type
  # TickType_t* = uint32

##  Definitions specific to the port being used.


##
##  Check all the required application specific macros have been defined.
##  These macros are application specific and (as downloaded) are defined
##  within FreeRTOSConfig.h.
##

proc configASSERT*(x: cint): void {.importc: "configASSERT", header: "<freertos/FreeRTOS.h>".}

proc portSET_INTERRUPT_MASK_FROM_ISR*() {.importc: "portSET_INTERRUPT_MASK_FROM_ISR", header: "<freertos/FreeRTOS.h>".}

proc portCLEAR_INTERRUPT_MASK_FROM_ISR*(uxSavedStatusValue: cint)  {.importc: "portCLEAR_INTERRUPT_MASK_FROM_ISR", header: "<freertos/FreeRTOS.h>".}

proc vQueueAddToRegistry*(xQueue, pcName: cint): void  {.importc: "vQueueAddToRegistry", header: "<freertos/FreeRTOS.h>".}

proc vQueueUnregisterQueue*(xQueue: cint): void {.importc: "vQueueUnregisterQueue", header: "<freertos/FreeRTOS.h>".} 

##  Remove any unused trace macros.


type
  xSTATIC_LIST_ITEM* {.importcpp: "xSTATIC_LIST_ITEM", header: "freertos/FreeRTOS.h", bycopy.} = object
    xDummy1* {.importc: "xDummy1".}: TickType_t
    pvDummy2* {.importc: "pvDummy2".}: array[4, pointer]

  StaticListItem_t* = xSTATIC_LIST_ITEM

##  See the comments above the struct xSTATIC_LIST_ITEM definition.

type
  xSTATIC_MINI_LIST_ITEM* {.importcpp: "xSTATIC_MINI_LIST_ITEM",
                           header: "freertos/FreeRTOS.h", bycopy.} = object
    xDummy1* {.importc: "xDummy1".}: TickType_t
    pvDummy2* {.importc: "pvDummy2".}: array[2, pointer]

  StaticMiniListItem_t* = xSTATIC_MINI_LIST_ITEM

##  See the comments above the struct xSTATIC_LIST_ITEM definition.

type
  StaticList_t* {.importcpp: "StaticList_t", header: "freertos/FreeRTOS.h", bycopy.} = object
    uxDummy1* {.importc: "uxDummy1".}: UBaseType_t
    pvDummy2* {.importc: "pvDummy2".}: pointer
    xDummy3* {.importc: "xDummy3".}: StaticMiniListItem_t


##
##  In line with software engineering best practice, especially when supplying a
##  library that is likely to change in future versions, FreeRTOS implements a
##  strict data hiding policy.  This means the Task structure used internally by
##  FreeRTOS is not accessible to application code.  However, if the application
##  writer wants to statically allocate the memory required to create a task then
##  the size of the task object needs to be know.  The StaticTask_t structure
##  below is provided for this purpose.  Its sizes and alignment requirements are
##  guaranteed to match those of the genuine structure, no matter which
##  architecture is being used, and no matter how the values in FreeRTOSConfig.h
##  are set.  Its contents are somewhat obfuscated in the hope users will
##  recognise that it would be unwise to make direct use of the structure members.
##

type
  # `_reent`* {.importcpp: "_reent", header: "freertos/FreeRTOS.h", bycopy.} = object

  StaticTask_t* {.importcpp: "StaticTask_t", header: "freertos/FreeRTOS.h", bycopy.} = object
    # pxDummy1* {.importc: "pxDummy1".}: pointer
    # # xDummy2* {.importcpp: "xDummy2", header: "freertos/FreeRTOS.h".}: xMPU_SETTINGS
    # xDummy3* {.importc: "xDummy3".}: array[2, StaticListItem_t]
    # uxDummy5* {.importc: "uxDummy5".}: UBaseType_t
    # pxDummy6* {.importc: "pxDummy6".}: pointer
    # # ucDummy7* {.importc: "ucDummy7".}: array[configMAX_TASK_NAME_LEN, uint8]
    # uxDummyCoreId* {.importc: "uxDummyCoreId".}: UBaseType_t
    # pxDummy8* {.importcpp: "pxDummy8", header: "freertos/FreeRTOS.h".}: pointer
    # uxDummy9* {.importcpp: "uxDummy9", header: "freertos/FreeRTOS.h".}: UBaseType_t
    # OldInterruptState* {.importcpp: "OldInterruptState", header: "freertos/FreeRTOS.h".}: uint32
    # uxDummy10* {.importcpp: "uxDummy10", header: "freertos/FreeRTOS.h".}: array[2,
    #       UBaseType_t]
    # uxDummy12* {.importcpp: "uxDummy12", header: "freertos/FreeRTOS.h".}: array[2,
    #       UBaseType_t]
    # pxDummy14* {.importcpp: "pxDummy14", header: "freertos/FreeRTOS.h".}: pointer
    # pvDummy15* {.importcpp: "pvDummy15", header: "freertos/FreeRTOS.h".}: array[
    #       configNUM_THREAD_LOCAL_STORAGE_POINTERS, pointer]
    # pvDummyLocalStorageCallBack* {.
    #         importcpp: "pvDummyLocalStorageCallBack", header: "freertos/FreeRTOS.h".}: array[
    #         configNUM_THREAD_LOCAL_STORAGE_POINTERS, pointer]
    # ulDummy16* {.importcpp: "ulDummy16", header: "freertos/FreeRTOS.h".}: uint32
    # xDummy17* {.importcpp: "xDummy17", header: "freertos/FreeRTOS.h".}: st_reent
    # ulDummy18* {.importcpp: "ulDummy18", header: "freertos/FreeRTOS.h".}: uint32
    # ucDummy19* {.importcpp: "ucDummy19", header: "freertos/FreeRTOS.h".}: uint32
    # uxDummy20* {.importcpp: "uxDummy20", header: "freertos/FreeRTOS.h".}: uint8


##
##  In line with software engineering best practice, especially when supplying a
##  library that is likely to change in future versions, FreeRTOS implements a
##  strict data hiding policy.  This means the Queue structure used internally by
##  FreeRTOS is not accessible to application code.  However, if the application
##  writer wants to statically allocate the memory required to create a queue
##  then the size of the queue object needs to be know.  The StaticQueue_t
##  structure below is provided for this purpose.  Its sizes and alignment
##  requirements are guaranteed to match those of the genuine structure, no
##  matter which architecture is being used, and no matter how the values in
##  FreeRTOSConfig.h are set.  Its contents are somewhat obfuscated in the hope
##  users will recognise that it would be unwise to make direct use of the
##  structure members.
##

type
  # INNER_C_UNION_FreeRTOS_969* {.importcpp: "no_name", header: "freertos/FreeRTOS.h", bycopy.} = object {.
  #     union.}
  #   pvDummy2* {.importc: "pvDummy2".}: pointer
  #   uxDummy2* {.importc: "uxDummy2".}: UBaseType_t

  StaticQueue_t* {.importcpp: "StaticQueue_t", header: "freertos/FreeRTOS.h", bycopy.} = object
    # pvDummy1* {.importc: "pvDummy1".}: array[3, pointer]
    # u* {.importc: "u".}: INNER_C_UNION_FreeRTOS_969
    # xDummy3* {.importc: "xDummy3".}: array[2, StaticList_t]
    # uxDummy4* {.importc: "uxDummy4".}: array[3, UBaseType_t]
    # ucDummy6* {.importcpp: "ucDummy6", header: "freertos/FreeRTOS.h".}: uint8
    # pvDummy7* {.importcpp: "pvDummy7", header: "freertos/FreeRTOS.h".}: pointer
    # uxDummy8* {.importcpp: "uxDummy8", header: "freertos/FreeRTOS.h".}: UBaseType_t
    # ucDummy9* {.importcpp: "ucDummy9", header: "freertos/FreeRTOS.h".}: uint8
    # muxDummy* {.importc: "muxDummy".}: portMUX_TYPE ## Mutex required due to SMP

  StaticSemaphore_t* = StaticQueue_t

##
##  In line with software engineering best practice, especially when supplying a
##  library that is likely to change in future versions, FreeRTOS implements a
##  strict data hiding policy.  This means the event group structure used
##  internally by FreeRTOS is not accessible to application code.  However, if
##  the application writer wants to statically allocate the memory required to
##  create an event group then the size of the event group object needs to be
##  know.  The StaticEventGroup_t structure below is provided for this purpose.
##  Its sizes and alignment requirements are guaranteed to match those of the
##  genuine structure, no matter which architecture is being used, and no matter
##  how the values in FreeRTOSConfig.h are set.  Its contents are somewhat
##  obfuscated in the hope users will recognise that it would be unwise to make
##  direct use of the structure members.
##

type
  StaticEventGroup_t* {.importcpp: "StaticEventGroup_t", header: "freertos/FreeRTOS.h", bycopy.} = object
    # xDummy1* {.importc: "xDummy1".}: TickType_t
    # xDummy2* {.importc: "xDummy2".}: StaticList_t
    # uxDummy3* {.importcpp: "uxDummy3", header: "freertos/FreeRTOS.h".}: UBaseType_t
    # ucDummy4* {.importcpp: "ucDummy4", header: "freertos/FreeRTOS.h".}: uint8
    # muxDummy* {.importc: "muxDummy".}: portMUX_TYPE ## Mutex required due to SMP


##
##  In line with software engineering best practice, especially when supplying a
##  library that is likely to change in future versions, FreeRTOS implements a
##  strict data hiding policy.  This means the software timer structure used
##  internally by FreeRTOS is not accessible to application code.  However, if
##  the application writer wants to statically allocate the memory required to
##  create a software timer then the size of the queue object needs to be know.
##  The StaticTimer_t structure below is provided for this purpose.  Its sizes
##  and alignment requirements are guaranteed to match those of the genuine
##  structure, no matter which architecture is being used, and no matter how the
##  values in FreeRTOSConfig.h are set.  Its contents are somewhat obfuscated in
##  the hope users will recognise that it would be unwise to make direct use of
##  the structure members.
##

type
  StaticTimer_t* {.importcpp: "StaticTimer_t", header: "freertos/FreeRTOS.h", bycopy.} = object
    # pvDummy1* {.importc: "pvDummy1".}: pointer
    # xDummy2* {.importc: "xDummy2".}: StaticListItem_t
    # xDummy3* {.importc: "xDummy3".}: TickType_t
    # uxDummy4* {.importc: "uxDummy4".}: UBaseType_t
    # pvDummy5* {.importc: "pvDummy5".}: array[2, pointer]
    # uxDummy6* {.importcpp: "uxDummy6", header: "freertos/FreeRTOS.h".}: UBaseType_t
    # ucDummy7* {.importcpp: "ucDummy7", header: "freertos/FreeRTOS.h".}: uint8

