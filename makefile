FELFING=nasm -felf64 -o
LDING=ld -o
TESTING=python

%.o: %.asm
	$(FELFING) $@ $<
main: main.o dict.o lib.o
	$(LDING) $@ $^


clean:
	rm *.o

test:
	$(TESTING) test.py

compile:
	make main
	make clean

laba:
	make compile
	make test

