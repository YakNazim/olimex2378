
#
# Makefile for libolimex2378 
#

NAME            := libolimex2378
LPCLIBDIR       := ./liblpc23xx
CROSS           ?= /opt/cross

CC              := $(CROSS)/bin/arm-elf-gcc
LD              := $(CROSS)/bin/arm-elf-ld
AR              := $(CROSS)/bin/arm-elf-ar
AS              := $(CROSS)/bin/arm-elf-as
CP              := $(CROSS)/bin/arm-elf-objcopy
OD              := $(CROSS)/bin/arm-elf-objdump

TYPE            ?= lpc23xx

TARGET          ?=

USB_PORT        := -DLPC2378_PORTB

DEBUG           ?=
#DEBUG           = -DDEBUG
 
INCLUDE         := -I$(LPCLIBDIR)/include\
		   -I$(LPCLIBDIR)/lpc23xx-pll/include\
		   -I$(LPCLIBDIR)/lpc23xx-mam/include\
		   -I$(LPCLIBDIR)/lpc23xx-vic/include\
		   -I$(LPCLIBDIR)/lpc23xx-util/include\
		   -I$(LPCLIBDIR)/lpc23xx-uart/include\
                   -I./olimex2378-util/include
	
HS              :=  $(wildcard ./include/*.h)\
                    $(wildcard ./olimex2378-util/include/*.h)

EXLIBS          = ./liblpc23xx/liblpc23xx.a

LIBS            = $(NAME).a

TESTS           = ./olimex2378-util/led-test/led-test.hex\
		  ./olimex2378-i2c/blinkm-test/blinkm-test.hex\
		  ./olimex2378-usb/echo-test/echo-test.hex
		  
TESTSRCS        = $(wildcard olimex2378-*/*test/*c)
TESTOBJS        = $(TESTSRCS:.c=.o)

ASRCS           := $(wildcard olimex2378-*/*.s)

CSRCS           := $(wildcard olimex2378-*/*.c)

COBJS           = $(CSRCS:.c=.o)

AOBJS           = $(ASRCS:.s=.o)
                  
#CFLAGS          = $(INCLUDE) $(DEBUG) $(USB_PORT) -ggdb -c -Wall -Werror -mfloat-abi=softfp -fno-common -O2 -mcpu=arm7tdmi-s
CFLAGS          = $(INCLUDE) $(DEBUG) $(USB_PORT) -ggdb -c -Wall -mfloat-abi=softfp -fno-common -O0 -mcpu=arm7tdmi-s

ARCHIVEFLAGS    = rvs

ASFLAGS         = -ggdb -ahls -mfloat-abi=softfp $(INCLUDE) 
 
.PHONY: clean allclean rebuild

.SUFFIXES : .c .cpp .s

.c.o :
	@echo "======== COMPILING $@ ========================"
	@$(CC) $(CFLAGS) -o $(<:.c=.o) -c $<

.s.o :
	@echo "======== COMPILING $@ ========================"
	@$(AS) $(ASFLAGS) -o $@ $< > $*.lst
        

all: $(LIBS) $(EXLIBS) Makefile

tests: $(TESTS) 

$(COBJS): $(HS)

$(EXLIBS): 
	@echo "========= Recursive make: $(@D)    ========================"
	@$(MAKE) USB_PORT=$(USB_PORT) DEBUG=$(DEBUG) -s -C $(@D) $(@F)

$(LIBS): $(AOBJS) $(COBJS) $(EXLIBS)
	@echo "========= Making Library $@ ========================"
	$(AR) $(ARCHIVEFLAGS) $@ $(AOBJS) $(COBJS)

$(TESTS): $(LIBS) $(ASRCS) $(CSRCS) $(TESTSRCS)
	@echo "========= Recursive make: $(@D) ========================"
	$(MAKE) -s -C $(@D) $(@F)

clean:
	@$(RM)  $(LIBS) $(AOBJS) $(COBJS) $(COBJS) \
	*.map *.hex *.bin *.lst *~ ./include/*~ a.out 
	$(MAKE) -s -C olimex2378-util/led-test clean
	$(MAKE) -s -C olimex2378-i2c/blinkm-test clean

allclean: clean
	@$(MAKE) -s -C liblpc23xx clean
	
rebuild: allclean
	@$(MAKE)

