#*----------------------------------------------------------------------------/
#  FatFs - Generic FAT Filesystem module  R0.13c                              /
#-----------------------------------------------------------------------------/
#
# Copyright (C) 2018, ChaN, all right reserved.
#
# FatFs module is an open source software. Redistribution and use of FatFs in
# source and binary forms, with or without modification, are permitted provided
# that the following condition is met:#
# 1. Redistributions of source code must retain the above copyright notice,
#    this condition and the following disclaimer.
#
# This software is provided by the copyright holder and contributors "AS IS"
# and any warranties related to this software are DISCLAIMED.
# The copyright owner or contributors be NOT LIABLE for any damages caused
# by use of this software.
#
#----------------------------------------------------------------------------*/

import ffconf

## Integer types used for FatFs API
## 
when defined(windows):  # Main development platform
 const FF_INTDEF^ = 2
 type QWORD^ = uint64

# If C99+
const FF_INTDEF* = 2
type
  UINT* = uint
  BYTE* = char
  WORD* = uint16
  WCHAR* = uint16
  DWORD* = uint32
  QWORD* = uint64

## Filesystem object structure (FATFS)

type FATFS* {.importc: "FATFS", header: "ff.h", bycopy.} = object
  fs_type : BYTE   # Filesystem type (0:not mounted)
  pdrv : BYTE      # Associated physical drive
  n_fats : BYTE    # Number of FATs (1 or 2)
  wflag : BYTE     # win[] flag (b0:dirty)
  fsi_flag : BYTE  # FSINFO flags (b7:disabled, b0:dirty)
  id : WORD        # Volume mount ID
  n_rootdir : WORD # Number of root directory entries (FAT12/16)
  csize : WORD     # Cluster size [sectors]
#if FF_MAX_SS != FF_MIN_SS
  ssize :WORD      # Sector size (512, 1024, 2048 or 4096)
#endif
#if FF_USE_LFN
  lfnbuf : ptr WCHAR # LFN working buffer
#endif
#if FF_FS_EXFAT
  dirbuf : ptr BYTE # Directory entry block scratchpad buffer for exFAT
#endif
#if FF_FS_REENTRANT
  sobj : FF_SYNC_t # Identifier of sync object
#endif
#if !FF_FS_READONLY
  last_clst : DWORD # Last allocated cluster
  free_clst : DWORD # Number of free clusters
#endif
#if FF_FS_RPATH
  cdir : DWORD# Current directory start cluster (0:root)
#if FF_FS_EXFAT
  cdc_scl : DWORD # Containing directory start cluster (invalid when cdir is 0)
  cdc_size : DWORD# b31-b8:Size of containing directory, b7-b0: Chain status
  cdc_ofs : DWORD # Offset in the containing directory (invalid when cdir is 0)
#endif
#endif
  n_fatent : DWORD # Number of FAT entries (number of clusters + 2)
  fsize : DWORD# Size of an FAT [sectors]
  volbase : DWORD # Volume base sector
  fatbase : DWORD # FAT base sector
  dirbase : DWORD # Root directory base sector/cluster
  database :DWORD # Data base sector
#if FF_FS_EXFAT
  Dbitbase : DWORD# Allocation bitmap base sector
#endif
  winsect : DWORD# Current sector appearing in the win[]
  win : array[FF_MAX_SS, BYTE] # Disk access window for Directory, FAT (and file data at tiny cfg)
