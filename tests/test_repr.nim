
type 
  Example[T] = ref object 
    a*: T
    id*: int


proc testprint[T](a: T, obj: Example) =  
  echo("testprint: a: " & $(repr(a)))
  echo("testprint: obj: " & $(repr(obj)))
  obj.id.inc(10)


var e1 = Example[string](a: "test", id: 3)

testprint("example", e1)
  
echo("example: : " & $(e1.id))
