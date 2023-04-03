import gpio
import times
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
  held*: bool
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
    
    if button.held: return Hold

    let newMillis = getTime()
    
    result =
      if button.down and (newMillis-button.pressedTime).inMilliseconds() > button.pressLeeway:
        button.held = true
        Hold
      else:
        Press

    button.down = true

  else:
    result = if button.down: Release else: Up
    button.held = false
    button.down = false

