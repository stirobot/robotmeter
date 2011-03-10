/* Copyright (c) 2008, Justin Nevitt
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of   conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Use of this software for commercial gain without written consent of 
*       above mentioned copyright holder is NOT permitted.  This includes, but 
*       is not limited to products which do not contain/or are not distributed 
*       with the software but are built with the purpose of using this software.
*
* THIS SOFTWARE IS PROVIDED BY Justin Nevitt ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */


//also a replacement for gauges
//set up for 2 display
//also set up for 1 and bar graph display

//multi mode selection via the "A" button
//"B" button clears peaks and operates the usb logging as well as the timer function
//#include <SoftwareSerial.h> 
//#define rxPin 4
//#define txPin 5


#include "WProgram.h"
void setup();
void loop ();
void test_all_meters();
void spray();
void play_piezo();
void accelerometer();
void runTimerv2();
void runTimer();
void print_T1 ();
void print_T2 ();
void oil_psi_meter();
void temp_meter();
void temp_boost_meter();
void two_temp_meter();
void printInTens(int Tvar);
void printBarGraph(int y);
long lookup_boost(long boost);
long lookup_oil_psi(long psival);
long lookup_oil_temp(long tval);
long lookup_temp(long tval);
void printAccelerometerReadout(int reading);
int getAccelerometerData (int axis);
void peak(int val);
int numberofdigits(long value);
void generic_bar_display(char title[ ], long high, long cur_value, long peak, long hiWarn, long loWarn, boolean hiloswitch);
void generic_dual_display (char title1[ ], long high1, long cur_value1, long peak1, long hiWarn1, long loWarn1, boolean hilo1, char title2[ ], long high2, long cur_value2, long peak2, long hiWarn2, long loWarn2, boolean hilo2);
void usb_logger();
void warn_flash();
void meter_splash(char line1[], char line2[]);
byte pinState = 0;

//int logfilecount = 0;

int xval = 4;
int yval = 5;
int negpeak = 0;
int pospeak = 0;
int pospeakcount = 0;
int negpeakcount = 0;
int zerogy = 512;
int zerogx = 512;

unsigned long T1 = 0;
unsigned long T2 = 0;

int mode = 1; 
int buttonApin = 12;
int buttonBpin = 10;
//int buttonBval = HIGH;

int sprayTriggerPin = 11;
int piezoTriggerPin = 9;

int t1pin = 2;
int t2pin = 3;
int tempPin = 1;
int boostPin = 0;

int timer_state = 0;
int timer_state1 = 0;
int timer_state2 = 0;
long tempmillisT1 = 0;
long tempmillisT2 = 0;

boolean startuptempswitch = false;

//global peaks...so that you can switch modes and preserve peaks
long boost_peak = 0;
long oil_psi_peak = 0;
long temp_peak = 0;
long temp1_peak = 0;
long temp2_peak = 0;

  
void setup(){
   pinMode(piezoTriggerPin, OUTPUT);
  //delay(10000);
  //setup the accelerometer and screen
  //Serial.begin(9600); 
  //Serial.print("IPA"); //to vdip logger
  //Serial.print(13, BYTE); //to vdip logger
  //delay(10000);
  //pinMode(sprayTriggerPin, OUTPUT);
  //digitalWrite(sprayTriggerPin, LOW);
  Serial.begin(9600);
  //put wait code to look and see if there is a
  //response from the VDIP1.  If there isn't try connecting again
  
  //read the root dir in the memstick to set the 
  //log file's name/number (its sequential)
  //Serial.print("DIR");
  //Serial.print(13, BYTE);
  //Serial.print(0xFE, BYTE);   //command flag
   //Serial.print(128, BYTE); 
  //while(Serial.available() > 0){
   //Serial.print(Serial.read()); 
  //}
  
  //Serial.print(0xFE, BYTE);   //command flag
   //Serial.print(128, BYTE); 
  //Serial.print("initialized");
  //read
  //int tfilenum = 0;
  /*if(Serial.available() > 0){
    //look for "LOG"
    int input = Serial.read();
    Serial.print(input);
    if (input == 76){  //L
      input = Serial.read();
       if (input == 79){ //O
       input = Serial.read();
        if (input == 71){ //G
          //get the numers after "LOG"
          input = Serial.read();
          tfilenum = input - 48;
          input = Serial.read();
          while (input > 48 && input < 58){
            input = Serial.read();
            tfilenum = tfilenum * 10 + input - 48;
          }
        } 
      }
    }
  }*/
  
  //logfilecount = tfilenum + 1;
 // Serial.print("OPW LOG555");
  //Serial.print(13, BYTE);
   Serial.print(0xFE, BYTE);   
   Serial.print(128, BYTE);  
   Serial.print("Welcome!"); //change this to the users greeting...also useful as a LCD communication test
   Serial.print(0xFE, BYTE);  
   Serial.print(192, BYTE); 
   Serial.print(""); //line two of the users splash screen
   for (int i=0; i<100; i++){
     play_piezo();
   }
   delay(1000);  //how long to delay on the 
  //Serial.print("file write");
  //Serial.print("CFL LOG555");
  //Serial.print(13,BYTE);
  
  //this next line for debug only
  //delay(10000);
  Serial.print(0x7C, BYTE);  
  Serial.print(157, BYTE);   //light level to 150 out of 157
   //Serial.print(0xFE, BYTE);   
   //Serial.print(0x01, BYTE);
  //zero the accelerometer...but only for small tilts
  delay(1000);
  int tempreading = analogRead(yval);
  if ((tempreading < 800) && (tempreading > 200)){
    zerogy = tempreading;
  }
  else {
    zerogy = 512;
  }
  tempreading = analogRead(xval);
  if (true) { //((tempreading < 800) && (tempreading > 200)){
    zerogx = tempreading;
  }
  else {
    zerogx = 512;
  }
  //setup the buttons as inputs
  pinMode(buttonApin, INPUT);
  pinMode(buttonBpin, INPUT);
  Serial.print(0xFE, BYTE);  
  Serial.print(0x01, BYTE); //clear LCD
}

