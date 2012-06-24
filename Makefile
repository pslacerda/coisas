
compile:
	nasm -I lib/ -f dbg -g -f elf grav.asm -o grav.o

link: compile
	ld -m elf_i386 -e _start grav.o -o grav

build: link

clean:
	rm -f grav calc *~ *.o

show-lines:	
	cat * | sed s/\	//g | grep -v \; | awk 'NF' |  wc -l

