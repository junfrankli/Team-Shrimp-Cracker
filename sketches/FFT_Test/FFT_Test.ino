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

int threshold = 20;
int treasure_7 = 0;
int treasure_12 = 0;
int treasure_17 = 0;
bool started = false;

void setup() {
  Serial.begin(115200); // use the serial port
//  TIMSK0 = 0; // turn off timer0 for lower jitter
//  ADCSRA = 0xe5; // set the adc to free running mode
//  ADMUX = 0x40; // use adc0
//  DIDR0 = 0x01; // turn off the digital input for adc0
}

void loop() {
  while (1) { // reduces jitter
    cli();  // UDRE interrupt slows this way down on arduino1.0
    for (int i = 0 ; i < 512 ; i += 2) {
      fft_input[i] = analogRead(A3); // <-- NOTE THIS LINE
      fft_input[i + 1] = 0;
    }
    fft_window(); // window the data for better frequency response
    fft_reorder(); // reorder the data before doing the fft
    fft_run(); // process the data in the fft
    fft_mag_log(); // take the output of the fft
    sei(); // turns interrupts back on
    //    if (!started) {
    //      toneDetect();
    //    }
    //    if (started) {
    //      treasureDetect();
    //    }

    Serial.println("start");
    for (byte i = 0 ; i < FFT_N / 2 ; i++) {
      Serial.println(fft_log_out[i]);
    }
    if (treasureDetect() == 1)
      Serial.println("7");
    if (treasureDetect() == 2)
      Serial.println("12");
    if (treasureDetect() == 3)
      Serial.println("17");
    if (treasureDetect() == 0)
      Serial.println("no treasure");
  }
}

int treasureDetect() {
  int max_7_bin = 0;
  for (int i = 45; i < 56; i++) {
    int x = (int) fft_log_out[i];
    if (x > max_7_bin)
      max_7_bin = x;
  }
  int max_12_bin = 0;
  for (int i = 80; i < 90; i++) {
    int x = (int) fft_log_out[i];
    if (x > max_12_bin)
      max_12_bin = x;
  }
  int max_17_bin = 0;
  for (int i = 110; i < 120; i++) {
    int x = (int) fft_log_out[i];
    if (x > max_17_bin)
      max_17_bin = x;
  }
  if (max_17_bin > threshold)
      return 3;
  else if (max_12_bin > threshold)
      return 2;
  else if (max_7_bin > 30)
    return 1;
  else 
    return 0;
}

void toneDetect() {
  bool signal = false;
  for (byte i = 0 ; i < FFT_N / 2 ; i++) {
    if (i == 4) {
      if (fft_log_out[i] > 150) {
        signal = true;
      }
    }
    if (signal) {
      Serial.println("660 Hz Signal Detected\n");
      started = true;
      ADMUX = 0x41;
    }
  }
}
