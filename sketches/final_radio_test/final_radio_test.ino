#include <SPI.h>
#include "nRF24L01.h"
#include "RF24.h"

// Radio pins
RF24 radio(4,3);

//
// Topology
//

// Radio pipe addresses for the 2 nodes to communicate.
const uint64_t pipes[2] = { 0x0000000022LL, 0x0000000023LL };

//
// Role management
//
// Set up role.  This sketch uses the same software for all the nodes
// in this system.  Doing so greatly simplifies testing.
//

// The various roles supported by this sketch
typedef enum { role_ping_out = 1, role_pong_back } role_e;

// The debug-friendly names of those roles
const char* role_friendly_name[] = { "invalid", "Ping out", "Pong back"};

// The role of the current running sketch
role_e role = role_ping_out;


void setup() {
  // put your setup code here, to run once:
  //
  // Setup and configure rf radio
  //

  Serial.begin (115200);
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

  //set up for ping out
  radio.openWritingPipe(pipes[0]);
  radio.openReadingPipe(1,pipes[1]);
}

void loop() {
  // put your main code here, to run repeatedly:
  sendMazePacket (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  delay (1000);
  sendMazePacket (0, 1, 0, 0, 0, 0, 0, 0, 0, 0);
  delay (1000);
  sendMazePacket (0, 2, 1, 1, 0, 0, 0, 0, 0, 0);
  delay (1000);
  sendMazePacket (0, 3, 1, 1, 0, 0, 0, 1, 0, 0);
  delay (1000);
  sendMazePacket (0, 4, 1, 1, 0, 0, 1, 0, 0, 0);
  delay (1000);
  sendMazePacket (0, 3, 1, 1, 0, 0, 0, 1, 0, 0);
  delay (1000);
  sendMazePacket (0, 2, 1, 1, 0, 0, 0, 0, 0, 0);
  delay (1000);
  sendMazePacket (0, 1, 0, 0, 0, 0, 0, 0, 0, 0);
  delay (1000);
  sendMazePacket (1, 1, 1, 0, 0, 1, 0, 0, 0, 0);
  delay (1000);
  sendMazePacket (1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  delay (1000);
  sendMazePacket (2, 0, 1, 0, 0, 0, 0, 0, 0, 0);
  delay (1000);
  sendMazePacket (2, 1, 1, 0, 0, 0, 0, 0, 0, 0);
  delay (1000);
  sendMazePacket (2, 2, 1, 1, 0, 0, 0, 0, 0, 0);
  delay (1000);
  sendMazePacket (2, 3, 1, 1, 0, 1, 0, 0, 1, 0);
  delay (1000);
  sendMazePacket (2, 4, 1, 1, 0, 0, 0, 0, 0, 1);
  delay (1000);
}

void sendMazePacket(int x, int y, int rw, int lw, int dw, int uw, int t1, int t2, int t3, int done) {
  int packet = 0;
  packet = packet | (x << 12);
  packet = packet | (y << 8);
  packet = packet | (rw << 7);
  packet = packet | (lw << 6);
  packet = packet | (dw << 5);
  packet = packet | (uw << 4);
  packet = packet | (t1 << 3);
  packet = packet | (t2 << 2);
  packet = packet | (t3 << 1);
  packet = packet | done;

  sendRadioPacket(packet);
}

void sendRadioPacket(int packet) {
  bool ok = radio.write( &packet, sizeof(int));
  Serial.println("attempting to write a packet");
  if (!ok) {
    //failed to send
    Serial.println ("failed");
    sendRadioPacket(packet);
    
  }
  //check for response
  /*radio.startListening();
  unsigned long started_waiting_at = millis();
  bool timeout = false;
  while ( ! radio.available() && ! timeout )
    if (millis() - started_waiting_at > 200 )
      timeout = true;
  if (timeout) {
    //failure
    delay (100); //try again 100 milliseconds later
    Serial.println("timeout");
    //sendRadioPacket(packet);
  }
  radio.stopListening();*/
}

