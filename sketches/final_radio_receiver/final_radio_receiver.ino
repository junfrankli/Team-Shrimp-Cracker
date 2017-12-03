#include <SPI.h>
#include "nRF24L01.h"
#include "RF24.h"

int x0 = 0;
int x1 = 1;
int y0 = 2;
int y1 = 3;
int y2 = 4;
int rw = 5;
int lw = 6;
int dw = 7;
int uw = 8;
int t1 = A4;
int t2 = A3;
int t3 = A2;
int done = A1;
int valid = A0; 


//set up radio on 9 and 10
RF24 radio(9,10);

// Topology

// Radio pipe addresses for the 2 nodes to communicate.
const uint64_t pipes[2] = { 0x0000000022LL, 0x0000000023LL };

typedef enum { role_ping_out = 1, role_pong_back } role_e;

// The debug-friendly names of those roles
const char* role_friendly_name[] = { "invalid", "Ping out", "Pong back"};

// The role of the current running sketch
role_e role = role_pong_back;

void setup() {
  //packet setup
  pinMode(x0,OUTPUT);
  pinMode(x1,OUTPUT);
  pinMode(y0,OUTPUT);
  pinMode(y1,OUTPUT);
  pinMode(y2,OUTPUT);
  pinMode(rw,OUTPUT);
  pinMode(lw,OUTPUT);
  pinMode(dw,OUTPUT);
  pinMode(uw,OUTPUT);
  pinMode(t1,OUTPUT);
  pinMode(t2,OUTPUT);
  pinMode(t3,OUTPUT);
  pinMode(done,OUTPUT);
  pinMode(valid,OUTPUT);


  Serial.begin(115200);
   //
  // Setup and configure rf radio
  //

  radio.begin();

  // optionally, increase the delay between retries & # of retries
  radio.setRetries(15,15);
  radio.setAutoAck(true);
  // set the channel
  radio.setChannel(0x50);
  // set the power
  // RF24_PA_MIN=-18dBm, RF24_PA_LOW=-12dBm, RF24_PA_MED=-6dBM, and RF24_PA_HIGH=0dBm.
  radio.setPALevel(RF24_PA_MIN);
  //RF24_250KBPS for 250kbs, RF24_1MBPS for 1Mbps, or RF24_2MBPS for 2Mbps
  radio.setDataRate(RF24_250KBPS);

  //role is role_pong_back
  radio.openWritingPipe(pipes[1]);
  radio.openReadingPipe(1, pipes[0]);

  radio.startListening();
}

void loop() {
  // if there is data ready
    if ( radio.available() ) {
      // Dump the payloads until we've gotten everything
      int packet;
      bool done = false;
      while (!done)
      {
        // Fetch the payload, and see if this was the last one.
        done = radio.read( &packet, sizeof(int) );

        // Spew it
        //printf("Got payload %lu...",got_time);

        // Delay just a little bit to let the other unit
        // make the transition to receiver
        //delay(20);
      }

      // First, stop listening so we can send packet
      radio.stopListening();

      // Send the final one back.
        radio.write( &packet, sizeof(int) );
      //printf("Sent response.\n\r");

      sendPacket(packet);
      
      // Now, resume listening so we catch the next packets.
      radio.startListening();
    } 
}

void sendPacket(int packet) {
  int x;
  int y;
  int rw;
  int lw;
  int dw;
  int uw;
  int t1;
  int t2;
  int t3;
  int done;

  x = (packet & (3 << 12)) >> 12;
  y = (packet & (7 << 8)) >> 8;
  rw = (packet & (1 << 7)) >> 7;
  lw = (packet & (1 << 6)) >> 6;
  dw = (packet & (1 << 5)) >> 5;
  uw = (packet & (1 << 4)) >> 4;
  t1 = (packet & (1 << 3)) >> 3;
  t2 = (packet & (1 << 2)) >> 2;
  t3 = (packet & (1 << 1)) >> 1;
  done = packet & 1;

  setPins(x, y, rw, lw, dw, uw, t1, t2, t3, done);
}

void setPins(int x, int y, int rwp, int lwp, int dwp, int uwp, int t1p, int t2p, int t3p, int donep) {
  Serial.print("x ");
  Serial.print(x);
  Serial.print(" y ");
  Serial.print(y);
  Serial.print(" rw ");
  Serial.print(rwp);
  Serial.print(" lw ");
  Serial.print(lwp);
  Serial.print(" dw ");
  Serial.print(dwp);
  Serial.print(" uw ");
  Serial.print(uwp);
  Serial.print(" t1 ");
  Serial.print(t1p);
  Serial.print(" t2 ");
  Serial.print(t2p);
  Serial.print(" t3 ");
  Serial.print(t3p);
  Serial.print(" done ");
  Serial.println(donep);
  if (x == 0) {
    digitalWrite(x0, LOW);
    digitalWrite(x1, LOW);
  } else if (x == 1) {
    digitalWrite(x0, HIGH);
    digitalWrite(x1, LOW);
  } else if (x == 2) {
    digitalWrite(x0, LOW);
    digitalWrite(x1, HIGH);
  } else if (x == 3) {
    digitalWrite(x0, HIGH);
    digitalWrite(x1, HIGH);
  }

  if (y == 0) {
    digitalWrite(y2, LOW);
    digitalWrite(y1, LOW);
    digitalWrite(y0, LOW);
  } else if (y == 1) {
    digitalWrite(y2, LOW);
    digitalWrite(y1, LOW);
    digitalWrite(y0, HIGH);
  } else if (y == 2) {
    digitalWrite(y2, LOW);
    digitalWrite(y1, HIGH);
    digitalWrite(y0, LOW);
  } else if (y == 3) {
    digitalWrite(y2, LOW);
    digitalWrite(y1, HIGH);
    digitalWrite(y0, HIGH);
  } else if (y == 4) {
    digitalWrite(y2, HIGH);
    digitalWrite(y1, LOW);
    digitalWrite(y0, LOW);
  }

  if (rwp)
    digitalWrite(rwp, HIGH);
  else
    digitalWrite(rwp, LOW);
  
  if (lwp)
    digitalWrite(lwp, HIGH);
  else
    digitalWrite(lwp, LOW);

  if (dwp)
    digitalWrite(dwp, HIGH);
  else
    digitalWrite(dwp, LOW);

  if (uwp)
    digitalWrite(uwp, HIGH);
  else
    digitalWrite(uwp, LOW);

  if (t1p)
   digitalWrite(t1p, HIGH);
  else
    digitalWrite(t1p, LOW);

  if (t2p)
    digitalWrite(t2p, HIGH);
  else
    digitalWrite(t2p, LOW);

  if (t3p)
    digitalWrite(t3p, HIGH);
  else
    digitalWrite(t3p, LOW);

  if (donep)
    digitalWrite(done, HIGH);
  else
    digitalWrite(done, LOW);
    
  digitalWrite(valid, HIGH);
  delay(1000);
  digitalWrite(valid, LOW);
}

