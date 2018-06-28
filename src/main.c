#include <avr/io.h>
#include <util/setbaud.h>
#include <stdbool.h>
#include <apa102.h>
#include <apa102_effects.h>


static inline void initUSART(void);
static void transmitByte(uint8_t data);
static uint8_t receiveByte(void);
static void printString(const char *stringData);


int main(void) {
    initUSART();
    apa102_init_spi();

    printString("\r\n\r\n===RaveSaber Color Test ===\r\n");
    printString("Enter a Hex Color to test(e.g., FFFFFF):\r\n");
    while (1) {
        uint8_t hex_count = 0;
        uint32_t color = 0;
        while (hex_count < 6) {
            uint8_t hex_code = receiveByte();
            bool valid_code = (hex_code >= '0' && hex_code <= '9')
                || (hex_code >= 'a' && hex_code <= 'f');
            if (valid_code) {
                transmitByte(hex_code);
                uint8_t input_number = 0;
                if (hex_code >= '0' && hex_code <= '9') {
                    input_number = hex_code - '0';
                } else {
                    input_number = 10 + (hex_code - 'a');
                }
                color = (color << 4) | input_number;
                hex_count++;
            }
        }
        printString("\r\n");
        apa102_set_all(rgb(color));
    }
    return 0;
}


// Initialize USART Peripherals
static inline void initUSART(void) {
    // set baud rate
    UBRR0H = UBRRH_VALUE;
    UBRR0L = UBRRL_VALUE;
#if USE_2X
    UCSR0A |= 1 <<  U2X0;
#else
    UCSR0A &= ~(1 << U2X0);
#endif
    // enable rx & tx
    UCSR0B |= (1 << RXEN0) | (1 << TXEN0);
    // set 8 data bits
    UCSR0C |= (1 << UCSZ01) | (1 << UCSZ00);
}

// Transmit a single byte over USART
static void transmitByte(uint8_t data) {
    loop_until_bit_is_set(UCSR0A, UDRE0);
    UDR0 = data;
}

// Receive a single byte from the USART connection
static uint8_t receiveByte(void) {
    loop_until_bit_is_set(UCSR0A, RXC0);
    return UDR0;
}

// Print a string over the USART connection
static void printString(const char stringData[]) {
    uint8_t i = 0;
    while (stringData[i]) {
        transmitByte(stringData[i]);
        i++;
    }
}
