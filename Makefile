all: weather.gb transparency.gb scanlines.gb den.gb lapras.gb palette still colors

weather.gb: weather/main.obj
	rgblink -o$@ $?
	rgbfix -v $@

weather/main.obj: weather/main.asm
	rgbasm -h -iinclude/ -o$@ $?

weather/main.asm: include/pallet-town.2bpp

include/pallet-town.2bpp: include/pallet-town.png
	rgbgfx -T -u -o $@ $?

transparency.gb: transparency/main.obj
	rgblink -o$@ transparency/main.obj
	rgbfix -v $@

transparency/main.obj: transparency/main.asm transparency/lyra.2bpp transparency/pallet.2bpp transparency/text.2bpp
	rgbasm -otransparency/main.obj -h transparency/main.asm

transparency/lyra.2bpp: transparency/lyra.png
	rgbgfx -o transparency/lyra.2bpp transparency/lyra.png

transparency/pallet.2bpp: transparency/pallet.png
	rgbgfx -T -u -o transparency/pallet.2bpp transparency/pallet.png

transparency/text.2bpp: transparency/text.png
	rgbgfx -T -u -o transparency/text.2bpp transparency/text.png

scanlines.gb: scanlines/main.obj
	rgblink -o$@ scanlines/main.obj
	rgbfix -v $@

scanlines/main.obj: scanlines/main.asm
	rgbasm -oscanlines/main.obj -h scanlines/main.asm

den.gb: dragons-den/main.obj
	rgblink -o$@ dragons-den/main.obj
	rgbfix -v $@

dragons-den/main.obj: dragons-den/main.asm
	rgbasm -odragons-den/main.obj -h dragons-den/main.asm

lapras.gb: lapras/main.obj
	rgblink -o$@ lapras/main.obj
	rgbfix -v $@

lapras/main.obj: lapras/main.asm lapras/map.asm lapras/palette.asm lapras/header.inc lapras/lapras.2bpp
	rgbasm -ilapras/ -olapras/main.obj -h lapras/main.asm

lapras/lapras.2bpp: lapras/lapras.png
	rgbgfx -o lapras/lapras.2bpp lapras/lapras.png

colors: tools/colors.go
	go build tools/colors.go

palette: tools/palette.go
	go build tools/palette.go

still: tools/still.go
	go build tools/still.go

clean:
	rm dragons-den/main.obj den.gb lapras/main.obj lapras.gb scanlines/main.obj scanlines.gb colors palette still
