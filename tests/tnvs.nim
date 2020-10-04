
import nesper/consts
import nesper/general
import nesper/nvs


let nvs = newNvs("storage", NVS_READONLY)

nvs.setInt("a", 1)

let a = nvs.getInt("a")

echo "a: " & $a

