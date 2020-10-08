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
##  This is the list implementation used by the scheduler.  While it is tailored
##  heavily for the schedulers needs, it is also available for use by
##  application code.
##
##  list_ts can only store pointers to list_item_ts.  Each ListItem_t contains a
##  numeric value (xItemValue).  Most of the time the lists are sorted in
##  descending item value order.
##
##  Lists are created already containing one list item.  The value of this
##  item is the maximum possible that can be stored, it is therefore always at
##  the end of the list and acts as a marker.  The list member pxHead always
##  points to this marker - even though it is at the tail of the list.  This
##  is because the tail contains a wrap back pointer to the true head of
##  the list.
##
##  In addition to it's value, each list item contains a pointer to the next
##  item in the list (pxNext), a pointer to the list it is in (pxContainer)
##  and a pointer to back to the object that contains it.  These later two
##  pointers are included for efficiency of list manipulation.  There is
##  effectively a two way link between the object containing the list item and
##  the list item itself.
##
##
##  \page ListIntroduction List Implementation
##  \ingroup FreeRTOSIntro
##

type
  xLIST_ITEM* {.importc: "xLIST_ITEM", header: "list.h", bycopy.} = object
    xItemValue* {.importc: "xItemValue".}: TickType_t ##  listFIRST_LIST_ITEM_INTEGRITY_CHECK_VALUE				/*< Set to a known value if configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES is set to 1. */
    ## < The value being listed.  In most cases this is used to sort the list in descending order.
    pxNext* {.importc: "pxNext".}: ptr xLIST_ITEM ## < Pointer to the next ListItem_t in the list.
    pxPrevious* {.importc: "pxPrevious".}: ptr xLIST_ITEM ## < Pointer to the previous ListItem_t in the list.
    pvOwner* {.importc: "pvOwner".}: pointer ## < Pointer to the object (normally a TCB) that contains the list item.  There is therefore a two way link between the object containing the list item and the list item itself.
    pvContainer* {.importc: "pvContainer".}: pointer ## < Pointer to the list in which this list item is placed (if any).
                                                 ##
                                                 ## listSECOND_LIST_ITEM_INTEGRITY_CHECK_VALUE				/*< Set to a known value if
                                                 ## configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES is set to 1. */

  ListItem_t* = xLIST_ITEM

##  For some reason lint wants this as two separate definitions.

type
  xMINI_LIST_ITEM* {.importc: "xMINI_LIST_ITEM", header: "list.h", bycopy.} = object
    xItemValue* {.importc: "xItemValue".}: TickType_t ##  listFIRST_LIST_ITEM_INTEGRITY_CHECK_VALUE				/*< Set to a known value if configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES is set to 1. */
    pxNext* {.importc: "pxNext".}: ptr xLIST_ITEM
    pxPrevious* {.importc: "pxPrevious".}: ptr xLIST_ITEM

  MiniListItem_t* = xMINI_LIST_ITEM

##  #if __GNUC_PREREQ(4, 6)
##  _Static_assert(sizeof(StaticMiniListItem_t) == sizeof(MiniListItem_t), "StaticMiniListItem_t != MiniListItem_t");
##  #endif
##
##  Definition of the type of queue used by the scheduler.
##

type
  List_t* {.importc: "List_t", header: "list.h", bycopy.} = object
    uxNumberOfItems* {.importc: "uxNumberOfItems".}: UBaseType_t ##  listFIRST_LIST_INTEGRITY_CHECK_VALUE				/*< Set to a known value if configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES is set to 1. */
    pxIndex* {.importc: "pxIndex".}: ptr ListItem_t ## < Used to walk through the list.  Points to the last item returned by a call to listGET_OWNER_OF_NEXT_ENTRY ().
    xListEnd* {.importc: "xListEnd".}: MiniListItem_t ## < List item that contains the maximum possible item value meaning it is always at the end of the list and is therefore used as a marker.
                                                  ##
                                                  ## listSECOND_LIST_INTEGRITY_CHECK_VALUE				/*< Set to a known value if
                                                  ## configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES is set to 1. */


##  #if __GNUC_PREREQ(4, 6)
##  _Static_assert(sizeof(StaticList_t) == sizeof(List_t), "StaticList_t != List_t");
##  #endif
##
##  Access macro to set the owner of a list item.  The owner of a list item
##  is the object (usually a TCB) that contains the list item.
##
##  \page listSET_LIST_ITEM_OWNER listSET_LIST_ITEM_OWNER
##  \ingroup LinkedList
##

proc listSET_LIST_ITEM_OWNER(pxListItem, pxOwner: untyped): cint {.importc: "listSET_LIST_ITEM_OWNER", header: "list.h".}

