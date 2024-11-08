CROSS_COMPILE ?= arm-linux-gnueabihf-

all: src/main.s
	$(CROSS_COMPILE)as src/main.s -o obj/main.o
	$(CROSS_COMPILE)objcopy obj/main.o bin/app.bin -O binary
	$(CROSS_COMPILE)objdump -D -b binary -marm bin/app.bin > src/app.lst
	cp bin/app.bin /tftpboot/app.bin



clean:
	rm *.o *.bin *.lst
