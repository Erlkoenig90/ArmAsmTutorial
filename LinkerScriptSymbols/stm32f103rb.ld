MEMORY {
	FLASH	: ORIGIN = 0x8000000,	LENGTH = 128K
	SRAM	: ORIGIN = 0x20000000,	LENGTH = 20K
}

SECTIONS {
	.text : {
		*(.text)
	} >FLASH
	
	.data (NOLOAD) : {
		. = . + 0x400;
		_StackEnd = .;
		*(.data)
	} >SRAM
}

