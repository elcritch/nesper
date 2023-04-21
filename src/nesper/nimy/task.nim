
import nesper/esp/task


template makeTaskCrashable* [T](name:string,taskData:ptr T,runTask:(proc (state:ptr T))):untyped =
  ##Task runs a funcion inside a task
  ##Task should contain a while true: loop and an exception handler
  ##WARNING!! Has no safety nets, if your function crashes or reaches the end it will crash the board
  proc task (statePtr:pointer) {.exportc, cdecl.}=
    var state=cast[ptr T](statePtr)
    runTask(state)
  var handle:TaskHandle_t
  discard xTaskCreate(task,name,8128,taskData,5,addr(handle))
  handle

template makeTask* [T](name:string,taskData:ptr T,runTask:(proc (state:ptr T))):untyped =
  ##[Runs the provided function in a new task.
  The function should have an endless `while true:` loop. Probably with some delays 
  If the task crashes it will be restarted and the exception will be logged

  *Example*:
  ```nim
  proc readTask(state:ptr ProgramState)=
  while true:
    delayMillis(500)
    var temp:cfloat=0.0
    discard state.pins.tempSensor.gpio.ds18x20_measureand_read(state.tempAddress,addr(temp))
    echo  fmt"finished reading temp {temp}"
  
  let state=ProgramState(..)
  makeTask("tempTask",addr(state),readTemp)
  ```]##
  proc task (statePtr:pointer) {.exportc, cdecl.}=
    var state=cast[ptr T](statePtr)
    while true:
      try:
        runTask(state)
      except:
        let
          e = getCurrentException()
          msg = getCurrentExceptionMsg()
        echo "Task '",name,"': Got exception", repr(e), " with message ", msg,"\n Task will be restarted"
  
    
  var handle:TaskHandle_t
  discard xTaskCreate(task,name,8128,taskData,5,addr(handle))
  handle
 
