%.o: %.asm
	nasm -I lib/ -f dbg -g -f elf $< -o $@
%: %.o
	ld -m elf_i386 -e _start $< -o $@

clean:
	rm -f grav calc *~ *.o

#show-lines:	
#	cat `tree -f -i --noreport` | sed s/\	//g | grep -v \; | awk 'NF' |  wc -l

