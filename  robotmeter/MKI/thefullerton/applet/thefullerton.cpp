#include "WProgram.h"
/* Copyright (c) 2008, Justin Nevitt
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
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

void setup();
void loop ();
void test_all_meters();
void runTimer();
void print_T1 ();
void print_T2 ();
void temp_meter();
void two_temp_meter();
void printInTens(int Tvar);
void printBarGraph(int y);
long lookup_oil_temp(long tval);
long lookup_oil_psi(long psival);
long lookup_temp(long tval);
void printAccelerometerReadout(int reading);
int getAccelerometerData (int axis);
void peak(int val);
int numberofdigits(long value);
void generic_bar_display(char title[ ], long high, long cur_value, long peak, long hiWarn, long loWarn);
void generic_dual_display (char title1[ ], long high1, long cur_value1, long peak1, long loWarn1, long hiWarn1, char title2[ ], long high2, long cur_value2, long peak2, long loWarn2, long hiWarn2);
void warn_flash();
void meter_splash(char line1[], char line2[]);
void startupTimerAndOil();
void gforceAndAccel();
void allTemps();
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
int buttonApin = 10;
int buttonBpin = 13;
int buttonBval = HIGH;

int piezoTriggerPin = 11;

int t1pin = 2;
int t2pin = 3;
int tempPin = 1;
int oilPsiPin = 0;

int timer_state = 0;
long tempmillisT1 = 0;
long tempmillisT2 = 0;

boolean startuptempswitch = false;

//global peaks...so that you can switch modes and preserve peaks
long temp_peak = 0;
long temp1_peak = 0;
long temp2_peak = 0;

  
void setup(){
  //delay(10000);
  //setup the accelerometer and screen
  Serial.begin(9600); 
 
   Serial.print(0xFE, BYTE);   
   Serial.print(192, BYTE);  
  
    Serial.print(0x7C, BYTE);  
    Serial.print(150, BYTE); 

  //zero the accelerometer...but only for small tilts
  int tempreading = analogRead(yval);
  if ((tempreading < 600) && (tempreading > 400)){
    zerogy = tempreading;
  }
  else {
    zerogy = 512;
  }
  tempreading = analogRead(xval);
  if ((tempreading < 600) && (tempreading > 400)){
    zerogx = tempreading;
  }
  else {
    zerogx = 512;
  }
  //setup the buttons as inputs
  pinMode(buttonApin, INPUT);
  pinMode(buttonBpin, INPUT);
}

void loop (){
  //WHAT MODE
  if (digitalRead(buttonApin) == LOW){
    while (digitalRead(buttonApin)){
     //avoids flipping modes rapidly 
    }
     if (mode == 0){mode=2;}
     else if (mode == 1){mode=2;}
     else if (mode == 2){mode=3;}
     else mode = 1;
  }
 if (mode == 0){
   startupTimerAndOil();
 } 
 if (mode == 1){
  gforceAndAccel; 
 }
 if (mode == 2){
  allTemps(); 
 }
 if (mode == 3){
  runTimer(); 
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

/*void accelerometer(){
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
}*/

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
  generic_bar_display ("oil", 3500, reading, temp_peak, 2600, 0);
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
  generic_dual_display ("F 1", 1024, reading1, temp1_peak, 9999, 0, "F 2", 3500, reading2, temp2_peak, 1000, 0);
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

