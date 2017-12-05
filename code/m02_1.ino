int dis=0;

void setup() {
  Serial.begin(9600);
}

void loop() {
  float SensorValue = analogRead(A0); // Read sensor value for analog pin A0
  float dis = 2076/(SensorValue - 11); // SensorValue to Distance conversion from 
  // https://www.dfrobot.com/wiki/index.php/SHARP_GP2Y0A41SK0F_IR_ranger_sensor_(4-30cm)_SKU:SEN0143
  if (dis < 15 && dis > 13)
  {
    // do turning
    delay(1000);
  }
  delay(500);
}
