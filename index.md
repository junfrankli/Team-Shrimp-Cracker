## Meet Shrimpy

Inspired by the delicious snack that holds so much flavor in such a small size, Shrimpy is intended to be a fully autonomous robot capable of traversing and mapping a maze.

# Lab 1: Microcontroller
## Objective
In this lab we learned how to use the Arduino Uno and IDE, taking digital and analog inputs and outputting digital and PWM signals.

##### Equipment
* 1 Arduino Uno
* 1 USB A/B cable
* 1 Continuous rotation servos
* 1 Pushbutton
* 1 LED (any color except IR!)
* 1 Potentiometer
* Several resistors (kΩ range)
* 1 Solderless breadboard

## Communicating between the UNO and IDE

To test out the capabilities of the Arduino IDE, we first used the example blink program in the IDE to have the built-in LED in the Uno flash. 
```C++
void setup() {
    pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  digitalWrite(LED_BUILTIN, HIGH);
  delay(1000);                       
  digitalWrite(LED_BUILTIN, LOW);    
  delay(1000);                       
}
```
After the code was verified and uploaded to the Uno, the built-in LED on the UNO [started to blink]( https://gfycat.com/gifs/detail/DistantBraveBoa).

## Modifying the Blink Sketch

Next, we modified the sketch to blink an external LED connected to digital pin 9 on the UNO. The code was as follows:
```C++
void setup() {
    pinMode(9, OUTPUT);
}

void loop() {
  digitalWrite(9, HIGH);
  delay(1000);                       
  digitalWrite(9, LOW);    
  delay(1000);                       
}
```
We added a resistor to lower the current to the LED, as shown in the following image. 

![External LED](http://i.imgur.com/Rn8bvosl.jpg)

The LED blinked on and off, just as the built in LED did in the previous exercise.


## Using the Serial Monitor and Analog Pins
For this section we hooked up a potentiometer to one of the Arduino’s analog pins. The pot is a variable resistor, and is used in a voltage divider circuit to provide an output to the pin of between 0V and 5V, depending on its position. Refer to below circuit diagram for how we hooked up our circuit:

Image here

To output the measured values, we used the Serial library and the Arduino IDE’s serial monitor tool.

Here is the code that we used:

```Java
int value;
void setup() {
  Serial.begin(115200);      // open the serial port at 9600 bps:
}
void loop() {
  int value = 0;
  value = analogRead(A0);
  Serial.println("value = " + value);
}
```
<<<<<<< HEAD

When run, here’s what happens:

![analog led](https://thumbs.gfycat.com/NegligibleTerrificGreatdane-size_restricted.gif)

## Using the Arduino for Analog Output
To output an analog signal from the Arduino, we chose a digital pin with pulse-width modulation capability. We connected this pin to the LED in series with a resistor. The circuits below show the LED and potentiometer connected to the arduino, as well as the different levels of brightness of the LED. 

![LED circuit bright](https://lh5.googleusercontent.com/uM9ousc9k4QJiiv_gJrv8T3vyIZ0GfSbJWPJKhlUwz_eDroz0HSwYybYh3lJyI7LastCj2flsHdAPE0=w1461-h780-rw)

![LED circuit dull](https://lh3.googleusercontent.com/P1nK3a2EbWKHF2inhzWCfaQKRZ8QOYhjWPQcrUMfUrO1xD5d2mpOKpdGqRplFBuvsB7h7lQ_REUZa4w=w1461-h780-rw)

We added to our code from the previous section in order to use the potentiometer to adjust the LED brightness. We added a map function that would map the input range (0-1023 for the analog pin) to the correct output range (0-255 for the digital pin). We then used the analogWrite function to write the output value to the digital pin we had chosen. The following oscilloscope graph shows the frequency of the signal and its response to changing analog values. 

![Oscilloscope Graph](https://lh4.googleusercontent.com/rekdfs0oZ9bL4B-i_qlq74YDtRA386FyAla_KB0mnrXJKZ2kd0JqdcpBK2qXs-wir4arPKS9l4QFVVg=w1461-h780-rw)

## Applying the Parallax Servos
One of the most important functions for a robot to discover the maze is the ability to "walk". Here, we used Parallax Continuous Rotation Servos. The white wire was connected to the digital pin "~11" with PWM capability. The red wire was connected to 5V output pin and the black wire was connected to ground "GND". The oscilloscope was attached to check the frequency and maximum/minimum duty cycle. The code is listed below.

```C++
#include <Servo.h>
Servo yep;
void setup() {
}

void loop() {
    yep.attach(11);
    yep.write(0);   // yep.write(X), the integer X here can be 0 to 180. If X is 90, the servo will stop. If X is 0 or 180, it will rotate at full speed but in different directions for 0 and 180.
}
```

When ran, the oscilloscope looked like:

![Oscilloscope Graph 2](https://lh3.googleusercontent.com/UDT-QtnvwE1fglqu8VlNuDFOKSz1WUDftiVrREEFQynHzGH5WQzO9Fd6xLVxXawEv_T4QNFDmtmnt_g=w1461-h780-rw)

When the servo ran at full speed as X for yep.write(X) was 0, the duty cycle was 0.5/20=0.025. When the servo stopped as X was 180, the duty cycle was 1.5/20=0.075.

The potentiometer was then connected to the servo running with the same code above.

## Let the Robot Run!
Finally, we assembled the robot as shown below:

![Assembled Robot 1](https://i.imgur.com/vlPUDgf.jpg)

![Assembled Robot 2](http://i.imgur.com/z1QnSDW.jpg)

To let the robot drive in a square, the code was listed below:

```C++
#include <Servo.h>

Servo servoLeft;
Servo servoRight;

void setup() { 
  servoLeft.attach(11);
  servoRight.attach(10);
} 

void loop() {            // Loop through motion tests
 moveForward();
 delay(1000);
 turnRight();
}

// Motion routines for forward, reverse, turns, and stop
void moveForward() {
  servoLeft.write(180);
  servoRight.write(0);
}

void moveBackwards() {
  servoLeft.write(0);
  servoRight.write(180);
}

void turnLeft() {
  servoLeft.write(180);
  servoRight.write(180);
  delay(274);
}
void turnRight() {
  servoLeft.write(0);
  servoRight.write(0);
  delay(274);
}

void brake() {
  servoLeft.write(90);
  servoRight.write(90);
}
```

The robot ran as shown below:

![Running Robot in Square](https://thumbs.gfycat.com/BlandRashElk-size_restricted.gif)


### Team Contract
Here is the [team contract](https://docs.google.com/a/cornell.edu/document/d/185qE_biNOK_HIIYWK4v1OBuVsC2TEDHkQdZEg_0X8gM/edit?usp=sharing) that lists the goals and policies of the team.