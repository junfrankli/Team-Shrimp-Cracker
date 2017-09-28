/*
fft_adc.pde
guest openmusiclabs.com 8.18.12
example sketch for testing the fft library.
it takes in data on ADC0 (Analog0) and processes them
with the fft. the data is sent out over the serial
port at 115.2kb.  there is a pure data patch for
visualizing the data.
*/

#define LOG_OUT 1 // use the log output function
#define FFT_N 256 // set to 256 point fft

#include <FFT.h> // include the library

int threshold = 40; 
int time_threshold = 10;
int treasure_7 = 0;
int treasure_12 = 0;
int treasure_17 = 0;
bool started = false;

void setup() {
  Serial.begin(115200); // use the serial port
  TIMSK0 = 0; // turn off timer0 for lower jitter
  ADCSRA = 0xe5; // set the adc to free running mode
  ADMUX = 0x40; // use adc0
  DIDR0 = 0x01; // turn off the digital input for adc0
}

void loop() {
  while(1) { // reduces jitter
    cli();  // UDRE interrupt slows this way down on arduino1.0
    for (int i = 0 ; i < 512 ; i += 2) { // save 256 samples
      while(!(ADCSRA & 0x10)); // wait for adc to be ready
      ADCSRA = 0xf5; // restart adc
      byte m = ADCL; // fetch adc data
      byte j = ADCH;
      int k = (j << 8) | m; // form into an int
      k -= 0x0200; // form into a signed int
      k <<= 6; // form into a 16b signed int
      fft_input[i] = k; // put real data into even bins
      fft_input[i+1] = 0; // set odd bins to 0
    }
    fft_window(); // window the data for better frequency response
    fft_reorder(); // reorder the data before doing the fft
    fft_run(); // process the data in the fft
    fft_mag_log(); // take the output of the fft
    sei(); // turns interrupts back on
    if (!started) {
      toneDetect();
    }
    if (started) {
      treasureDetect();
    }
  }
}

void treasureDetect() {
  int max_7_bin = 0;
    for (int i = 46; i < 50; i++) {
      int x = (int) fft_log_out[i];
      if (x > max_7_bin)
        max_7_bin = x;
    }
    int max_12_bin = 0;
    for (int i = 80; i < 83; i++) {
      int x = (int) fft_log_out[i];
      if(x > max_12_bin) 
        max_12_bin = x;
    }
    int max_17_bin = 0;
    for (int i = 113; i < 116; i++) {
      int x = (int) fft_log_out[i];
      if (x > max_17_bin)
        max_17_bin = x;
    }
    if (max_17_bin > max_12_bin && max_17_bin > max_7_bin) {
      if (max_17_bin > threshold) 
       treasure_17++;
    }
    else if (max_12_bin > max_7_bin) {
      if (max_12_bin > threshold)  
       treasure_12++;
    }
    else 
      if (max_7_bin > threshold)
        treasure_7++;
    if (treasure_7 > time_threshold) {
      Serial.write("7 kHz treasure!\n");
      treasure_7 = 0;
    }
    else if (treasure_12 > time_threshold) {
      Serial.write ("12 kHz treasure!\n");
      treasure_12 = 0;
    }
    else if (treasure_17 > time_threshold) {
      Serial.write ("17 kHz treasure!\n");
      treasure_17 = 0;
    }
}

void toneDetect() {
  bool signal = false;
    for (byte i = 0 ; i < FFT_N/2 ; i++) { 
      if (i==4) {
        if (fft_log_out[i] > 150) {
          signal = true;
        }
      } 
      if (signal) {
        Serial.println("660 Hz Signal Detected\n");
        started = true;
      }
    }
}
