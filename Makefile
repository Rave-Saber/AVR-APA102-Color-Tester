LED_COUNT = 144
CURRENT_LIMIT = 1250

# ATmegaXX8a DIP
MCU = atmega168
MOSI = PB3
MOSI_DDR = DDRB
MOSI_PORT = PORTB
SS = PB2
SS_DDR = DDRB
SS_PORT = PORTB
SCK = PB5
SCK_DDR = DDRB


F_CPU = 16000000UL
BAUD = 19200UL


PROGRAMMER = usbtiny

LIBDIR = ./lib/AVR-APA102-library/src

CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump
AVRSIZE = avr-size
AVRDUDE = avrdude

TARGET = main

SOURCES=$(wildcard src/*.c $(LIBDIR)/*.c)
OBJECTS=$(SOURCES:.c=.o)
HEADERS=$(SOURCES:.c=.h)

CPPFLAGS  = -DF_CPU=$(F_CPU) -DBAUD=$(BAUD) -I. -I$(LIBDIR)
CPPFLAGS += -DMOSI=$(MOSI) -DMOSI_DDR=$(MOSI_DDR) -DMOSI_PORT=$(MOSI_PORT)
CPPFLAGS += -DSS=$(SS) -DSS_DDR=$(SS_DDR) -DSS_PORT=$(SS_PORT)
CPPFLAGS += -DSCK=$(SCK) -DSCK_DDR=$(SCK_DDR)
CPPFLAGS += -DLED_COUNT=$(LED_COUNT)U

ifdef CURRENT_LIMIT
CURRENT_PER_LED = $$(( $(CURRENT_LIMIT) / $(LED_COUNT) ))
ifeq ($(shell test $(CURRENT_PER_LED) -lt 60; echo $$?), 0)
CPPFLAGS += -DCURRENT_PER_LED=$(CURRENT_PER_LED)UL
endif
endif

CFLAGS  = -Os -g -std=gnu99 -Wall -Wextra
CFLAGS += -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CFLAGS += -ffunction-sections -fdata-sections

LDFLAGS  = -Wl,-Map,$(TARGET).map
LDFLAGS += -Wl,--gc-sections

TARGET_ARCH = -mmcu=$(MCU)


%.o: %.c $(HEADERS) Makefile
	 $(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c -o $@ $<;

$(TARGET).elf: $(OBJECTS)
	$(CC) $(LDFLAGS) $(TARGET_ARCH) $^ $(LDLIBS) -o $@

%.hex: %.elf
	 $(OBJCOPY) -j .text -j .data -O ihex $< $@


.PHONY: all flash clean

all: $(TARGET).hex

flash: $(TARGET).hex
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -U flash:w:$<

clean:
	rm -f *.hex *.elf *.map
	rm -f *.o $(LIBDIR)/*.o
