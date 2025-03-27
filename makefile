all:
	@echo "Usage - build run ...."

run:
	qemu-system-i386 -hda image.bin

debug: 
	qemu-system-i386 -hda image.bin -S -s

build: clean
	@nasm -f bin loader.asm 
	@nasm -f bin payload.asm
	@gcc -o builder.exe builder.c
	@./builder.exe

gdb:
	gdb -ex "target remote localhost:1234"\
		-ex "set arch i8086"\
		-ex "set disassembly-flavor intel"\
		-ex "b *0x7c00"\
		-ex "b *0x7c85"\
		-ex "c"
		

clean:
	@rm -vf payload loader builder.exe image.bin *.out
