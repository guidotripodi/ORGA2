all:
	nasm -f elf64 -g -F dwarf -o suma.o suma.asm
	gcc -o miEjecutable -m64 -ggdb main.c  suma.o

clean:
	rm -f *.o
	rm -f miEjecutable

run:
	./miEjecutable
	


