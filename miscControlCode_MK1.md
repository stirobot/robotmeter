#This is the Misc section with various interesting/important pieces of code.


##### Other Control Code #####

This is the Misc section with various interesting/important pieces of code.

#### Mode selection ####
Modes are selected via the A button.  Each mode is essentially a while loop that is terminated by the pressing of the A button.  This then returns the mode to the main loop which switches and keeps track of the mode iteration.
```
  void loop (){
    //WHAT MODE
    LCDSerial.print(mode);
    if (digitalRead(buttonApin) == LOW){
      while (digitalRead(buttonApin)){
       //avoids flipping modes rapidly
      }
       if (mode == 1){mode=2;}
       else if (mode == 2){mode=3;}
       else if (mode == 3){mode=4;}
       else if (mode == 4){mode=5;}
       else if (mode == 5){mode=6;}
       else if (mode == 6){mode=7;}
       else mode = 1;
      }
   //ACCELEROMETER
   if (mode == 2) {
      accelerometer();
   }
   //LAP TIMER 
   if (mode == 6){
     runTimer();
   } 
   if (mode == 1){
    temp_meter(); 
   }
   if (mode == 3){
    boost_meter(); 
   }
   if (mode == 4){
    temp_boost_meter(); 
   }
   if (mode == 5){
     two_temp_meter();
   }
   if (mode == 7){
     usb_logger();
   }
  }
```
#### Test all meters ####

If a user is on one mode and a value which should show a warning is read from a sensor not displayed on that mode then the device should switch to that mode and display the warning flash.  This function is called at the beginning of each while loop of each mode.
```
  void test_all_meters(){
  /* if ((analogRead(tempPin) > 512) && (mode != 1)){ //oil temp
     mode = 1;
     temp_meter();
   } 
   if ((analogRead(t1pin) > 512) && (mode != 6)){ //temp1
     mode = 6;
     two_temp_meter();
   }
   if ((analogRead(t2pin) > 512) && (mode != 6)){ //temp2
     mode = 6;
     two_temp_meter();
   }*/
  if   (( (lookup_boost(analogRead(boostPin))) >  140) && (mode != 3)){ //boost
     mode = 3;
     boost_peak=lookup_boost(analogRead(boostPin));
     spray();
     boost_meter();
   }
   return;
  }
```
#### Trigger something via a relay ####

If a relay is properly rigged and routed to a digital pin a value can trigger the run of this function.  In this case it is set up to trigger an Intercooler water sprayer for 3 seconds.  This could be set up for many things including N2O, Cryo, meth, etc.
```
  void spray(){
    digitalWrite(sprayTriggerPin, HIGH);
    delay(3000); //how long the spray lasts...spray will always last a little longer due to the built in timer in the car
    digitalWrite(sprayTriggerPin, LOW);
  }
```
#### Oil temp at startup ####

Having the oil temperature gauge tell you when the car is warmed up is a very useful feature.  This feature is controlled by a boolean switch which is set to on when the device is turned on.  This switch changes if the user switches to the accelerometer mode (the sequentially following the oil temp meter).
```
  if (startuptempswitch == true){
     while (digitalRead(buttonApin) == LOW){}
    }
    test_all_meters();
    startuptempswitch = true;
    int accelx = ( getAccelerometerData (xval) );
    int accely = ( getAccelerometerData (yval) );
```
If the switch hasn't been boolean switch hasn't been switch and the right temp is reached the oil temp mode will automatically do the flash to warn and switch to the accelerometer mode:
```
  if ((startuptempswitch == false) && (reading > 145)){
    mode = 2;
    return;
  }
```

#### Flash to warn ####

If statements are located in each of the meters that trigger this function.  It flashes the backlight LED of the LCD whenever a set point (set in the code) is reached for that meter.
```
  void warn_flash(){
    Serial.print(0x7C, BYTE);  
    Serial.print(128, BYTE);  //backlight off
    delay(300);
    Serial.print(0x7C, BYTE);  
    Serial.print(157, BYTE);  //backlight on
    delay(300);
  }
```

#### Play a Piezo tone (for warnings, etc) ####

In setup():
```

   pinMode(piezoTriggerPin, OUTPUT);
```
Also in setup().  Plays a test tone on startup:
```
   for (int i=0; i<100; i++){
     play_piezo();
   }
```
The driving function.  Changing the delays changes the shape of the wave that is played:
```
  void play_piezo(){
     digitalWrite(piezoTriggerPin, HIGH);
     delayMicroseconds(1432);
     digitalWrite(piezoTriggerPin,LOW);
     delayMicroseconds(1432);
  }


```