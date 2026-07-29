
/* cpuemu.h -- Header file for C programs to run on the CPU emulator. */
#pragma once
#ifndef CPUEMU_H
#define CPUEMU_H

/* System call numbers. */
//#include <cstring>
#define _EMUNR_exit  -1
#define _EMUNR_write -2
#define _EMUNR_read  -3
#define _EMUNR_trace_start -4
#define _EMUNR_trace_stop  -5
#define _EMNUR_trace_set_name -6
#define _EMNUR_trace_delay -7
#define _EMUNR_trace_set_metadata -8

/* Conventional stringification macros. */
#define __STR(x) #x
#define _STR(x) __STR(x)

/* Emit an inline assembly block that calls the given main function.
 * Should appear before any function or data declarations. */
#define _EMU_STARTUP(main_func) asm (                               \
    ".text; "                                                       \
    "_start: "                                                      \
    /* Initialize stack pointer to somewhere far away. */           \
    "li sp, 0x10000000; "                                           \
    /* Call main function (argc and argv are already 0). */         \
    "call " #main_func "; "                                         \
    /* Pass return value to exit system call. */                    \
    "li a7, " _STR(_EMUNR_exit) "; "                                \
    "ecall; "                                                       \
    /* That shouldn't have failed, but handle this case somehow. */ \
    "_HALT: "                                                       \
    "j _HALT"                                                       \
);

/* Define this macro if you supply your own startup code. */
#ifndef EMU_NO_DEFAULT_STARTUP
_EMU_STARTUP(main)
#endif


/* Intrinsic functions for special assembly instructions. */

/* Cause a software breakpoint */
static inline void breakpoint(void) {
    asm volatile ( "ebreak" ::: "memory" );
}

/* Serialize the instruction stream.
 * All instructions before the fence finish before any instructions after the
 * fence are issued. */
static inline void fence(void) {
    asm volatile ( "fence.i" ::: "memory" );
}

/* Read the cycle counter.
 * returns -- Cycle count as of the function's call. */
static inline int rdcycle(void) {
    register int _R_result;
    asm volatile ( "rdcycle %0" : "=r"(_R_result) );
    return _R_result;
}

/* Flush the cache line containing addr.
 * addr -- The address to flush. */
static inline void flush(void *__addr) {
    asm volatile ( "cbo.flush (%0)" :: "r"(__addr) : "memory" );
}

/* Flush the entire cache. */
static inline void flushall(void) {
    asm volatile ( "th.dcache.ciall" ::: "memory" );
}


/* Internal convenience macros for system calls.
 * Must be used together with register-bound variables to work correctly. */
#define _EMU_SYSCALL(rv, no, ...) asm volatile (                \
    "li a7, " #no "; ecall" : "=r"(rv) : __VA_ARGS__ : "memory" \
)
#define _EMU_SYSCALL0(rv, no)             \
    _EMU_SYSCALL(rv, no)
#define _EMU_SYSCALL1(rv, no, a1)         \
    _EMU_SYSCALL(rv, no, "r"(a1))
#define _EMU_SYSCALL2(rv, no, a1, a2)     \
    _EMU_SYSCALL(rv, no, "r"(a1), "r"(a2))
#define _EMU_SYSCALL3(rv, no)             \
    _EMU_SYSCALL(rv, no)
#define _EMU_SYSCALL4(rv, no, a1, a2, a3, a4)                 \
    _EMU_SYSCALL(rv, no, "r"(a1), "r"(a2), "r"(a3), "r"(a4))
#define _EMU_SYSCALL5(rv, no, a1, a2)     \
    _EMU_SYSCALL(rv, no, "r"(a1), "r"(a2))
#define _EMU_SYSCALL6(rv, no) \
    _EMU_SYSCALL(rv, no)
/* System call wrappers. */

/* Shut down the emulator.
 * status  -- The exit status as an integer.
 * returns -- Never. */
static inline void exit(int __status) {
    register int _R_status asm("a0") = __status;
    register int _R_result asm("a0");
    _EMU_SYSCALL1(_R_result, _EMUNR_exit, _R_status);
}

/* Write from buffer to console.
 * buffer  -- Buffer to write from. Must be at least size bytes long.
 * size    -- Amount of bytes to write.
 * returns -- Amount of bytes written (always equal to size). */
static inline int write(const void *__buffer, int __size) {
    register int _R_buffer asm("a0") = (int) __buffer;
    register int _R_size   asm("a1") =       __size;
    register int _R_result asm("a0");
    _EMU_SYSCALL2(_R_result, _EMUNR_write, _R_buffer, _R_size);
    return _R_result;
}

/* Read from console into buffer.
 * buffer  -- Buffer to store into. Must have at least size bytes' space.
 * size    -- Maximum amount to read at once. If more bytes are available for
 *            reading, they are buffered internally until the next read()
 *            call.
 * returns -- Amount of bytes read.
 */
static inline int read(void *__buffer, int __size) {
    register int _R_buffer asm("a0") = (int) __buffer;
    register int _R_size   asm("a1") =       __size;
    register int _R_result asm("a0");
    _EMU_SYSCALL2(_R_result, _EMUNR_read, _R_buffer, _R_size);
    return _R_result;
}

