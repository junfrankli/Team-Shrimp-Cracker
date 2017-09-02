## Meet Shrimpy

Inspired by the delicious snack that holds so much flavor in such a small size, Shrimpy is intended to be a fully autonomous robot capable of traversing and mapping a maze.

# Lab 1: Microcontroller
## Objective
In this lab we learned how to use the Arduino Uno and IDE, taking digital and analog inputs and outputting digital and PWM signals.

###### Equipment
* 1 Arduino Uno
* 1 USB A/B cable
* 1 Continuous rotation servos
* 1 Pushbutton
* 1 LED (any color except IR!)
* 1 Potentiometer
* Several resistors (kΩ range)
* 1 Solderless breadboard


## Using the Serial Monitor and Analog Pins
For this section we hooked up a potentiometer to one of the Arduino’s analog pins. The pot is a variable resistor, and is used in a voltage divider circuit to provide an output to the pin of between 0V and 5V, depending on its position. Refer to the below below circuit diagram for how we hooked up our circuit:

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
When run, here’s what happens:

gfy
