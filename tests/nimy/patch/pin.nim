type Pin* = ref object
  level*:bool
  ##More erganomic wrapper around esp gpio pin functions

proc high*(pin:var Pin) =  
  echo "pins set high"
  pin.level=true
  ##Set pin output to 1/on 

proc low*(pin:var  Pin) = pin.level=false
  ##Set pin output to 0/off 

proc read*(pin:Pin):cint=return if pin.level :1 else:0
  ##Read the value of the pin
proc isHigh*(pin:Pin):bool= pin.level
  ##Read the value of the pin and check if it is equal to 1
  ##Same as `pin.read()==1`
proc isLow*(pin:Pin):bool= not pin.level
  ##Read the value of the pin and check if it is equal to 0
  ##Same as `pin.read()==0`
