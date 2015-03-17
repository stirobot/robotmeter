#how to log via usb to a computer.

##### Usb Logging to a Computer #####

All serial messages (Serial.print("stuff"); get output to through the USB output as serial data.  This data can easily be read  and parsed by many different programs.  Currently the only way to get serial data out of the device is to use the serial listener in the arduino IDE.  However, a script for creating time stamped logging files will be written in the near future.

Code for creating comma delimited log files (assumes you are using software serial assigned to LCDSerial for the LCD):
```
  void usb_logger(){
   while (digitalRead(buttonApin) == LOW){}
     LCDSerial.print(0xFE, BYTE);   
     LCDSerial.print(0x01, BYTE);
     LCDSerial.print(0xFE, BYTE);  
     LCDSerial.print(128, BYTE);
     LCDSerial.print("USB Logging");
     LCDSerial.print(0xFE, BYTE);   
     LCDSerial.print(192, BYTE);  
     LCDSerial.print("Press B"); 
   while (digitalRead(buttonBpin) == HIGH){
     if (digitalRead(buttonApin)==LOW){
       return;
     }
   }
   delay(500);
     LCDSerial.print(0xFE, BYTE);   
     LCDSerial.print(0x01, BYTE);
     LCDSerial.print("Logging"); 
    Serial.print("T1, T2, Oil Temp, Boost, x accel, y accel\n"); 
    Serial.print(13, BYTE);
 
   while (digitalRead(buttonBpin) == LOW){}
   while ( (digitalRead(buttonApin) == HIGH) && (digitalRead(buttonBpin) == HIGH) ){
     //logging output
     Serial.print("WRF ");

     long t1 = ( (lookup_temp(analogRead(t1pin))) );
     long t2 = ( (lookup_temp(analogRead(t2pin))) );
     long oil = ( lookup_oil_temp(analogRead(tempPin))); 
     long press =  lookup_boost(analogRead(boostPin));
     long ax = getAccelerometerData (xval);
     long ay = getAccelerometerData (yval);
     Serial.print(t1);
     Serial.print(",");
     //get T2 and convert
     //LCDSerial.print( lookup_temp(analogRead(t2pin)) );
     Serial.print(t2);
     Serial.print(",");
     //get oil temp and convert
     //LCDSerial.print( analogRead(tempPin) );
     Serial.print(oil);
     Serial.print(",");
     //get boost and convert
     Serial.print(press);
     //LCDSerial.print("###");
     Serial.print(",");
     //get x accel
     Serial.print(ax);
     Serial.print(",");
     //get y accel
     Serial.print(ay);
     //Serial.print("\n");
   
     Serial.print(13, BYTE);
   }
   while ( (digitalRead(buttonApin) == LOW) && (digitalRead(buttonBpin) == LOW) ){}
   return;
  }
```