//calculated for use with 0-150 psi sender from isspro with 240-33 ohm range using a 100 ohm resistor as R1
long lookup_oil_psi(long psival){
   if (psival > 723){
     return (0);
   }
   if (psival < 257){
     return(9999);
   }
   if ((psival <= 723)&&(psival > 619)) {
     return(psival*361)/1000 + 260;
   } 
   if ((psival <= 619)&&(psival > 520)) {
     return(psival*379)/1000 + 272;
   }
   if ((psival <= 520)&&(psival > 411)) {
     return(psival*344)/1000 + 254;     
   }
   if ((psival <= 411)&&(psival > 257)){
     return(psival*244)/1000 + 213;
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
  float frtrn = (((float)top/(float)158)*100);  //158Vint jumps are 1g
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
void generic_bar_display(char title[ ], long high, long cur_value, long peak, long hiWarn, long loWarn){
 Serial.print(0xFE, BYTE);  
 Serial.print(128, BYTE);
  Serial.print(title);
  Serial.print(" ");
  Serial.print(cur_value/10);
  Serial.print(".");
  Serial.print(cur_value%10);
  int ndigits = numberofdigits(cur_value) + 1;
  if (ndigits <= 2){ ndigits = ndigits + 1;}
  for (int i = 0; i < 5 - ndigits; i++) {
   Serial.print(" "); 
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
  delay(60);
}


//use only 4 char titles (should be changed soon)
void generic_dual_display (char title1[ ], long high1, long cur_value1, long peak1, long loWarn1, long hiWarn1, char title2[ ], long high2, long cur_value2, long peak2, long loWarn2, long hiWarn2){
 Serial.print(0xFE, BYTE);  
 Serial.print(128, BYTE);
  Serial.print(title1);
  Serial.print(" ");
  Serial.print(cur_value1/10);
  Serial.print(".");
  Serial.print(cur_value1%10);
  int ndigits = numberofdigits(cur_value1) + 1;
  if (ndigits <= 2){ ndigits = ndigits + 1;}
  for (int i = 0; i < 5 - ndigits; i++) {
   Serial.print(" "); 
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
  if ( (cur_value1 > loWarn1) || (cur_value1 < hiWarn1) ){ //blink if warning threshold is met
    warn_flash();
  }
   Serial.print(0xFE, BYTE);   
   Serial.print(192, BYTE);  
  Serial.print(title2);
  Serial.print(" ");
  Serial.print(cur_value2/10);
  Serial.print(".");
  Serial.print(cur_value2%10);
  ndigits = numberofdigits(cur_value2) + 1;
  if (ndigits <= 2){ ndigits = ndigits + 1;}
  for (int i = 0; i < 5 - ndigits; i++) {
   Serial.print(" "); 
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
  if ( (cur_value2 > loWarn2) || (cur_value2 < hiWarn2) ){ //blink if warning threshold is met
     warn_flash();
  }
  delay(60);
}

//quad display -- mus use 4 char (incl ":") for each title...ex "PSI:", "TEMP", "POOP", " ETC"
//void generic_quad_display(char title1[], unsigned long reading1, unsigned long warn1, char title2[], unsigned long reading2, unsigned long warn2, char title3[], unsigned long reading3, unsigned long warn3, char title4[], unsigned long reading4, unsigned long warn4){
 //Serial.print(0xFE, BYTE);  
 //Serial.print(128, BYTE);
//  Serial.print(title1);
  
//}

void warn_flash(){
  Serial.print(0x7C, BYTE);  
  Serial.print(128, BYTE);  //backlight off
  digitalWrite(piezoTriggerPin, HIGH);
  delay(300);
  digitalWrite(piezoTriggerPin, LOW);
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


//Fullerton requested functions 

//startup mode 0 DONE
//00:00:00 continuous from startup
//Oil XXX.Xf
//after reaching set temp flash for 10 seconds then go to mode 1
void startupTimerAndOil(){
  meter_splash("Startup Meter", "Timer/Oil");
  if (startuptempswitch == false){
     while (digitalRead(buttonApin) == LOW){}
   }
   while(digitalRead(buttonApin) == HIGH){
   if (digitalRead(buttonBpin) == LOW) {
    temp_peak = 0;
   }
   int reading = lookup_oil_temp(analogRead(tempPin));

   if ((startuptempswitch == false) && (reading > 145)){
    mode = 2;
    return;
   }
   temp_peak = max (temp_peak, reading); 
   //select the first line
   Serial.print(0xFE, BYTE);   
   Serial.print(128, BYTE);  
   //timer display
     unsigned long T = millis();
     Serial.print(0xFE, BYTE);   
     Serial.print(128, BYTE); 
     unsigned long Tmillis = T%1000/10;
     unsigned long Tseconds = T%60000/1000;
     unsigned long Tminutes = T%3600000/60000;
     unsigned long Thours = T/3600000;
     Serial.print("  ");
     printInTens(Thours);
     Serial.print(":");
     printInTens(Tminutes);
     Serial.print(":");
     printInTens(Tseconds);
     Serial.print(".");
     printInTens(Tmillis);
   
   //select the second line
   Serial.print(0xFE, BYTE);  
   Serial.print(192, BYTE); 
   //oil temp display
   Serial.print("OilTemp: ");
   int Toil = lookup_oil_temp(analogRead(tempPin));
   Serial.print(Toil/10);
   Serial.print(".");
   Serial.print(Toil%10);
   //check to see if it's past the set point for switch
   if ( ((startuptempswitch == false) && (reading > 145))){
    mode = 1; 
    return; 
   }
   
   }
   while(digitalRead(buttonApin) == LOW){}
   delay(20);
}

//mode 1 TODO: add 
//-------|-------- gmeter w/peaks
//Oil: xxx.x/xxx.x
//check and flash when X warning temp has been reached
void gforceAndAccel(){
  meter_splash("Accelerometer", "Oil Temp");
  while(digitalRead(buttonApin) == HIGH){
     //select the first line
     Serial.print(0xFE, BYTE);   
     Serial.print(128, BYTE);
     printBarGraph(getAccelerometerData(yval));
   
     //select the second line
     Serial.print(0xFE, BYTE);  
     Serial.print(192, BYTE); 
     //oil temp display
     Serial.print("OilT");
     int Toil = lookup_oil_temp(analogRead(tempPin));
     Serial.print(Toil/10);
     Serial.print(".");
     Serial.print(Toil%10);
     //TODO: add peak COPY from below
  }
  while(digitalRead(buttonApin) == LOW){}
  return;
}

//mode 2 TODO: fix digit spacing on both lines
//I xxx.x O xxx.x
//OTxxx.x OPxxx.x
void allTemps(){
  int currentT = 0;
  meter_splash("IC Temp", "Oil Temp/Psi");
  int inTemp = 0;
  int outTemp = 0;
  while(digitalRead(buttonApin) == HIGH){
     //select the first line
     Serial.print(0xFE, BYTE);   
     Serial.print(128, BYTE);
     Serial.print("I ");
     inTemp = (lookup_temp(analogRead(t1pin)));
     Serial.print(inTemp/10);
     Serial.print(".");
     Serial.print(inTemp%10);
     Serial.print(" O ");
     outTemp = (lookup_temp(analogRead(t2pin))); 
     Serial.print(outTemp/10);
     Serial.print(".");
     Serial.print(outTemp%10);
     
     //select the second line
     Serial.print(0xFE, BYTE);  
     Serial.print(192, BYTE); //select line
     int cur_value1 = lookup_oil_temp(tempPin);
     int cur_value2 = lookup_oil_psi(oilPsiPin);
     Serial.print("OT");
     Serial.print(cur_value1/10);
     Serial.print(".");
     Serial.print(cur_value1%10);
     Serial.print(" ");
     Serial.print("OP");
     Serial.print(cur_value2/10);
     Serial.print(".");
     Serial.print(cur_value2%10);
     if ( (cur_value1 > 1400) || (cur_value1 < 10) ) { //blink if warning threshold is met
      warn_flash();
     }
     if ( (cur_value2 > 1400) || (cur_value2 < 10) ){
      warn_flash(); 
     }
  }
  while(digitalRead(buttonApin) == LOW){}
  return;
}

//mode 3
//like standard timer
//will later dual button stuff later
//--hold both to switch modes (continual timing)
//--hit a to start and stop T1--hold to reset
//--hit b to start and stop T2--hold to reset
//see runTimer();

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

