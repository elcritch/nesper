## *
##  @file
##  IPv4 address API
##
##
##  Copyright (c) 2001-2004 Swedish Institute of Computer Science.
##  All rights reserved.
##
##  Redistribution and use in source and binary forms, with or without modification,
##  are permitted provided that the following conditions are met:
##
##  1. Redistributions of source code must retain the above copyright notice,
##     this list of conditions and the following disclaimer.
##  2. Redistributions in binary form must reproduce the above copyright notice,
##     this list of conditions and the following disclaimer in the documentation
##     and/or other materials provided with the distribution.
##  3. The name of the author may not be used to endorse or promote products
##     derived from this software without specific prior written permission.
##
##  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
##  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
##  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
##  SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
##  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
##  OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
##  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
##  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
##  IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
##  OF SUCH DAMAGE.
##
##  This file is part of the lwIP TCP/IP stack.
##
##  Author: Adam Dunkels <adam@sics.se>
##
##

import
  lwip/opt, lwip/def

when LWIP_IPV4:
  ## * This is the aligned version of ip4_addr_t,
  ##    used as local variable, on the stack, etc.
  type
    ip4_addr_t* {.importc: "ip4_addr_t", header: "ip4_addr_t.h", bycopy.} = object
      `addr`* {.importc: "addr".}: u32_t

  ## * ip4_addr_t uses a struct for convenience only, so that the same defines can
  ##  operate both on ip4_addr_t as well as on ip4_addr_p_t.
  type
    ip4_addr_t* = ip4_addr_t
  ##  Forward declaration to not include netif.h
  type
    netif* {.importc: "netif", header: "ip4_addr_t.h", bycopy.} = object

  ## * 255.255.255.255
  const
    IPADDR_NONE* = (cast[u32_t](0xFFFFFFFF))
  ## * 127.0.0.1
  const
    IPADDR_LOOPBACK* = (cast[u32_t](0x7F000001))
  ## * 0.0.0.0
  const
    IPADDR_ANY* = (cast[u32_t](0x00000000))
  ## * 255.255.255.255
  const
    IPADDR_BROADCAST* = (cast[u32_t](0xFFFFFFFF))
  ##  Definitions of the bits in an Internet address integer.
  ##
  ##    On subnets, host and network parts are found according to
  ##    the subnet mask, not these masks.
  template IP_CLASSA*(a: untyped): untyped =
    ((((u32_t)(a)) and 0x80000000) == 0)

  const
    IP_CLASSA_NET* = 0xFF000000
    IP_CLASSA_NSHIFT* = 24
    IP_CLASSA_HOST* = (0xFFFFFFFF and not IP_CLASSA_NET)
    IP_CLASSA_MAX* = 128
  template IP_CLASSB*(a: untyped): untyped =
    ((((u32_t)(a)) and 0xC0000000) == 0x80000000)

  const
    IP_CLASSB_NET* = 0xFFFF0000
    IP_CLASSB_NSHIFT* = 16
    IP_CLASSB_HOST* = (0xFFFFFFFF and not IP_CLASSB_NET)
    IP_CLASSB_MAX* = 65536
  template IP_CLASSC*(a: untyped): untyped =
    ((((u32_t)(a)) and 0xE0000000) == 0xC0000000)

  const
    IP_CLASSC_NET* = 0xFFFFFF00
    IP_CLASSC_NSHIFT* = 8
    IP_CLASSC_HOST* = (0xFFFFFFFF and not IP_CLASSC_NET)
  template IP_CLASSD*(a: untyped): untyped =
    (((u32_t)(a) and 0xF0000000) == 0xE0000000)

  const
    IP_CLASSD_NET* = 0xF0000000
    IP_CLASSD_NSHIFT* = 28
    IP_CLASSD_HOST* = 0x0FFFFFFF
  template IP_MULTICAST*(a: untyped): untyped =
    IP_CLASSD(a)

  template IP_EXPERIMENTAL*(a: untyped): untyped =
    (((u32_t)(a) and 0xF0000000) == 0xF0000000)

  template IP_BADCLASS*(a: untyped): untyped =
    (((u32_t)(a) and 0xF0000000) == 0xF0000000)

  const
    IP_LOOPBACKNET* = 127
  ## * Set an IP address given by the four byte-parts
  template IP4_ADDR*(ipaddr, a, b, c, d: untyped): untyped =
    (ipaddr).`addr` = PP_HTONL(LWIP_MAKEU32(a, b, c, d))

  ## * Copy IP address - faster than ip4_addr_set: no NULL check
  template ip4_addr_copy*(dest, src: untyped): untyped =
    ((dest).`addr` = (src).`addr`)

  ## * Safely copy one IP address to another (src may be NULL)
  template ip4_addr_set*(dest, src: untyped): untyped =
    ((dest).`addr` = (if (src) == nil: 0 else: (src).`addr`))

  ## * Set complete address to zero
  template ip4_addr_set_zero*(ipaddr: untyped): untyped =
    ((ipaddr).`addr` = 0)

  ## * Set address to IPADDR_ANY (no need for lwip_htonl())
  template ip4_addr_set_any*(ipaddr: untyped): untyped =
    ((ipaddr).`addr` = IPADDR_ANY)

  ## * Set address to loopback address
  template ip4_addr_set_loopback*(ipaddr: untyped): untyped =
    ((ipaddr).`addr` = PP_HTONL(IPADDR_LOOPBACK))

  ## * Check if an address is in the loopback region
  template ip4_addr_isloopback*(ipaddr: untyped): untyped =
    (((ipaddr).`addr` and PP_HTONL(IP_CLASSA_NET)) ==
        PP_HTONL((cast[u32_t](IP_LOOPBACKNET)) shl 24))

  ## * Safely copy one IP address to another and change byte order
  ##  from host- to network-order.
  template ip4_addr_set_hton*(dest, src: untyped): untyped =
    ((dest).`addr` = (if (src) == nil: 0 else: lwip_htonl((src).`addr`)))

  ## * IPv4 only: set the IP address given as an u32_t
  template ip4_addr_set_u32*(dest_ipaddr, src_u32: untyped): untyped =
    ((dest_ipaddr).`addr` = (src_u32))

  ## * IPv4 only: get the IP address as an u32_t
  template ip4_addr_get_u32*(src_ipaddr: untyped): untyped =
    ((src_ipaddr).`addr`)

  ## * Get the network address by combining host address with netmask
  template ip4_addr_get_network*(target, host, netmask: untyped): void =
    while true:
      ((target).`addr` = ((host).`addr`) and ((netmask).`addr`))
      if not 0:
        break

  ## *
  ##  Determine if two address are on the same network.
  ##
  ##  @arg addr1 IP address 1
  ##  @arg addr2 IP address 2
  ##  @arg mask network identifier mask
  ##  @return !0 if the network identifiers of both address match
  ##
  template ip4_addr_netcmp*(addr1, addr2, mask: untyped): untyped =
    (((addr1).`addr` and (mask).`addr`) == ((addr2).`addr` and (mask).`addr`))

  template ip4_addr_cmp*(addr1, addr2: untyped): untyped =
    ((addr1).`addr` == (addr2).`addr`)

  template ip4_addr_isany_val*(addr1: untyped): untyped =
    ((addr1).`addr` == IPADDR_ANY)

  template ip4_addr_isany*(addr1: untyped): untyped =
    ((addr1) == nil or ip4_addr_isany_val((addr1)[]))

  template ip4_addr_isbroadcast*(addr1, netif: untyped): untyped =
    ip4_addr_isbroadcast_u32((addr1).`addr`, netif)

  proc ip4_addr_isbroadcast_u32*(`addr`: u32_t; netif: ptr netif): u8_t {.
      importc: "ip4_addr_isbroadcast_u32", header: "ip4_addr_t.h".}
  template ip_addr_netmask_valid*(netmask: untyped): untyped =
    ip4_addr_netmask_valid((netmask).`addr`)

  proc ip4_addr_netmask_valid*(netmask: u32_t): u8_t {.
      importc: "ip4_addr_netmask_valid", header: "ip4_addr_t.h".}
  template ip4_addr_ismulticast*(addr1: untyped): untyped =
    (((addr1).`addr` and PP_HTONL(0xF0000000)) == PP_HTONL(0xE0000000))

  template ip4_addr_islinklocal*(addr1: untyped): untyped =
    (((addr1).`addr` and PP_HTONL(0xFFFF0000)) == PP_HTONL(0xA9FE0000))

  ##  #define ip4_addr_debug_print_parts(debug, a, b, c, d) \
  ##  LWIP_DEBUGF(debug, ("%" U16_F ".%" U16_F ".%" U16_F ".%" U16_F, a, b, c, d))
  ##  #define ip4_addr_debug_print(debug, ipaddr) \
  ##    ip4_addr_debug_print_parts(debug, \
  ##                        (u16_t)((ipaddr) != NULL ? ip4_addr1_16(ipaddr) : 0),       \
  ##                        (u16_t)((ipaddr) != NULL ? ip4_addr2_16(ipaddr) : 0),       \
  ##                        (u16_t)((ipaddr) != NULL ? ip4_addr3_16(ipaddr) : 0),       \
  ##                        (u16_t)((ipaddr) != NULL ? ip4_addr4_16(ipaddr) : 0))
  ##  #define ip4_addr_debug_print_val(debug, ipaddr) \
  ##    ip4_addr_debug_print_parts(debug, \
  ##                        ip4_addr1_16_val(ipaddr),       \
  ##                        ip4_addr2_16_val(ipaddr),       \
  ##                        ip4_addr3_16_val(ipaddr),       \
  ##                        ip4_addr4_16_val(ipaddr))
  ##  Get one byte from the 4-byte address
  template ip4_addr_get_byte*(ipaddr, idx: untyped): untyped =
    ((cast[ptr u8_t]((addr((ipaddr).`addr`))))[idx])

  template ip4_addr1*(ipaddr: untyped): untyped =
    ip4_addr_get_byte(ipaddr, 0)

  template ip4_addr2*(ipaddr: untyped): untyped =
    ip4_addr_get_byte(ipaddr, 1)

  template ip4_addr3*(ipaddr: untyped): untyped =
    ip4_addr_get_byte(ipaddr, 2)

  template ip4_addr4*(ipaddr: untyped): untyped =
    ip4_addr_get_byte(ipaddr, 3)

  ##  Get one byte from the 4-byte address, but argument is 'ip4_addr_t',
  ##  not a pointer
  template ip4_addr_get_byte_val*(ipaddr, idx: untyped): untyped =
    ((u8_t)(((ipaddr).`addr` shr (idx * 8)) and 0x000000FF))

  template ip4_addr1_val*(ipaddr: untyped): untyped =
    ip4_addr_get_byte_val(ipaddr, 0)

  template ip4_addr2_val*(ipaddr: untyped): untyped =
    ip4_addr_get_byte_val(ipaddr, 1)

  template ip4_addr3_val*(ipaddr: untyped): untyped =
    ip4_addr_get_byte_val(ipaddr, 2)

  template ip4_addr4_val*(ipaddr: untyped): untyped =
    ip4_addr_get_byte_val(ipaddr, 3)

  ##  These are cast to u16_t, with the intent that they are often arguments
  ##  to printf using the U16_F format from cc.h.
  template ip4_addr1_16*(ipaddr: untyped): untyped =
    (cast[u16_t](ip4_addr1(ipaddr)))

  template ip4_addr2_16*(ipaddr: untyped): untyped =
    (cast[u16_t](ip4_addr2(ipaddr)))

  template ip4_addr3_16*(ipaddr: untyped): untyped =
    (cast[u16_t](ip4_addr3(ipaddr)))

  template ip4_addr4_16*(ipaddr: untyped): untyped =
    (cast[u16_t](ip4_addr4(ipaddr)))

  template ip4_addr1_16_val*(ipaddr: untyped): untyped =
    (cast[u16_t](ip4_addr1_val(ipaddr)))

  template ip4_addr2_16_val*(ipaddr: untyped): untyped =
    (cast[u16_t](ip4_addr2_val(ipaddr)))

  template ip4_addr3_16_val*(ipaddr: untyped): untyped =
    (cast[u16_t](ip4_addr3_val(ipaddr)))

  template ip4_addr4_16_val*(ipaddr: untyped): untyped =
    (cast[u16_t](ip4_addr4_val(ipaddr)))

  const
    IP4ADDR_STRLEN_MAX* = 16
  ## * For backwards compatibility
  template ip_ntoa*(ipaddr: untyped): untyped =
    ipaddr_ntoa(ipaddr)

  proc ipaddr_addr*(cp: cstring): u32_t {.importc: "ipaddr_addr", header: "ip4_addr_t.h".}
  proc ip4addr_aton*(cp: cstring; `addr`: ptr ip4_addr_t): cint {.
      importc: "ip4addr_aton", header: "ip4_addr_t.h".}
  ## * returns ptr to static buffer; not reentrant!
  proc ip4addr_ntoa*(`addr`: ptr ip4_addr_t): cstring {.importc: "ip4addr_ntoa",
      header: "ip4_addr_t.h".}
  proc ip4addr_ntoa_r*(`addr`: ptr ip4_addr_t; buf: cstring; buflen: cint): cstring {.
      importc: "ip4addr_ntoa_r", header: "ip4_addr_t.h".}