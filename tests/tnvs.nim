
import nesper
import nesper/nvs


let nvs_handle = newNvs("storage", NVS_READWRITE)
nvs_handle.setInt("a", 1)
let a = nvs_handle.getInt("a")
echo "a: " & $a

nvs_handle.setStr("b", "bb")
let b = nvs_handle.getStr("b")
echo "b: " & $b

