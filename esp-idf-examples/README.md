
The two examples `simplewifi` and `simplewifi-rpc` are currently the only examples that have been tested on hardware. 

The `simplewifi` example is a simple method showing how to use async servers with Nim. However, as of Nim 1.4, there are still some challenges running async with ORC on small devices. This should get better over time and may work depending on your paramters. 

For production usage, it's recommended to use one of the `simplewifi-rpc` methods. Using socket `select` allows efficiently servicing RPC calls without requiring async. However, this means only *one* RPC call can be handled at a time. This could be worked around by spawning more tasks or sockets, but is sufficient for many cases. 


