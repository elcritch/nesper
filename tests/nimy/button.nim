import nesper
import nesper/nimy/pin
import nesper/nimy/button
import unittest
import os

test "button works":
  var pin=Pin(level:false)

  var btn=newButton(pin,true,100)
  let state1= getButtonState btn
  pin.high() 
  let state2= getButtonState btn
  let state3=getButtonState btn
  sleep(150)
  let state4=getButtonState btn
  let state5=getButtonState btn
  pin.low() 
  let state6=getButtonState btn
  sleep(90)
  let state7=getButtonState btn
  sleep(20)
  let state8=getButtonState btn
  let state9=getButtonState btn
  echo "Checking "
  unittest.check state1==Up
  unittest.check state2==Press
  unittest.check state3==Press
  unittest.check state4==Hold
  unittest.check state5==Hold
  unittest.check state6==Release
  unittest.check state7==Release
  unittest.check state8==Up
  unittest.check state9==Up
