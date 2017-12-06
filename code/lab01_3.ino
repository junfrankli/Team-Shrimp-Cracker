int value;
void setup() {
  // open the serial port at 9600 bps
  Serial.begin(115200);      
}

void loop() {
  int value = 0;
  value = analogRead(A0);
  Serial.println("value = " + value);
}
