all:
	rgbasm -omain.obj -h main.asm
	rgblink -oden.gb main.obj
	rgbfix -v den.gb
	cp den.gb /media/sf_Share/

palette:
	go build palette.go

clean:
	rm main.obj den.gb palette
