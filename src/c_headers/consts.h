#include <stdint.h>

typedef int32 esp_err_t;

/* Definitions for error constants. */
#define ESP_OK          0       /*!< esp_err_t value indicating success (no error) */
#define ESP_FAIL        -1      /*!< Generic esp_err_t code indicating failure */

#define ESP_ERR_NO_MEM              0x101   /*!< Out of memory */
#define ESP_ERR_INVALID_ARG         0x102   /*!< Invalid argument */
#define ESP_ERR_INVALID_STATE       0x103   /*!< Invalid state */
#define ESP_ERR_INVALID_SIZE        0x104   /*!< Invalid size */
#define ESP_ERR_NOT_FOUND           0x105   /*!< Requested resource not found */
#define ESP_ERR_NOT_SUPPORTED       0x106   /*!< Operation or feature not supported */
#define ESP_ERR_TIMEOUT             0x107   /*!< Operation timed out */
#define ESP_ERR_INVALID_RESPONSE    0x108   /*!< Received response was invalid */
#define ESP_ERR_INVALID_CRC         0x109   /*!< CRC or checksum was invalid */
#define ESP_ERR_INVALID_VERSION     0x10A   /*!< Version was invalid */
#define ESP_ERR_INVALID_MAC         0x10B   /*!< MAC address was invalid */

#define ESP_ERR_WIFI_BASE           0x3000  /*!< Starting number of WiFi error codes */
#define ESP_ERR_MESH_BASE           0x4000  /*!< Starting number of MESH error codes */
#define ESP_ERR_FLASH_BASE          0x6000  /*!< Starting number of flash error codes */

// This is used to provide SystemView with positive IRQ IDs, otherwise sheduler events are not shown properly
// #define ETS_INTERNAL_INTR_SOURCE_OFF		(-ETS_INTERNAL_PROFILING_INTR_SOURCE)

#define ESP_INTR_ENABLE(inum)  xt_ints_on((1<<inum))
#define ESP_INTR_DISABLE(inum) xt_ints_off((1<<inum))

const char *esp_err_to_name(esp_err_t code);

const char *esp_err_to_name_r(esp_err_t code, char *buf, size_t buflen);

void ESP_ERROR_CHECK(int x);
void ESP_ERROR_CHECK_WITHOUT_ABORT(int x);


typedef uint32 TickType_t;

typedef struct xSTATIC_QUEUE
{
	void *pvDummy1[ 3 ];

	union
	{
		void *pvDummy2;
		UBaseType_t uxDummy2;
	} u;

	StaticList_t xDummy3[ 2 ];
	UBaseType_t uxDummy4[ 3 ];

		uint8_t ucDummy6;

		void *pvDummy7;

		UBaseType_t uxDummy8;
		uint8_t ucDummy9;

	portMUX_TYPE muxDummy;		//Mutex required due to SMP

} StaticQueue_t;
typedef StaticQueue_t StaticSemaphore_t;

typedef int8 portCHAR;	
typedef float portFLOAT;
typedef double portDOUBLE;
typedef int32 portLONG;
typedef int16 portSHORT;
typedef uint8 portSTACK_TYPE;
typedef int portBASE_TYPE;

typedef portSTACK_TYPE			StackType_t;
typedef portBASE_TYPE			BaseType_t;
typedef portBASE_TYPE	UBaseType_t;

typedef void (*intr_handler_t)(void *arg);

typedef struct shared_vector_desc_t shared_vector_desc_t;
typedef struct vector_desc_t vector_desc_t;

struct shared_vector_desc_t {
    // int disabled: 1;
    // int source: 8;
    int disabled;
    int source;
    volatile uint32 *statusreg;
    uint32 statusmask;
    intr_handler_t isr;
    void *arg;
    shared_vector_desc_t *next;
};

//Pack using bitfields for better memory use
struct vector_desc_t {
    // int flags: 16;                          //OR of VECDESC_FLAG_* defines
    // unsigned int cpu: 1;
    // unsigned int intno: 5;
    // int source: 8;                          //Interrupt mux flags, used when not shared
    int flags;                          //OR of VECDESC_FLAG_* defines
    unsigned int cpu;
    unsigned int intno;
    int source;                          //Interrupt mux flags, used when not shared
    shared_vector_desc_t *shared_vec_info;  //used when VECDESC_FL_SHARED
    vector_desc_t *next;
};

struct intr_handle_data_t {
    vector_desc_t *vector_desc;
    shared_vector_desc_t *shared_vector_desc;
};


typedef struct intr_handle_data_t intr_handle_data_t;
typedef intr_handle_data_t* intr_handle_t ;
