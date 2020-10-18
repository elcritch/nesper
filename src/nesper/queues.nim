import consts

# FreeRTOS/ESP-IDF Queue API's for a concise overview:
# proc xQueueCreate(uxQueueLength, uxItemSize: UBaseType_t): QueueHandle_t
# proc xQueueCreateStatic(uxQueueLength: UBaseType_t, uxItemSize: UBaseType_t, pucQueueStorage: pointer, pxQueueBuffer: ptr StaticQueue_t): QueueHandle_t
# proc xQueueSendToFront(xQueue: QueueHandle_t, pvItemToQueue: pointer, xTicksToWait: TickType_t): BaseType_t
# proc xQueueSendToBack(xQueue: QueueHandle_t, pvItemToQueue: pointer, xTicksToWait: TickType_t): BaseType_t
# proc xQueueSend(xQueue: QueueHandle_t, pvItemToQueue: pointer, xTicksToWait: TickType_t): BaseType_t
# proc xQueueOverwrite(xQueue: QueueHandle_t, pvItemToQueue: pointer): BaseType_t
# proc xQueueGenericSend(xQueue: QueueHandle_t; pvItemToQueue: pointer; xTicksToWait: TickType_t; xCopyPosition: BaseType_t): BaseType_t 
# proc xQueuePeek(xQueue: QueueHandle_t, pvBuffer: pointer, xTicksToWait: TickType_t): BaseType_t
# proc xQueuePeekFromISR(xQueue: QueueHandle_t; pvBuffer: pointer): BaseType_t
# proc xQueueReceive(xQueue: QueueHandle_t, pvBuffer: pointer, xTicksToWait: TickType_t): BaseType_t
# proc xQueueGenericReceive(xQueue: QueueHandle_t; pvBuffer: pointer; xTicksToWait: TickType_t; xJustPeek: BaseType_t): BaseType_t 

# Utils
# proc uxQueueMessagesWaiting*(xQueue: QueueHandle_t): UBaseType_t
# proc uxQueueSpacesAvailable*(xQueue: QueueHandle_t): UBaseType_t

# proc vQueueDelete*(xQueue: QueueHandle_t)
# proc xQueueReset*(xQueue: QueueHandle_t): BaseType_t

# proc vQueueAddToRegistry*(xQueue: QueueHandle_t; pcName: cstring)
# proc vQueueUnregisterQueue*(xQueue: QueueHandle_t)
# proc pcQueueGetName*(xQueue: QueueHandle_t): cstring

# Note: not listing various *ISR functions, see esp/queue.nim for thos
# Note: not listing various *Alt functions, see esp/queue.nim for thos
# Note: not listing various *C functions, see esp/queue.nim for thos

## xQueue Set Functions
# proc xQueueCreateSet*(uxEventQueueLength: UBaseType_t): QueueSetHandle_t
# proc xQueueAddToSet*(xQueueOrSemaphore: QueueSetMemberHandle_t; xQueueSet: QueueSetHandle_t): BaseType_t
# proc xQueueRemoveFromSet*(xQueueOrSemaphore: QueueSetMemberHandle_t; xQueueSet: QueueSetHandle_t): BaseType_t
# proc xQueueSelectFromSet*(xQueueSet: QueueSetHandle_t; xTicksToWait: TickType_t): QueueSetMemberHandle_t
# proc xQueueSelectFromSetFromISR*(xQueueSet: QueueSetHandle_t): QueueSetMemberHandle_t

{.emit: """/*INCLUDESECTION*/
#include "freertos/FreeRTOS.h"
#include "freertos/queue.h"
""".}

import esp/queue
export queue

type
  XQueue*[N] = pointer

template xQueueCreate*(uxQueueLength, uxItemSize: int): untyped =
  xQueueCreate(UBaseType_t(uxQueueLength), UBaseType_t(uxItemSize))

template createXQueue[N](depth: int, itemSize: N): QueueHandle_t =
  let q: QueueHandle_t = xQueueCreate(20,sizeof(uint32))
  cast[XQueue[N]](q)

