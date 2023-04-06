import nesper
import nesper/nimy/pin
import nesper/nimy/button
import unittest
import os

test "button works":
  var pin=Pin(level:false)

  var btn=newButton(pin,true,100)
  let state1= getState btn
  pin.high() 
  let state2= getState btn
  let state3=getState btn
  sleep(150)
  let state4=getState btn
  let state5=getState btn
  pin.low() 
  let state6=getState btn
  sleep(90)
  let state7=getState btn
  sleep(20)
  let state8=getState btn
  let state9=getState btn
  echo "Checking "
  unittest.check state1==Up
  unittest.check state2==Press
  unittest.check state3==Pressing
  unittest.check state4==Hold
  unittest.check state5==Hold
  unittest.check state6==Release
  unittest.check state7==Releasing
  unittest.check state8==Up
  unittest.check state9==Up
test "2 buttons work":
  var pin=Pin(level:false)
  var pin2=Pin(level:false)

  var btn=newButton(pin,true,100)
  var btn2=newButton(pin2,true,100)

  let st1=getStateTogether(btn,btn2)
  pin.high() 
  let st2=getStateTogether(btn,btn2)
  sleep(20)
  pin2.high() 
  let state3=getStateTogether(btn,btn2)
  let state3_1=getStateTogether(btn,btn2)
  sleep(150)
  let state4=getStateTogether(btn,btn2)
  let state5=getStateTogether(btn,btn2)
  pin.low() 
  let state6=getStateTogether(btn,btn2)
  pin2.low() 
  sleep(50)
  let state7=getStateTogether(btn,btn2)
  sleep(20)
  let state7_1=getStateTogether(btn,btn2)
  sleep(50)
  let state8=getStateTogether(btn,btn2)
  let state9=getStateTogether(btn,btn2)
  echo "Checking "
  unittest.check st1==Up
  unittest.check st2==Up
  unittest.check state3==Press
  unittest.check state3_1==Pressing
  unittest.check state4==Hold
  unittest.check state5==Hold
  unittest.check state6==Hold
  unittest.check state7==Release
  unittest.check state7_1==Releasing
  unittest.check state8==Up
  unittest.check state9==Up
