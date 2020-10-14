import nesper/gpios

{GPIO_NUM_11, GPIO_NUM_2}.configure(GPIO_MODE_OUTPUT)
{GPIO_NUM_10, GPIO_NUM_3}.configure(GPIO_MODE_INPUT)
{GPIO_NUM_12}.configure(GPIO_MODE_INPUT, pull_up=true)
{GPIO_NUM_13}.configure(GPIO_MODE_INPUT, pull_down=true)
{GPIO_NUM_13}.configure(GPIO_MODE_OUTPUT_OD, pull_down=true)
{GPIO_NUM_14}.configure(GPIO_MODE_INPUT_OUTPUT, interrupt = GPIO_INTR_ANYEDGE)

GPIO_NUM_14.set(true)

let state = GPIO_NUM_13.get()
echo("gpio 14: " & $state)