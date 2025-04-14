#include <stdio.h>
#include <unistd.h>

#include <wiringx.h>

int main() {
    // Duo/Duo256M: LED = 25
    // DuoS:        LED =  0
#if BOARD_DUO || BOARD_DUO256M
    int DUO_LED = 25;
#elif BOARD_DUOS
    int DUO_LED = 0;
#else
#error "No board definition found!"
#endif

    // Duo:     milkv_duo
    // Duo256M: milkv_duo256m
    // DuoS:    milkv_duos
    if(wiringXSetup(BOARD_NAME, NULL) == -1) {
        wiringXGC();
        return 1;
    }

    if(wiringXValidGPIO(DUO_LED) != 0) {
        printf("Invalid GPIO %d\n", DUO_LED);
    }

    pinMode(DUO_LED, PINMODE_OUTPUT);

    // ReSharper disable once CppDFAEndlessLoop
    while(1) {
        printf("Duo LED GPIO (wiringX) %d: High\n", DUO_LED);
        digitalWrite(DUO_LED, HIGH);
        sleep(1);
        printf("Duo LED GPIO (wiringX) %d: Low\n", DUO_LED);
        digitalWrite(DUO_LED, LOW);
        sleep(1);
    }

    return 0;
}