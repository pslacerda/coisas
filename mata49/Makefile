.PHONY: clean all

all: grav calc

clean:
	rm -f grav calc *~ *.o

%.o: %.asm
	nasm -Ilib/ -g -f elf $< -o $@

%: %.o
	ld -m elf_i386 -e _start $< -o $@

