FASMLIB:= ./fasmlib-0.8.0

compile:
	nasm -f dbg -g -f elf grav.asm -o grav.o

link: compile
	ld -m elf_i386 -e _start grav.o -o grav

link-debug:
	gcc -nostartfiles -m32 *.o  -o grav

build: link
debug: link-debug

clean:
	rm -f grav *~ *.o
