##  Copyright 2018 Espressif Systems (Shanghai) PTE LTD
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##          http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

##  Defines for declaring and defining event base
##  #define ESP_EVENT_DECLARE_BASE(id) extern esp_event_base_t id
##  #define ESP_EVENT_DEFINE_BASE(id) esp_event_base_t id = #id
##  Event loop library types

type
  esp_event_base_t* = cstring

## *< unique pointer to a subsystem that exposes events

type
  esp_event_loop_handle_t* = pointer

## *< a number that identifies an event with respect to a base

type
  esp_event_handler_t* = proc (event_handler_arg: pointer;
                            event_base: esp_event_base_t; event_id: int32_t;
                            event_data: pointer)

## *< function called when an event is posted to the queue
##  Defines for registering/unregistering event handlers

const
  ESP_EVENT_ANY_BASE* = nil
  ESP_EVENT_ANY_ID* = -1
