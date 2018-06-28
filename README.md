# RaveSaber - AVR APA102C Color Test

A simple AVR firmware & cli application to test colors of an APA102 strip via
a serial connection.

This was tested using an ATmega168a AVR microcontroller with a Sparkfun
Lumentai 8-LED strip. The data pin is hooked up to PB3(MOSI) & the clock pin is
hooked up to PB5(SCK). The serial connection uses a USB-FTDI cable. The chip is
programmed with a USBtinyISP.

To flash your chip, simply run `make flash`.

Then open a serial session with`screen /dev/ttyUSB0` and type in the digits of
the hex code you want to test.

You can also use the CLI/TUI app to select RGB values. You need Haskell stack
installed(`pacman -S stack`). Then you can build & run the app:

    cd ui/
    stack build
    stack exec color-test -- /dev/ttyUSB0

With the app running, you can press the arrow keys to scroll through the
numbers, the Enter key to switch between the Red, Green, & Blue inputs, and the
`q` key to quit.


## License

GPL-3.0
