import ../queue

type 
  SemaphoreHandle_t* = QueueHandle_t
  FF_SYNC_t* = SemaphoreHandle_t

# SD card sector size 
const
  CONFIG_WL_SECTOR_SIZE* = 4096 # From sdkconfig.h

  FF_SS_SDCARD* = 512
  # wear_levelling library sector size 
  FF_SS_WL* = CONFIG_WL_SECTOR_SIZE

  FF_MIN_SS* = min(FF_SS_SDCARD, FF_SS_WL)
  FF_MAX_SS* = max(FF_SS_SDCARD, FF_SS_WL)

  # This set of options configures the range of sector size to be supported. (512,
  # 1024, 2048 or 4096) Always set both 512 for most systems, generic memory card and
  # harddisk. But a larger value may be required for on-board flash memory and some
  # type of optical media. When FF_MAX_SS is larger than FF_MIN_SS, FatFs is configured
  # for variable sector size mode and disk_ioctl() function needs to implement
  # GET_SECTOR_SIZE command.
