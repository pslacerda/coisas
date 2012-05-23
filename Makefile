all: grav calc

clean:
	rm -f *.o *~ grav calc

%.o: %.asm
	nasm -f elf32 -p macros.i $*.asm -o $*.o

%.dbg: %.o utils.o io.o
	gcc -nostartfiles -g -m32 -o $* *.o

%: %.o utils.o io.o
	ld -m elf_i386 -s -o $* *.o