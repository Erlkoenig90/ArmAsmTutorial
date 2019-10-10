PREFIX=arm-none-eabi-

# List your assembly source files here. Default: Find all .S files in directory
S_SOURCES = $(wildcard *.S)
# Name of the final program file
EXENAME = program

# Flags to pass to the assembler
ASFLAGS = -g
# Flags to pass to the linker
LDFLAGS = -g
# Name of the linker script
LDSCRIPT = stm32f103rb.ld

S_OBJECTS	= $(foreach file,$(S_SOURCES),$(basename $(file)).o)

all : $(EXENAME).elf $(EXENAME).hex $(EXENAME).bin

$(EXENAME).elf : $(S_OBJECTS) $(LDSCRIPT)
	$(PREFIX)ld $(LDFLAGS) -o $@ $(S_OBJECTS) -T $(LDSCRIPT)

$(EXENAME).hex : $(EXENAME).elf
	$(PREFIX)objcopy -O ihex $< $@

$(EXENAME).bin : $(EXENAME).elf
	$(PREFIX)objcopy -O binary $< $@

$(S_OBJECTS) : %.o : %.S stm32f103.inc
	$(PREFIX)as $(ASFLAGS) -o $@ $<

.PHONY : gdbsrv program gdb clean

gdbsrv :
	openocd -f interface/stlink-v2.cfg -f target/stm32f1x.cfg

program : $(EXENAME).elf
	openocd -f interface/stlink-v2.cfg -f target/stm32f1x.cfg -c "program $< verify reset exit"

gdb : $(EXENAME).elf
	$(PREFIX)gdb $^

clean :
	rm -f $(EXENAME).elf $(EXENAME).hex $(EXENAME).bin $(S_OBJECTS)
