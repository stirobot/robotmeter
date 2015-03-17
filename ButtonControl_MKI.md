#How to use a button.

##### Button Control #####
The buttons used are generic SPST normally open momentary switches.  These come with two leads and are configured as such:

![http://robotmeter.com/meter/pictures/buttonwiring.jpg](http://robotmeter.com/meter/pictures/buttonwiring.jpg)


For more information on button wiring check: [Arduino.cc button tutorial](http://www.arduino.cc/en/Tutorial/Button)

##### Button Debouncing #####

Certain care is necessary when using buttons for control.  One wishes to capture only the single push of a button and not multiple presses.  This can be controlled by the use of while statements such as these from the boost gauge function:
```
  while (digitalRead(buttonBpin) == HIGH){
     //wait for timing T2
     if (digitalRead(buttonApin) == LOW){
      return;
     }
  ...
```
It is also possible to achieve the same effect by following this tutorial: [Arduino.cc button debounce tutorial](http://www.arduino.cc/en/Tutorial/Debounce)