/* Start power trace capture. 
 *
 * Should be called directly before any relevant AES calcualtion takes place
 *
 * returns -- 1 If trace was started
 *            0 If no trace was started (because one capture is already running)
 *
*/
static inline int trace_start() {
  register int _R_result asm("a0");
  _EMU_SYSCALL3(_R_result, _EMUNR_trace_start);
  return _R_result;
}

/* Stop power trace capture. 
 *
 * If the set trace name already exists we append to the end 
 * of the trace otherwise a new file will be created by the emulator with the trace name
 * containing the captured power trace
 *
 * returns -- 1 If trace was stopped successfully
 *            0 if no trace was running 
 */
static inline int trace_stop() {
  register int _R_result asm("a0");
  _EMU_SYSCALL0(_R_result, _EMUNR_trace_stop);
  return _R_result;
}


/* Set the name for the file where the power trace will be captured. 
 * WARNING: Can be called during an already running capture. This will result in parts
 * of the already running capture being written to another file if it is called 
 * with a new name. The only safe use of this syscall is calling it outside of
 * any running trace.
 *
 * return -- -1 if the pointer to the buffer referenced invalid memory that would
 *            produce a fault, 0 if the trace name was set successfully.
 * */ 
static inline int trace_set_name(const void *__buffer, int __size) {
  register int _R_buffer asm("a0") = (int) __buffer;
  register int _R_size   asm("a1") = __size;
  register int _R_result asm("a0");
  _EMU_SYSCALL5(_R_result, _EMNUR_trace_set_name, _R_buffer, _R_size); 
  return _R_result;
}

/*
 * Delay the trace for a random amount of cycles
 *
 * Delays the run of the program by a random amount of cycles and will add a 
 * random amount of power draw depending on the length of the stall to the 
 * power trace value
 *
 * return -- Always 0, return value can be ignored. 
 * */
static inline int trace_delay() {
  register int _R_result asm("a0");
  _EMU_SYSCALL6(_R_result, _EMNUR_trace_delay);
  return _R_result;
}

/* Attach a key/value pair to the metadata of the power trace.
 *
 * The pair is stored by the emulator and written into the trace file by the
 * next trace_stop() call. WARNING: Setting a key that was already set overwrites 
 * its value. When trace_stop() extends an already existing trace file, the pending
 * metadata is merged into that file's metadata, with these newly set keys
 * taking precedence. The pending metadata is cleared after every trace_stop(),
 * so each capture starts with an empty metadata set. May be called inside or
 * outside of an active capture.
 *
 * key        -- Buffer holding the metadata key.
 * key_size   -- Size of the key buffer, including the terminating null byte;
 *               key_size - 1 bytes are read.
 * value      -- Buffer holding the metadata value.
 * value_size -- Size of the value buffer, including the terminating null byte;
 *               value_size - 1 bytes are read.
 *
 * Both buffers are read fully before any metadata is changed, so a faulting
 * access leaves the metadata untouched.
 *
 * returns -- 0 if the metadata pair was set successfully, -1 if either buffer
 *            referenced invalid memory that would produce a fault.
 */
static inline int trace_set_metadata(const void *__key, int __key_size,
                                     const void *__value, int __value_size) {
  register int _R_key        asm("a0") = (int) __key;
  register int _R_key_size   asm("a1") =       __key_size;
  register int _R_value      asm("a2") = (int) __value;
  register int _R_value_size asm("a3") =       __value_size;
  register int _R_result     asm("a0");
  _EMU_SYSCALL4(_R_result, _EMUNR_trace_set_metadata,
                _R_key, _R_key_size, _R_value, _R_value_size);
  return _R_result;
}

/* Basic libc like functions -- TODO: Replace all of this with something like a single file libc (for example diet-libc) */ 

static inline void *memcpy(void *destination, const void *source, int num) {
  char *s_t = (char *) source;
  char *d_t = (char *) destination;

  while (num-- > 0) {
    d_t[num] = s_t[num];
  }

  return destination;
}


static inline int memcmp(const void *s1, const void *s2, int n) {
  char *s_t = (char *)s1;
  char *d_t = (char *)s2;

  while (n-- > 0) {
    if (s_t[n] != d_t[n]) 
      return 1;
  }

  return 0;
}


static inline void memset(void *dest, char something, unsigned long times) {
  char *d_t = (char*) dest; 

  while (times-- > 0) {
    d_t[times] = something;
  }
}


static inline int strlen(char *string) {
  int i = 0;
  while (string[i] != '\0') {
    i++;
  }

  return ++i;
}


static inline void iota(int integer, char* output) {
  const char abc[11] = "0123456789";
  char *tmp = output;

  while (integer / 10 != 0) {
    *tmp = abc[integer % 10];
    integer = integer / 10;
    tmp++;
  } 


  *(tmp++) = abc[integer % 10];
  *tmp = '\0'; // ensure string is terminated 

  int n = strlen(output) - 2;
  int begin = 0;

  while (n - begin > 0) {
    char tmp = output[begin];
    output[begin++] = output[n];
    output[n--] = tmp;
  }
}
#endif
