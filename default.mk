PREFIX=arm-none-eabi-

ifeq ($(strip $(S_SOURCES)),)
	S_SOURCES = $(wildcard *.S) ../vectortable.S ../startup.S
endif


S_OBJECTS	= $(foreach file,$(S_SOURCES),$(basename $(file)).o)


ifneq ($(strip $(LDCMD)),)
program.elf : $(S_OBJECTS)
	$(PREFIX)ld -g -o $@ $(S_OBJECTS) $(LDCMD)
else
	ifeq ($(strip $(LDSCRIPT)),)
		LDSCRIPT = ../stm32f103rb.ld
	endif

program.elf : $(S_OBJECTS) $(LDSCRIPT)
	$(PREFIX)ld -g -o $@ $(S_OBJECTS) -T $(LDSCRIPT)

endif

$(S_OBJECTS) : %.o : %.S ../stm32f103.inc
	$(PREFIX)as -g -o $@ $< -I..

.PHONY : gdbsrv program gdb clean

gdbsrv :
	openocd -f interface/stlink-v2.cfg -f target/stm32f1x.cfg

program : program.elf
	openocd -f interface/stlink-v2.cfg -f target/stm32f1x.cfg -c "program $< verify reset exit"

gdb : program.elf
	$(PREFIX)gdb $^

clean :
	rm -f program.elf $(S_OBJECTS)
