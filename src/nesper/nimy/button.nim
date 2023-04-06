import pin
import times
import os
type ButtonState* = enum
  ##The states a button can be in
  Press,
  Hold,
  Up,
  Release

type Button* = object
  ##The data needed to have a stateful button
  highIsDown*: bool
  pressedTime*: Time
  pressLeeway*: int64
  down*: bool
  transitioned*: bool

  pin*: Pin

proc isDown*(btnState: ButtonState): bool{.inline.} = btnState == Hold or btnState == Press

proc pressed*(states:varargs[ButtonState]): bool =
  ##Checks if all the states are all pressed at the same time
  for state in states:
    if state != Press:
      return false

proc newButton*(pin: Pin, highIsDown: bool, pressLeeway: int64): Button = 
  return Button(highIsDown: highIsDown, down: false, pin: pin, pressedTime: Time(), pressLeeway: pressLeeway)


proc getButtonState*(button: var Button): ButtonState =
  ##Reads the state of the button and updates the buttons internal state
  ##This will set the button.held and button.down and button.pressedTime

  let down =
    if button.highIsDown: button.pin.isHigh()
    else: button.pin.isLow()
  if down:
    #We know this must be the first press
    if not button.down:
      button.pressedTime=getTime()
      button.transitioned = false
      button.down=true
      return Press
    #if the button is still held, no change
    if button.transitioned: return Hold
    
    let newMillis = getTime()
    
    if button.down and (newMillis-button.pressedTime).inMilliseconds() > button.pressLeeway:
      button.transitioned = true
      return Hold
    else:
      return Press


  else:
    #TODO: do leeway checking for release just like press
    if button.down:
      button.pressedTime=getTime()
      button.transitioned = false
      button.down=false
      return Release 
    #if the button is transitioned
    if button.transitioned: return Up
    
    let newMillis = getTime()
    
    if (newMillis-button.pressedTime).inMilliseconds() > button.pressLeeway:
      button.transitioned = true
      return Up
    else:
      return Release 

