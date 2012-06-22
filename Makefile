
build: link

compile:
	nasm -f dbg -g -f elf grav.asm -o grav.o

link: compile
	ld -m elf_i386 -e _start grav.o -o grav

clean:
	rm -f grav *~ *.o

show-lines:	
	cat * | sed s/\	//g | grep -v \; | awk 'NF' |  wc -l

