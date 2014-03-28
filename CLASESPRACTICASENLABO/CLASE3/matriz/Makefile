make:
	nasm -f elf64 -g -F dwarf matriz.asm -o matriz.o
	gcc -ggdb -o matriz matriz.c matriz.o

clean:
	rm matriz matriz.o