void loop (){
  //WHAT MODE
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
   runTimerv2();
 } 
 if (mode == 1){
  temp_meter(); 
 }
 if (mode == 3){
  oil_psi_meter(); 
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

void test_all_meters(){
 /*if ( (lookup_oil_temp(analogRead(tempPin)) > 1500) && (mode != 1) ) { //oil temp
   mode = 1;
   temp_peak = lookup_oil_temp(analogRead(tempPin));
   temp_meter();
 } 
 /*if ((analogRead(t1pin) > 512) && (mode != 6)){ //temp1
   mode = 6;
   two_temp_meter();
 }
 if ((analogRead(t2pin) > 512) && (mode != 6)){ //temp2
   mode = 6;
   two_temp_meter();
 } 
 if (( (lookup_oil_psi(analogRead(boostPin))) >  100) && (mode != 3)){ //oil psi
   mode = 3;
   oil_psi_peak=lookup_boost(analogRead(boostPin));
   oil_psi_meter();
 } */
 return; 
}

//trigger something on pin x via the 
void spray(){
  digitalWrite(sprayTriggerPin, HIGH);
  delay(3000); //how long the spray lasts...spray will always last a little longer due to the built in timer in the car
  digitalWrite(sprayTriggerPin, LOW);
}

void play_piezo(){
 digitalWrite(piezoTriggerPin, HIGH);
 delayMicroseconds(1432);
 digitalWrite(piezoTriggerPin,LOW);
 delayMicroseconds(1432);
}

void accelerometer(){
    if (startuptempswitch == true){
     while (digitalRead(buttonApin) == LOW){}
    }
    test_all_meters();
    startuptempswitch = true;
    int accelx = ( getAccelerometerData (xval) );
    int accely = ( getAccelerometerData (yval) );
 
    pospeakcount++;
    negpeakcount++;
  
    peak(accely);
    Serial.print(0xFE, BYTE);   //command flag
    Serial.print(128, BYTE); 
    delay(60);
    printBarGraph(accely);
   Serial.print(0xFE, BYTE);   
   Serial.print(192, BYTE);  
    delay(60);
    Serial.print("x:");
    printAccelerometerReadout(accelx);
    Serial.print(" y: ");
    printAccelerometerReadout(accely);
}

//timer_states
//0 = all zeros and restarted
//1 = running
//2 = stopped but not zeroed
void runTimerv2(){
  while (digitalRead(buttonApin) == LOW){
  }
  Serial.print(0xFE, BYTE);   
  Serial.print(0x01, BYTE);
  while ( (digitalRead(buttonApin) == HIGH) && (digitalRead(buttonBpin) == HIGH) ) {
   
   if(digitalRead(buttonApin==LOW)){
     if (timer_state1 <= 2){
       timer_state1++;
     }
     else{
       timer_state1=0;
     }
     if (timer_state1=1){
       tempmillisT1=millis();
     }
     while(digitalRead(buttonApin==LOW)){ //debounce
      if(digitalRead(buttonBpin==LOW)){
        return;
      }
     }
   }
   
   if(digitalRead(buttonBpin==LOW)){
     if (timer_state2 <= 2){
       timer_state2++;
     }
     else{
       timer_state2=0;
     }
     if (timer_state2=1){
       tempmillisT2=millis();
     }
     while(digitalRead(buttonBpin==LOW)){ //debounce
      if(digitalRead(buttonApin==LOW)){
        return;
      }
     }
   }
   
   test_all_meters();
   if (timer_state1 == 0) {
     Serial.print(0xFE, BYTE);   //command flag
     Serial.print(128, BYTE);  
     delay(20);
     Serial.print("T1: 00:00:00.00");
     T1 = 0;
   }
   if (timer_state2 == 0){
     Serial.print(0xFE, BYTE);   
     Serial.print(192, BYTE);  
     delay(20);
     Serial.print("T2: 00:00:00.00"); 
     T2 = 0;
   }
   
   if (timer_state1 == 1){
     T1 = millis() - tempmillisT1;
     //printing to the screen
     print_T1();
     //a short pause
     delay(50);
   }
   if (timer_state2 == 1){
     T2 = millis() - tempmillisT2;
     //printing to the screen
     print_T2();
     //a short pause
     delay(50);
   }
   if (timer_state1 == 2){
     print_T1();
   }
   if (timer_state2 == 2){
     print_T2();
   }
   
  }
   
}

void runTimer(){
  while (digitalRead(buttonApin) == LOW){
   }
  test_all_meters();
  if (timer_state == 0){
   Serial.print(0xFE, BYTE);   
   Serial.print(0x01, BYTE);
    Serial.print(0xFE, BYTE);   //command flag
    Serial.print(128, BYTE);  
    delay(20);
    Serial.print("T1: 00:00:00.00");
   Serial.print(0xFE, BYTE);   
   Serial.print(192, BYTE);  
    Serial.print("T2: 00:00:00.00"); 
    T1 = 0;
    T2 = 0;
    while (digitalRead(buttonBpin) == HIGH){
     //wait for start
     if (digitalRead(buttonApin) == LOW){
       return;
     } 
    }
    while (digitalRead(buttonBpin) == LOW){
      //we don't want to skip the start if you hold the button too long
     //timing actually happens on button release 
     timer_state = 1;
     tempmillisT1 = millis();
    }
  }
  if (timer_state == 1){
   Serial.print(0xFE, BYTE);   
   Serial.print(0x01, BYTE);
    Serial.print(0xFE, BYTE);   
    Serial.print(128, BYTE); 
    while (digitalRead(buttonBpin) == HIGH){
      test_all_meters();
      //timing
      if (digitalRead(buttonApin) == LOW){
        return;
      }
   Serial.print(0xFE, BYTE);   
   Serial.print(0x01, BYTE);
      T1 = millis() - tempmillisT1;
      //printing to the screen
      print_T1();
      //a short pause
      delay(50);
    }
    while (digitalRead(buttonBpin) == LOW){
      //stop T1 timing
      test_all_meters();
      timer_state = 2;
    }
  }
  if (timer_state == 2){ //timed shown on T1 and zeros on T2 waiting to start T2
    //display T1 if we cycle through modes and reach this
    //---
   Serial.print(0xFE, BYTE);   
   Serial.print(0x01, BYTE);
      //printing to the screen
      print_T1();
      //a short pause
      delay(50);
      
      //display T2 as zeros
   Serial.print(0xFE, BYTE);   
   Serial.print(192, BYTE);  
      Serial.print("T2: 00:00:00.00"); 
    //---
    
    while (digitalRead(buttonBpin) == HIGH){
     //wait for timing T2
     if (digitalRead(buttonApin) == LOW){
      return;
     } 
     test_all_meters();
    }
    while (digitalRead(buttonBpin) == LOW){
     //clicking to start T2 
      timer_state = 3;
      tempmillisT2 = millis();
    }
  }
  if (timer_state == 3){ //T1 is displayed and T2 is running
    //display T1 if this mode is reache durring mode switching
    //--
   Serial.print(0xFE, BYTE);   
   Serial.print(0x01, BYTE);
      //printing to the screen
      print_T1();
      
    //--
    
    delay(10);

    while (digitalRead(buttonBpin) == HIGH){
      test_all_meters();
      if (digitalRead(buttonApin) == LOW){
        return;
       }
      //T2 timing 
      T2 = millis() - tempmillisT2;
      //printing to the screen
      print_T2();
      //a short pause
      delay(50);
    }
    while (digitalRead(buttonBpin) == LOW){
      //click to stop
      timer_state = 4;
    }
  }
  if (timer_state == 4){
   Serial.print(0xFE, BYTE);   
   Serial.print(0x01, BYTE);
    while (digitalRead(buttonBpin) == HIGH){ 
      //what to do if we've reached this direct thru mode switching
      //---
        //printing to the screen
        print_T1();
        //a short pause
        delay(50);
      
        //display T2
        print_T2();
        //a short pause
        delay(50);
       
    //---
      test_all_meters();
      if (digitalRead(buttonApin) == LOW){
        return;
      }
    }
    while (digitalRead(buttonBpin) == LOW){}
    //on release return to main loop
    timer_state = 0;
  }
  return;
}

void print_T1 (){
     //printing to the screen
     Serial.print(0xFE, BYTE);   
     Serial.print(128, BYTE); 
     unsigned long T1millis = T1%1000/10;
     unsigned long T1seconds = T1%60000/1000;
     unsigned long T1minutes = T1%3600000/60000;
     unsigned long T1hours = T1/3600000;
     Serial.print("T1: ");
     printInTens(T1hours);
     Serial.print(":");
     printInTens(T1minutes);
     Serial.print(":");
     printInTens(T1seconds);
     Serial.print(".");
     printInTens(T1millis);
}

void print_T2 (){
     //printing to the screen
   Serial.print(0xFE, BYTE);   
   Serial.print(192, BYTE);  
     unsigned long T2millis = T2%1000/10;
     unsigned long T2seconds = T2%60000/1000;
     unsigned long T2minutes = T2%3600000/60000;
     unsigned long T2hours = T2/3600000;
     Serial.print("T2: ");
     printInTens(T2hours);
     Serial.print(":");
     printInTens(T2minutes);
     Serial.print(":");
     printInTens(T2seconds);
     Serial.print(".");
     printInTens(T2millis);
}

void oil_psi_meter(){ 
 while (digitalRead(buttonApin) == LOW){}
   meter_splash("Oil Pressure", "     Meter");
   Serial.print(0xFE, BYTE);   
   Serial.print(0x01, BYTE);
   Serial.print(0xFE, BYTE);   
   Serial.print(128, BYTE); 
 long reading = 0;
 while (digitalRead(buttonApin) == HIGH){
  test_all_meters();
  if (digitalRead(buttonBpin) == LOW) {
    oil_psi_peak = 0;
  }  
  //non sensor code
  //reading = reading + 1;
  //real reading code
  //0 psi = 12 Vcount;
  reading = lookup_oil_psi( long(analogRead(boostPin)) ); //boostPin is the same as oil_psi pin
  oil_psi_peak = max (reading, oil_psi_peak); 
  generic_bar_display ("psi", 1700, reading, oil_psi_peak, 1450, 0, true);
  delay(50);    
 }
 return;
}

/*void boost_meter(){ 
 while (digitalRead(buttonApin) == LOW){}
   meter_splash("Boost", "     Meter");
   Serial.print(0xFE, BYTE);   
   Serial.print(0x01, BYTE);
   Serial.print(0xFE, BYTE);   
   Serial.print(128, BYTE); 
 long reading = 0;
 while (digitalRead(buttonApin) == HIGH){
  test_all_meters();
  if (digitalRead(buttonBpin) == LOW) {
    boost_peak = 0;
  }  
  //non sensor code
  //reading = reading + 1;
  //real reading code
  //0 psi = 12 Vcount;
  reading = lookup_boost( long(analogRead(boostPin)) );
  boost_peak = max (reading, boost_peak); 
  generic_bar_display ("psi", 170, reading, boost_peak, 145, false);
  delay(50);    
 }
 return;
} */

void temp_meter(){ 
 if (startuptempswitch == false){
  while (digitalRead(buttonApin) == LOW){}
 }
   meter_splash("Oil Temp", "     Meter");
 long reading = 0;
 while (digitalRead(buttonApin) == HIGH){
  test_all_meters(); 
  if (digitalRead(buttonBpin) == LOW) {
    temp_peak = 0;
  }
  //reading = reading + 1;
  reading = lookup_oil_temp(analogRead(tempPin));

  if ((startuptempswitch == false) && (reading > 145)){
    mode = 2;
    return;
  }
  temp_peak = max (temp_peak, reading);
  generic_bar_display ("oil", 3500, reading, temp_peak, 2600, 0, true);
  delay(50);    
 }
 return;
}

void temp_boost_meter(){ 
 while (digitalRead(buttonApin) == LOW){}
  meter_splash("Oil Temp", "and PSI Meter");
 long reading1 = 0;
 long reading2 = 0;
 while (digitalRead(buttonApin) == HIGH){
  test_all_meters();
  if (digitalRead(buttonBpin) == LOW) {
    temp_peak = 0;
    oil_psi_peak = 0;
  }
  //reading1 = random(100,350);
  reading1 = lookup_oil_temp(analogRead(tempPin));
  reading2 = lookup_oil_psi( long(analogRead(boostPin)) );
  temp_peak = max (temp_peak, reading1);
  oil_psi_peak = max (oil_psi_peak, reading2); 
  generic_dual_display ("tmp", 3500, reading1, temp_peak, 2000, 0, true, "psi", 1500, reading2, oil_psi_peak, 1000, 0, true);
  delay(50);    
 }
 return;
}

void two_temp_meter(){ 
 while (digitalRead(buttonApin) == LOW){}
   meter_splash("2 Temp Meter", "");
 long reading1 = 0;
 long reading2 = 0;
 while (digitalRead(buttonApin) == HIGH){
  test_all_meters();
  if (digitalRead(buttonBpin) == LOW) {
    temp1_peak = 0;
    temp2_peak = 0;
  }
  reading2 = lookup_temp((long)analogRead(t2pin));
  reading1 = lookup_temp((long)analogRead(t1pin));
  //reading1 = analogRead(t1pin);
  temp1_peak = max (temp1_peak, reading1);
  temp2_peak = max (temp2_peak, reading2); 
  generic_dual_display ("F 1", 1400, reading1, temp1_peak, 9999, 0, true, "F 2", 1400, reading2, temp2_peak, 1000, 0, true);
  delay(20);    
 }
 return;
}

void printInTens(int Tvar){
    if (Tvar < 10){
      Serial.print("0");
      Serial.print(Tvar);
    }
    else Serial.print(Tvar);
    return;
}

void printBarGraph(int y) { 
  //clear the 1st 8 spacesb
  if ( y >= 0){
    Serial.print("        ");  
    for(int i=1; i <= y/16; i++){
       Serial.print(0xFF, BYTE);
    }
    //fill the rest with spacesloo
    for(int i=1; i <= (8-y/16); i++){ 
      Serial.print(" "); 
    }
  }
  if (y < 0) {
    //1 - print spaces at the beginning
    for (int i=1; i <= (8-abs(y/16)); i++){
      Serial.print(" "); 
    }
    //2 - print blocks till the middle
    for (int i=1; i <= abs(y/16); i++){
      Serial.print(0xFF, BYTE);
    }
    //3 - print spaces till the end
    for (int i=1; i<=8; i++){
      Serial.print(" ");
    }
  }
 
 //print the peaks if there are any
 //negative
 Serial.print(0xFE, BYTE);  
 Serial.print(128, BYTE);
 if (negpeak/16 < 0){
   Serial.print(0xFE, BYTE);
   int npos = 128 + (8 - abs(negpeak/16));
   Serial.print(npos, BYTE);
   Serial.print(0xFF, BYTE);
 }
 
 //positive
 if (pospeak/16 > 0){
   Serial.print(0xFE, BYTE);
   int ppos = 128 + (8 + (pospeak/16));
   Serial.print(ppos, BYTE);
   Serial.print(0xFF, BYTE);
 }
  
}

long lookup_boost(long boost){
  //boost = ( (boost-106000) / 259000 );
  // boost = ( (( boost * 398) / 1000) + 2); //2 is the y intercept
  //398 changed to 378 for slope...because slope was too steep
  boost = ( (( boost * 378) / 1000) - 4); ///10; //get rid of the divide by ten when adding decimals on display
  return boost;
}

//calculated for use with 0-100 psi sender from autometer with 240-33 ohm range using a 100 ohm resistor as R1
/*long lookup_oil_psi(long psival){
   if (psival > 722){
     return (0);
   }
   if (psival < 257){
     return(9999);
   }
   if ((psival <= 722)&&(psival > 619)) {
     return 1747 - (psival*240)/100; 
   } 
   if ((psival <= 619)&&(psival > 520)) {
     return 1802 - (psival*250)/100;
   }
   if ((psival <= 520)&&(psival > 411)) {
     return 1694 - (psival*230)/100;     
   }
   if ((psival <= 411)&&(psival > 257)){
     return 1418 - (psival*160)/100;
   }
} */

long lookup_oil_psi(long psival){
 if (psival < 102){
   return 0;
 }
 if (psival > 922){
  return 9999; 
 }
 else {
  return (psival*14)/10 - 144;
 }
}

long lookup_oil_temp(long tval){
  tval = tval * 1000; //added an extra 0
  if (tval <= 11500){
    return (9999); 
  }
  if (tval >= 68100){
    return (0);
  }
  if ((tval <= 68000)&&(tval > 39600)){
    return (long)(((tval-134266)*10)/(-473));
  }
  if ((tval <= 39600)&&(tval > 28200)){
    return (long)(((tval-115600)*10)/(-380));
  }
  if ((tval <= 28200)&&(tval > 19700)){
    return (long)(((tval-93366)*10)/(-283));
  }  
  if ((tval <= 19700)&&(tval > 11600)){
    return (long)(((tval-54800)*10)/(-135));
  }  
}

long lookup_temp(long tval){
  tval = tval * 100;
  //tval = (long)(tval - (long)117588);
  //return tval;
  if (tval < 8900){
   return (9999); 
  }
  if (tval > 96000){
    return (0);
  }
  if ((tval <= 96000)&&(tval > 93221)){
    return (((tval-101577)*10)/(-172));
  }
  if ((tval <= 93221)&&(tval > 89610)){
    return (((tval-104201)*10)/(-226));
  }
  if ((tval <= 89610)&&(tval > 85125)){
    return (((tval-107738)*10)/(-280));
  }
  if ((tval <= 85125)&&(tval > 79139)){
    return (((tval-112264)*10)/(-335));
  }
  if ((tval <= 79139)&&(tval > 70799)){
    return (((tval-117588)*10)/(-388));
  }
  if ((tval <= 70799)&&(tval > 62470)){
    return (((tval-121441)*10)/(-421));
  }
  if ((tval <= 62470)&&(tval > 53230)){
    return (((tval-122367)*10)/(-428));
  }
  if ((tval <= 53230)&&(tval > 43707)){
    return (((tval-118651)*10)/(-405));
  }
  if ((tval <= 43707)&&(tval > 36471)){
    return (((tval-111349)*10)/(-366));
  }
  if ((tval <= 36471)&&(tval > 30685)){
    return (((tval-102232)*10)/(-321));
  }
  if ((tval <= 30685)&&(tval > 24800)){
    return (((tval-9078)*10)/(-270));
  }
  if ((tval <= 24800)&&(tval > 20000)){
    return (((tval-78575)*10)/(-220));
  }
  if ((tval <= 20000)&&(tval > 15851)){
    return (((tval-66507)*10)/(-175));
  }
  if ((tval <= 15851)&&(tval > 12380)){
    return (((tval-55300)*10)/(-137));
  }
  if ((tval <= 12380)&&(tval > 9085)){
    return (((tval-41752)*10)/(-94));
  }
}

void printAccelerometerReadout(int reading){
  if (reading >= 0 ) {
    Serial.print("+");
  }
  if (reading < 0) {
    Serial.print("-");
  }
  
  int afterdecimal = reading % 100;
  Serial.print(abs(reading/100));
  if ( (afterdecimal > 9) || (afterdecimal < -9) ){
    Serial.print(".");
  }
  else {
    Serial.print(".0");
  }
  Serial.print(abs(afterdecimal));
}

int getAccelerometerData (int axis){
  int zerog = 512;
  if (axis == 5){
   zerog = zerogy;
  }
  if (axis == 3){
   zerog = zerogx; 
  }
    
  int rc = analogRead(axis);
  int top =( (zerog - rc) ) ; 
  float frtrn = (((float)top/(float)154)*100);  //158Vint jumps are 1g for the ADXL213AE (original accel)
  //154Vint jumps are 1g for the ADXL322 (updated one)
  int rtrn = (int)frtrn;
  return rtrn;
}

void peak(int val){
  
  if ( (val > 0) && (val > pospeak) ){       //pos peak compare and set
      pospeak = val;
      pospeakcount = 0;
  }
 
  if ( (val < 0) && (val < negpeak) ) {     //neg peak compare and set 
       negpeak = val;
       negpeakcount = 0;
  }
  
  else {                                    //peak mark expires after x time
    if (pospeakcount >= 20){
      pospeakcount = 0;
      pospeak = 0;
    }
    if (negpeakcount >= 20){
      negpeakcount = 0;
      negpeak = 0;
    }
  }
}

int numberofdigits(long value){
 
 int digits = 1;
 while (value/10 > 0){
  value = value/10;
  digits++; 
 }
 
 if (value < 0){digits ++;}
 return digits; 
}

//positive only value 0 to X
//only 4 char titles (should be changed soon)
//1234567890123456
//TMP 134.5/ 314.5
//psi 14.5 /  14.5 
//oil 1.0  /   1.4
//oil 0.3  /   0.4
void generic_bar_display(char title[ ], long high, long cur_value, long peak, long hiWarn, long loWarn, boolean hiloswitch){
  int ndigits = 0;
  Serial.print(0xFE, BYTE);  
  Serial.print(128, BYTE);
  Serial.print(title);
  if( (hiloswitch == true) && (cur_value == 0) ){
   Serial.print("LOW ");
  } 
  if ( (hiloswitch == true) && (cur_value == 9999) ){
   Serial.print("HIGH "); 
  }
  else {
    Serial.print(" ");
    Serial.print(cur_value/10);
    Serial.print(".");
    Serial.print(cur_value%10);
    ndigits = numberofdigits(cur_value) + 1;
    if (ndigits <= 2){ ndigits = ndigits + 1;}
    for (int i = 0; i < 5 - ndigits; i++) {
     Serial.print(" "); 
    }
  }
  Serial.print("/");
  ndigits = numberofdigits(peak) + 1;
  if (ndigits <= 2){ ndigits = ndigits + 1;}
  for (int i = 0; i < 6 - ndigits; i++){
   Serial.print(" "); 
  }
  Serial.print(peak/10);
  Serial.print(".");
  Serial.print(peak%10);
  if ( (cur_value > hiWarn) || (cur_value < loWarn) ){ //blink if warning threshold is met
    warn_flash();
  }
   Serial.print(0xFE, BYTE);   
   Serial.print(192, BYTE);  
  unsigned long abar = high/16;
  unsigned long n_bars = cur_value/abar;
  if (cur_value <= 0){n_bars=0;}
  for(int i=1; i< n_bars; i++){ 
     Serial.print(0xFF, BYTE);
  }
  for (int i=1; i < (16 - n_bars); i++){
     Serial.print(" "); 
  }
  delay(100); //gauge refresh rate in ms
}

//use only 4 char titles (should be changed soon)
void generic_dual_display (char title1[ ], long high1, long cur_value1, long peak1, long hiWarn1, long loWarn1, boolean hilo1, char title2[ ], long high2, long cur_value2, long peak2, long hiWarn2, long loWarn2, boolean hilo2){
  int ndigits = 0;
  Serial.print(0xFE, BYTE);  
  Serial.print(128, BYTE);
  Serial.print(title1);
  Serial.print(" ");
  if ( (hilo1 == true) && (cur_value1 == 0) ){
   Serial.print("LOW  "); 
  }
  else if ( (hilo1 == true) && (cur_value1 == 9999) ){
   Serial.print("HIGH  "); 
  }
  else {
    Serial.print(cur_value1/10);
    Serial.print(".");
    Serial.print(cur_value1%10);
    ndigits = numberofdigits(cur_value1) + 1;
    if (ndigits <= 2){ ndigits = ndigits + 1;}
    for (int i = 0; i < 5 - ndigits; i++) {
     Serial.print(" "); 
    }
  }
  Serial.print("/");
  ndigits = numberofdigits(peak1) + 1;
  if (ndigits <= 2){ ndigits = ndigits + 1;}
  for (int i = 0; i < 6 - ndigits; i++){
   Serial.print(" "); 
  }
  Serial.print(peak1/10);
  Serial.print(".");
  Serial.print(peak1%10);
  if ( (cur_value1 > hiWarn1) || (cur_value1 < loWarn1) ){ //blink if warning threshold is met
    warn_flash();
  }
   Serial.print(0xFE, BYTE);   //select the second line
   Serial.print(192, BYTE);  
  Serial.print(title2);
  Serial.print(" ");
  if ( (hilo2 == true) && (cur_value2 == 0) ){
    Serial.print("LOW  ");
  }
  else if ( (hilo2 == true) && (cur_value2 == 9999) ){
    Serial.print("HIGH ");
  }
  else {
    Serial.print(cur_value2/10);
    Serial.print(".");
    Serial.print(cur_value2%10);
    ndigits = numberofdigits(cur_value2) + 1;
    if (ndigits <= 2){ ndigits = ndigits + 1;}
    for (int i = 0; i < 5 - ndigits; i++) {
     Serial.print(" "); 
    }
  }
  Serial.print("/");
  ndigits = numberofdigits(peak2) + 1;
  if (ndigits <= 2){ ndigits = ndigits + 1;}
  for (int i = 0; i < 6 - ndigits; i++){
   Serial.print(" "); 
  }
  Serial.print(peak2/10);
  Serial.print(".");
  Serial.print(peak2%10);
  if ( (cur_value2 > hiWarn2) || (cur_value2 < loWarn2) ){ //blink if warning threshold is met
     warn_flash();
  }
  delay(100);
}

//quad display -- mus use 4 char (incl ":") for each title...ex "PSI:", "TEMP", "POOP", " ETC"
//void generic_quad_display(char title1[], unsigned long reading1, unsigned long warn1, char title2[], unsigned long reading2, unsigned long warn2, char title3[], unsigned long reading3, unsigned long warn3, char title4[], unsigned long reading4, unsigned long warn4){
 //Serial.print(0xFE, BYTE);  
 //Serial.print(128, BYTE);
//  Serial.print(title1);
  
//}

//changed from the regular v4 to log to a serial logging device not
//to usb on a laptop

void usb_logger(){
 while (digitalRead(buttonApin) == LOW){}
   Serial.print(0xFE, BYTE);   
   Serial.print(0x01, BYTE);
   Serial.print(0xFE, BYTE);  
   Serial.print(128, BYTE);
   Serial.print("USB Logging");
   Serial.print(0xFE, BYTE);   
   Serial.print(192, BYTE);  
   Serial.print("Press B"); 
 while (digitalRead(buttonBpin) == HIGH){
   if (digitalRead(buttonApin)==LOW){
     return;
   }
 }
 delay(500);
   Serial.print(0xFE, BYTE);   
   Serial.print(0x01, BYTE);
 Serial.print("Logging");   //command flag
 //Serial.print(0x08, BYTE);   //turn off visual display
 //Serial.print("Data logger: \n");
 //open a new file based on a millis timestamp, give it a header and start writting
 //Serial.print("OPW log");
// Serial.print(logfilecount);
 //Serial.print(".txt");
 //Serial.print(13, BYTE);
 //Serial.print("WRF ");
 //Serial.print(42);
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
   
   //calc the number of characters
   int linelen = 5 + numberofdigits(t1) + numberofdigits(t2) + numberofdigits(oil) + numberofdigits(press) + numberofdigits(ax) + numberofdigits(ay);
   //print the number of characters for this line
   Serial.print(linelen);
   Serial.print(13, BYTE);
   
   Serial.print(t1);
   Serial.print(",");
   //get T2 and convert
   //Serial.print( lookup_temp(analogRead(t2pin)) );
   Serial.print(t2);
   Serial.print(",");
   //get oil temp and convert
   //Serial.print( analogRead(tempPin) );
   Serial.print(oil);
   Serial.print(",");
   //get boost and convert
   Serial.print(press);
   //Serial.print("###");
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
 //close the file
 //Serial.print("CLF log%"); 
 //Serial.print(logfilecount);
 //Serial.print(".txt");
 //Serial.print(13, BYTE);
 //logfilecount++;
 //Serial.print(0xFE, BYTE);   //command flag
 //Serial.print(0x0C, BYTE);   //turn on visual display
 return;
}

void warn_flash(){
  Serial.print(0x7C, BYTE);  
  Serial.print(128, BYTE);  //backlight off
  for (int i=0; i<=200; i++){ //play the piezo 
    play_piezo();
  }
  Serial.print(0x7C, BYTE);  
  Serial.print(157, BYTE);  //backlight on
  delay(300);
}

void meter_splash(char line1[], char line2[]){
   Serial.print(0xFE, BYTE);   
   Serial.print(0x01, BYTE); //clear
   Serial.print(0xFE, BYTE);  
   Serial.print(128, BYTE); //select line 1
   Serial.print(line1);
   Serial.print(0xFE, BYTE);   
   Serial.print(192, BYTE);  //select line 2
   Serial.print(line2); 
   delay(1000);                  //wait
   Serial.print(0xFE, BYTE);   //clear
   Serial.print(0x01, BYTE);
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