##
##  Access macro to get the owner of a list item.  The owner of a list item
##  is the object (usually a TCB) that contains the list item.
##
##  \page listSET_LIST_ITEM_OWNER listSET_LIST_ITEM_OWNER
##  \ingroup LinkedList
##

proc listGET_LIST_ITEM_OWNER(pxListItem: untyped): cint {.importc: "listGET_LIST_ITEM_OWNER", header: "list.h".}

##
##  Access macro to set the value of the list item.  In most cases the value is
##  used to sort the list in descending order.
##
##  \page listSET_LIST_ITEM_VALUE listSET_LIST_ITEM_VALUE
##  \ingroup LinkedList
##

proc listSET_LIST_ITEM_VALUE(pxListItem, xValue: untyped): cint {.importc: "listSET_LIST_ITEM_VALUE", header: "list.h".}

##
##  Access macro to retrieve the value of the list item.  The value can
##  represent anything - for example the priority of a task, or the time at
##  which a task should be unblocked.
##
##  \page listGET_LIST_ITEM_VALUE listGET_LIST_ITEM_VALUE
##  \ingroup LinkedList
##

proc listGET_LIST_ITEM_VALUE(pxListItem: untyped): cint {.importc: "listGET_LIST_ITEM_VALUE", header: "list.h".}

##
##  Access macro to retrieve the value of the list item at the head of a given
##  list.
##
##  \page listGET_LIST_ITEM_VALUE listGET_LIST_ITEM_VALUE
##  \ingroup LinkedList
##

proc listGET_ITEM_VALUE_OF_HEAD_ENTRY(pxList: untyped): cint {.importc: "listGET_ITEM_VALUE_OF_HEAD_ENTRY", header: "list.h".}

##
##  Return the list item at the head of the list.
##
##  \page listGET_HEAD_ENTRY listGET_HEAD_ENTRY
##  \ingroup LinkedList
##

proc listGET_HEAD_ENTRY(pxList: untyped): cint {.importc: "listGET_HEAD_ENTRY", header: "list.h".}

##
##  Return the list item at the head of the list.
##
##  \page listGET_NEXT listGET_NEXT
##  \ingroup LinkedList
##

proc listGET_NEXT(pxListItem: untyped): cint {.importc: "listGET_NEXT", header: "list.h".}

##
##  Return the list item that marks the end of the list
##
##  \page listGET_END_MARKER listGET_END_MARKER
##  \ingroup LinkedList
##

proc listGET_END_MARKER(pxList: untyped): cint {.importc: "listGET_END_MARKER", header: "list.h".}

##
##  Access macro to determine if a list contains any items.  The macro will
##  only have the value true if the list is empty.
##
##  \page listLIST_IS_EMPTY listLIST_IS_EMPTY
##  \ingroup LinkedList
##

proc listLIST_IS_EMPTY(pxList: untyped): cint {.importc: "listLIST_IS_EMPTY", header: "list.h".}

##
##  Access macro to return the number of items in the list.
##

proc listCURRENT_LIST_LENGTH(pxList: untyped): cint {.importc: "listCURRENT_LIST_LENGTH", header: "list.h".}

##
##  Access function to obtain the owner of the next entry in a list.
##
##  The list member pxIndex is used to walk through a list.  Calling
##  listGET_OWNER_OF_NEXT_ENTRY increments pxIndex to the next item in the list
##  and returns that entry's pxOwner parameter.  Using multiple calls to this
##  function it is therefore possible to move through every item contained in
##  a list.
##
##  The pxOwner parameter of a list item is a pointer to the object that owns
##  the list item.  In the scheduler this is normally a task control block.
##  The pxOwner parameter effectively creates a two way link between the list
##  item and its owner.
##
##  @param pxTCB pxTCB is set to the address of the owner of the next list item.
##  @param pxList The list from which the next item owner is to be returned.
##
##  \page listGET_OWNER_OF_NEXT_ENTRY listGET_OWNER_OF_NEXT_ENTRY
##  \ingroup LinkedList
##

template listGET_OWNER_OF_NEXT_ENTRY*(pxTCB, pxList: untyped): void =
  var pxConstList: ptr List_t
  ##  Increment the index to the next item and return the item, ensuring
  ##  we don't return the marker used at the end of the list.
  (pxConstList).pxIndex = (pxConstList).pxIndex.pxNext
  if cast[pointer]((pxConstList).pxIndex) ==
      cast[pointer](addr(((pxConstList).xListEnd))):
    (pxConstList).pxIndex = (pxConstList).pxIndex.pxNext
  (pxTCB) = (pxConstList).pxIndex.pvOwner

