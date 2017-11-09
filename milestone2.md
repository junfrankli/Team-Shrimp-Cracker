# Milestone 2
## Objective
The purpose of this milestone was to add spice to the life of our robot with wall detection and differentiation between the three treasures.

## Wall Detection
We need short range IR sensor SHARP 0A41SK to detect the distance between the sensor and the object.

Code to measure the distance between the wall and the robot:
```C++
int dis=0;

void setup() {
  Serial.begin(9600);
}

void loop() {
  float SensorValue = analogRead(A0); // Read sensor value for analog pin A0
  float dis = 2076/(SensorValue - 11); // SensorValue to Distance conversion from https://www.dfrobot.com/wiki/index.php/SHARP_GP2Y0A41SK0F_IR_ranger_sensor_(4-30cm)_SKU:SEN0143
  if (dis<4 || dis>30)
  {
    Serial.print( "Out of Range.\n");
  }
  else
  {
    Serial.print(dis);
    Serial.print(" cm\n");
  }
  delay(500);
}
```

The IR sensor performance can be analyzed from the video:

[![wall detection](https://i.imgur.com/ovFlDHc.png)](https://youtu.be/L2GjUC7tSxU)

To detect the wall, we can change the code to the following:
```C++
int dis=0;

void setup() {
  Serial.begin(9600);
}

void loop() {
  float SensorValue = analogRead(A0); // Read sensor value for analog pin A0
  float dis = 2076/(SensorValue - 11); // SensorValue to Distance conversion from https://www.dfrobot.com/wiki/index.php/SHARP_GP2Y0A41SK0F_IR_ranger_sensor_(4-30cm)_SKU:SEN0143
  if (dis < 15 && dis > 13)
  {
    //do turning
    delay(1000);
  }
  delay(500);
}
```
Therefore, when the distance between the sensor on the robot and the wall falls into 13 to 15 cm range, the robot will turn left or right to avoid the wall and the distance measurments will delay longer to finish the turning.

## Treasure Detection
In order to differentiate between the three frequencies of treasures, we needed to modify our FFT code from Lab 2 for optical detection. As a unit test, we first checked to see which bins corresponded to the different treasure frequencies. 

![FFT Output Graph](https://i.imgur.com/SHQroh1.png)

Since our analog circuitry was still in progress, we had to rely on just our software to differentiate between the frequencies for this milestone. We were then faced with the problem of how to make our software sensitive enough to detect the treasure farther away, but also able to differentiate between the three frequencies of treasure. This resulted from harmonics in the FFT - when a treasure of one frequency triggered the sensor, there would also be a spike in the relevant bins of other frequencies. 

We solved this problem by comparing the relevant bins and determining which frequency had the highest magnitude. If the maximum magnitude was greater than the threshold, we reported that the treasure was detected.

Here is our code for determining which frequency treasure the sensor detected:

```C++
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
        treasure_17++; //Detected 17kHz treasure
} else if (max_12_bin > max_7_bin) {
    if (max_12_bin > threshold)  
        treasure_12++; //Detected 12kHz treasure
} else {
    if (max_7_bin > threshold)
        treasure_7++; //Detected 7kHz treasure
}
```

This video shows detection of a single treasure, moving it in and out of range of our sensor:
[![Single treasure detection](https://i.imgur.com/a8mRE3X.png)](
https://drive.google.com/file/d/0BwOxbk7b-QdoUFhZLXRjNUlVYlU/view)

We found, however, that using this method sometimes resulted in false detection of treasure. Our software was extremely sensitive and could not filter out noise. The program also misidentified some of the frequencies. To solve both of these problems, we decided to add time integration.

We checked to see whether treasure of the same frequency had been detected for several iterations. Only when our robot had detected the treasure for more iterations than our cycle threshold did it report a treasure being detected. We found that adding the cycle threshold enabled our robot to filter out noise as well as correctly identify the frequency of treasure each time.

Here is our code for time integration (Note: We did not reset the counters if the treasure of a particular frequency was not detected that iteration. We chose not to do this to keep the number of instructions low. We thought this was an acceptable trade off as our code worked correctly even without this reset): 

```C
if (treasure_7 > time_threshold) {
    Serial.write("7 kHz treasure!\n"); //Report treasure detection 
    treasure_7 = 0; //Reset relevant counter
}
else if (treasure_12 > time_threshold) {
    Serial.write ("12 kHz treasure!\n");
    treasure_12 = 0;
}
else if (treasure_17 > time_threshold) {
    Serial.write ("17 kHz treasure!\n");
    treasure_17 = 0;
}
```

The following video shows our code recognizing the correct treasure frequencies.
[![Single treasure detection](https://i.imgur.com/9MbMQJD.png)](
https://drive.google.com/file/d/0BwOxbk7b-QdoeDhjaDNwNkFNQVU/view)


### Looking Ahead
For our final robot, we plan to modify our treasure detection based on our final analog circuitry. We plan to add an op-amp as well as band pass filtering in order to amplify the output of the sensor and filter out noise. As a result, we will not have to make our software as sensitive, and we will be able to make it much more efficient.
