all:
	nasm -f elf64 printtf.asm
	gcc -c main.c -o main_c.o
	gcc -static main_c.o printtf.o -o main 
