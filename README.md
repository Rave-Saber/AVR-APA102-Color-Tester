# RaveSaber - AVR APA102C Color Test

[![Build Status](https://travis-ci.org/Rave-Saber/AVR-APA102-Color-Tester.svg?branch=master)](https://travis-ci.org/Rave-Saber/AVR-APA102-Color-Tester)

A simple AVR firmware & cli application to test colors of an APA102 strip via
a serial connection.

This was tested using an ATmega168a AVR microcontroller running at 16Mhz with
both a Sparkfun Lumentai 8-LED strip & Adafruit DotStar 144/m strip. The data
pin is hooked up to PB3(MOSI) & the clock pin is hooked up to PB5(SCK). The
serial connection uses a USB-FTDI cable. The chip is programmed with a
USBtinyISP.

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


## TODO

* Fix bug in TUI app where scrolling with the mouse wheel causes an incomplete
  serial data transmission. Quick fix is to reset the AVR device.
* GTK app with features like a color wheel, & adding colors to a favorites
  list.
* Pattern testing
    * app sends pattern type, color sequence, & timing info via serial
    * firmware decodes serial data then allocates and plays the given pattern


## License

GPL-3.0
