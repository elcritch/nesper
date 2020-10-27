import strutils
import nesper

let n1 = joinBytes32[uint32]([0x01'u8, 0x02, 0x03], 3)
let n2 = joinBytes32[uint32]([0x01'u8, 0x02, 0x03], 2)
let n3 = joinBytes32[uint32]([0x01'u8, 0x02, 0x03], 1)

let n4 = joinBytes32[int32]([0xFF'u8, 0xFF, 0xFF, 0xFF], 4)
let n5 = joinBytes32[int32]([0xFF'u8, 0xFF, 0xFF, 0xFE], 4)

let n6 = joinBytes64[int64]([0xFF'u8, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE], 8)

let n7 = joinBytes32[uint32]([0x01'u8, 0x02, 0x03], 3, top=true)
let n8 = joinBytes32[int32]([0xFF'u8, 0xFF, 0xFF], 4, top=true)

let n9 = joinBytes64[int64]([0xFF'u8, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE], 7, top=true)

let n10 = joinBytes32[int32]([0'u8, 255, 234, 221][1..3], 3, top=true) shr 8

assert n1 == 0x010203'u32, "got: " & $toHex(n1)
assert n2 == 0x0102'u32, "got: " & $n2.toHex()
assert n3 == 0x01'u32, "got: " & $n3.toHex()

assert n4 == -1, "got: " & $n4.toHex() & " int: " & $n4
assert n5 == -2, "got: " & $n5.toHex() & " int: " & $n5

assert n6 == -2'i64, "got: " & $n6.toHex() & " int: " & $n6

assert n7 == 0x01020300'u32, "got: " & $n7.toHex() & " int: " & $n7
assert (ashr(n8 , 8)) == -1'i32, "got: " & $n8.toHex() & " int: " & $n8

assert (ashr(n9 , 8)) == -2'i64, "got: " & $n9.toHex() & " int: " & $n9

echo " n10 == -5411 got: " & $(n10)
assert n10 == -5411, "got: " & $(n10)

echo "GENERAL"