##
##  Access function to obtain the owner of the first entry in a list.  Lists
##  are normally sorted in ascending item value order.
##
##  This function returns the pxOwner member of the first item in the list.
##  The pxOwner parameter of a list item is a pointer to the object that owns
##  the list item.  In the scheduler this is normally a task control block.
##  The pxOwner parameter effectively creates a two way link between the list
##  item and its owner.
##
##  @param pxList The list from which the owner of the head item is to be
##  returned.
##
##  \page listGET_OWNER_OF_HEAD_ENTRY listGET_OWNER_OF_HEAD_ENTRY
##  \ingroup LinkedList
##

proc listGET_OWNER_OF_HEAD_ENTRY(pxList: untyped): cint {.importc: "listGET_OWNER_OF_HEAD_ENTRY", header: "list.h".}

##
##  Check to see if a list item is within a list.  The list item maintains a
##  "container" pointer that points to the list it is in.  All this macro does
##  is check to see if the container and the list match.
##
##  @param pxList The list we want to know if the list item is within.
##  @param pxListItem The list item we want to know if is in the list.
##  @return pdTRUE if the list item is in the list, otherwise pdFALSE.
##

proc listIS_CONTAINED_WITHIN(pxList, pxListItem: untyped): cint {.importc: "listIS_CONTAINED_WITHIN", header: "list.h".}

##
##  Return the list a list item is contained within (referenced from).
##
##  @param pxListItem The list item being queried.
##  @return A pointer to the List_t object that references the pxListItem
##

proc listLIST_ITEM_CONTAINER(pxListItem: untyped): cint {.importc: "listLIST_ITEM_CONTAINER", header: "list.h".}

##
##  This provides a crude means of knowing if a list has been initialised, as
##  pxList->xListEnd.xItemValue is set to portMAX_DELAY by the vListInitialise()
##  function.
##

proc listLIST_IS_INITIALISED(pxList: untyped): cint {.importc: "listLIST_IS_INITIALISED", header: "list.h".}

##
##  Must be called before a list is used!  This initialises all the members
##  of the list structure and inserts the xListEnd item into the list as a
##  marker to the back of the list.
##
##  @param pxList Pointer to the list being initialised.
##
##  \page vListInitialise vListInitialise
##  \ingroup LinkedList
##

proc vListInitialise*(pxList: ptr List_t) {.importc: "vListInitialise",
                                        header: "list.h".}
##
##  Must be called before a list item is used.  This sets the list container to
##  null so the item does not think that it is already contained in a list.
##
##  @param pxItem Pointer to the list item being initialised.
##
##  \page vListInitialiseItem vListInitialiseItem
##  \ingroup LinkedList
##

proc vListInitialiseItem*(pxItem: ptr ListItem_t) {.importc: "vListInitialiseItem",
    header: "list.h".}
##
##  Insert a list item into a list.  The item will be inserted into the list in
##  a position determined by its item value (descending item value order).
##
##  @param pxList The list into which the item is to be inserted.
##
##  @param pxNewListItem The item that is to be placed in the list.
##
##  \page vListInsert vListInsert
##  \ingroup LinkedList
##

proc vListInsert*(pxList: ptr List_t; pxNewListItem: ptr ListItem_t) {.
    importc: "vListInsert", header: "list.h".}
##
##  Insert a list item into a list.  The item will be inserted in a position
##  such that it will be the last item within the list returned by multiple
##  calls to listGET_OWNER_OF_NEXT_ENTRY.
##
##  The list member pvIndex is used to walk through a list.  Calling
##  listGET_OWNER_OF_NEXT_ENTRY increments pvIndex to the next item in the list.
##  Placing an item in a list using vListInsertEnd effectively places the item
##  in the list position pointed to by pvIndex.  This means that every other
##  item within the list will be returned by listGET_OWNER_OF_NEXT_ENTRY before
##  the pvIndex parameter again points to the item being inserted.
##
##  @param pxList The list into which the item is to be inserted.
##
##  @param pxNewListItem The list item to be inserted into the list.
##
##  \page vListInsertEnd vListInsertEnd
##  \ingroup LinkedList
##

proc vListInsertEnd*(pxList: ptr List_t; pxNewListItem: ptr ListItem_t) {.
    importc: "vListInsertEnd", header: "list.h".}
##
##  Remove an item from a list.  The list item has a pointer to the list that
##  it is in, so only the list item need be passed into the function.
##
##  @param uxListRemove The item to be removed.  The item will remove itself from
##  the list pointed to by it's pxContainer parameter.
##
##  @return The number of items that remain in the list after the list item has
##  been removed.
##
##  \page uxListRemove uxListRemove
##  \ingroup LinkedList
##

proc uxListRemove*(pxItemToRemove: ptr ListItem_t): UBaseType_t {.
    importc: "uxListRemove", header: "list.h".}