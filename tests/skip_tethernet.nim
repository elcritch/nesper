
import nesper
import nesper/general
import nesper/networking/setup_ethernet

proc app_main*() =

  networkingInit() 

  # Connect networking
  var eth = EthConfigDM9051()
  networkingConnect(eth)

  # Connect networking
  onNetworking():
    logi(TAG, "Connected to %s", networkConnectionName)
    logi(TAG, "IPv4 address: %s", $networkIpAddr)
    logi(TAG, "network setup!\n")


  # turn off networking 
  check:
    networkingDisconnect()

  assert false, "shouldn't reach here!"
