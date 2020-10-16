import strutils
import nesper

let n1 = joinBytes32[uint32]([0x01'u8, 0x02, 0x03], 3)
let n2 = joinBytes32[uint32]([0x01'u8, 0x02, 0x03], 2)
let n3 = joinBytes32[uint32]([0x01'u8, 0x02, 0x03], 1)

let n4 = joinBytes32[int32]([0xFF'u8, 0xFF, 0xFF, 0xFF], 4)
let n5 = joinBytes32[int32]([0xFF'u8, 0xFF, 0xFF, 0xFE], 4)

let n6 = joinBytes64[int64]([0xFF'u8, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE], 8)

assert n1 == 0x010203'u32, "got: " & $toHex(n1)
assert n2 == 0x0102'u32, "got: " & $n2.toHex()
assert n3 == 0x01'u32, "got: " & $n3.toHex()

assert n4 == -1, "got: " & $n4.toHex() & " int: " & $n4
assert n5 == -2, "got: " & $n5.toHex() & " int: " & $n5

assert n6 == -2'i64, "got: " & $n6.toHex() & " int: " & $n6

echo "GENERAL"
