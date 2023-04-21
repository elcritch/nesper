import pin
import times
import macros
import os
import std/sequtils

##Contains a button type and functions that handle common button associated tasks.
##Tracks states and transitions between them


type ButtonState* = enum
  ##The states a button can be in
  Press,##Emmited once when transitioning from up to down 
  Pressing,##Emmited after Press for the duration of the pressLeeway time
  Hold, ##Emitted when the button is down after the pressLeeway has elapsed
  Up, ##Emitted when the button is up after the pressLeeway has elapsed
  Release,##Emmited once when transitioning from down to up
  Releasing,##Emmited after Release for the duration of the pressLeeway time

type Button* = object
  ##The data needed to have a stateful button
  highIsDown*: bool
  transitionStart*: Time
  trasitionWindowMs*: int64 ##How many milliseconds the button will be in the pressing/releaseing state for when transitioning 
  down*: bool
  transitioned*: bool ##Whether the button has finished a state transition. Up to down via press or down to up via release 
  pin*: Pin

proc isDown*(btnState: ButtonState): bool{.inline.} = btnState == Hold or btnState == Press

  

proc newButton*(pin: Pin, highIsDown: bool, transitionWindowMs: int64): Button = 
  return Button(highIsDown: highIsDown, down: false, pin: pin, transitionStart: Time(),  trasitionWindowMs:transitionWindowMs)


proc getState*(button: var Button): ButtonState =
  ##Reads the state of the button and updates the buttons internal state
  ##This will set the button.transitioned and button.down and button.pressedTime
  ##*States:*
  ##Press: Emmited once when transitioning from up to down 
  ##Pressing: Emmited after Press for the duration of the pressLeeway time
  ##Hold: Emitted when the button is down after the pressLeeway has elapsed
  ##Up: Emitted when the button is up after the pressLeeway has elapsed
  ##Release: Emmited once when transitioning from down to up
  ##Releasing: Emmited after Release for the duration of the pressLeeway time

  let down =
    if button.highIsDown: button.pin.isHigh()
    else: button.pin.isLow()

  if down:
    #We know this must be the first press
    if not button.down:
      button.transitionStart=getTime()
      button.transitioned = false
      button.down=true
      return Press
    #if the button is still held, no change
    if button.transitioned: return Hold
    
    let newMillis = getTime()
    
    if button.down and (newMillis-button.transitionStart).inMilliseconds() > button.trasitionWindowMs:
      button.transitioned = true
      return Hold
    else:
      return Pressing

  else:

    if button.down:
      button.transitionStart=getTime()
      button.transitioned = false
      button.down=false
      return Release 
    if button.transitioned: return Up
    
    let newMillis = getTime()
    
    if (newMillis-button.transitionStart).inMilliseconds() > button.trasitionWindowMs:
      button.transitioned = true
      return Up
    else:
      return Releasing 
template `<=`[T](x:set[T],y:set[T]):bool=
  x==y or x<y 

proc together*(states:varargs[ButtonState]): ButtonState =
  ##Checks if the states are aligned.
  ##Useful for checking pressing more than one button at once
  ##
  ##NOTE: Press will trigger once all buttons are either "Press" or "Pressing" 
  ##NOTE: Release will trigger once all buttons are either "Release" or "Releasing" 
  

  var btnStates:set[ButtonState]={}
  #If at any time they are all the same, we can just send that
  var first =states[0]
  var sameAsFirst=true;

  for state in states:
    btnStates.incl state
    if state!=first: sameAsFirst=false

  const onlyPress={Press,Pressing}
  #so long as one button is held and they are all down, we consider it a hold
  #const hold={Press,Pressing,Hold,Release}
  const onlyRelease={Release,Releasing}
  echo "state:",btnStates
  
  if sameAsFirst: first
  else :
    if btnStates.contains Up: Up 
    elif btnStates<=onlyPress:
      if btnStates.contains Press:Press
      else: Pressing
    elif btnStates<=onlyRelease:
        if btnStates.contains Release: Release
        else: Releasing
    elif btnStates.contains Hold :Hold 
    else:Up 

macro getStateTogether*(btns:varargs[Button]): ButtonState =
  ##gets the states of the buttons and checks if they are all aligned 
  ##Useful for checking pressing more than one button at once
  ##
  ##Warning!! You should only get the state once per time step!
  ##If you need the button states again after calling this, call 'getState' instead
  ##and feed the results into 'together'.  
  ##
  ##NOTE: Press will trigger once all buttons are either "Press" or "Pressing" 
  ##NOTE: Release will trigger once all buttons are either "Release" or "Releasing" 
  result= newCall( ident "together")
  for a in btns:
    var stateGetter = newCall( ident "getState")
    stateGetter.add a
    result.add (stateGetter)

  
  
