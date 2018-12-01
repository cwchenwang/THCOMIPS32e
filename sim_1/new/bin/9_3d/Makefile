ifndef CROSS_COMPILE
CROSS_COMPILE = mips-mti-elf-
endif
CC = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

OBJECTS = inst_rom.o

export	CROSS_COMPILE

# ********************
# Rules of Compilation
# ********************

all: inst_rom_el.bin inst_rom_eb_rev.bin inst_rom_el.asm inst_rom_eb.asm

inst_rom_el.o: inst_rom.S
	$(CC) -mips32 -EL $< -o $@
inst_rom_eb.o: inst_rom.S
	$(CC) -mips32 -EB $< -o $@
inst_rom_el.elf: ram.ld inst_rom_el.o
	$(LD) -EL -T ram.ld inst_rom_el.o -o $@
inst_rom_eb.elf: ram.ld inst_rom_eb.o
	$(LD) -EB -T ram.ld inst_rom_eb.o -o $@
inst_rom_el.bin: inst_rom_el.elf 
	$(OBJCOPY) -O binary $< $@
inst_rom_eb_rev.bin: inst_rom_eb.elf
	$(OBJCOPY) -O binary --reverse-bytes=4 $< $@
%.asm: %.elf
	$(OBJDUMP) -D $< > $@
clean:
	rm -f *.o *.om *.bin *.data *.mif *.asm *.elf
