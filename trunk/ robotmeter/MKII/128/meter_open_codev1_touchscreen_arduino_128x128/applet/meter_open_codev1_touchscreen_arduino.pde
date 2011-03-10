#include <AFSoftSerial.h>
//code for upload to tsshield...takes care of display and mode switching
//not responsible for pulling data from sensors

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

//add usb logger junks

#define rxPin 3
#define txPin 2


AFSoftSerial vSerial = AFSoftSerial(rxPin, txPin);

int logfilecount = 0;

int rtsPin = 4;
int ctsPin = 5;

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

char mode = 'O'; 

int sprayTriggerPin = 11;
int piezoTriggerPin = 9;

int t1pin = 2;
int t2pin = 3;
int tempPin = 1;
int boostPin = 0;

int timer_state = 0;
long tempmillisT1 = 0;
long tempmillisT2 = 0;

boolean startuptempswitch = false;

//global peaks...so that you can switch modes and preserve peaks
long boost_peak = 0;
//long oil_psi_peak = 0;
long temp_peak = 0;
long temp1_peak = 0;
long temp2_peak = 0;

int boost;
int oilT;
int t1;
int t2;
int x;
int y;

  
void setup(){
  //setup connection to tsshield
  vSerial.begin(9600);
  while(vSerial.read() != 'U'); //wait until the TouchShield sends a sync character
  
  pinMode(piezoTriggerPin, OUTPUT);
  //Serial.begin(9600);
  //put wait code to look and see if there is a
  //response from the VDIP1.  If there isn't try connecting again
  //Serial.print("IPA");
  //Serial.print(13, BYTE);
  
   /*for (int i=0; i<100; i++){
     play_piezo();
   }*/
   //Important to delay because we need to wait for the vdip to initialize the usb key
   
   //determine what log file number to begin with
  /* .print("DIR");
   .print(13, BYTE);
   delay(1000);  //wait a second
   
   //need to add code to check if there is a disk present
   //if there isn't then skip the read or it will just hang
   
   while(char i = .read()){
     if (i == '%'){
      logfilecount = .read(); 
     }
   }*/
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
 // pinMode(ctsPin, OUTPUT);
 // pinMode(rtsPin, INPUT);
}

void loop (){
  //listen for queries from tsshield
  while(vSerial.read() != 'A'){
    //test_all_meters...but only every 10 seconds
    //depending on what is sent call the correct lookup function
    //boost meter
    if (vSerial.read() == 'B'){
      boost = lookup_boost(boostPin);
      vSerial.print(boost);
    }
    //oil temp meter
    if (vSerial.read() == 'O'){
      oilT = lookup_oil_temp(tempPin);
      vSerial.print(oilT);
    }
    //four bar display or line display
    if (vSerial.read() == 'F'){  
      boost = lookup_boost(boostPin);
      oilT = lookup_oil_temp(tempPin);
      t1 = lookup_temp(t1pin);
      t2 = lookup_temp(t2pin);
      vSerial.print(boost);
      vSerial.print(oilT);
      vSerial.print(t1);
      vSerial.print(t2);
    }
    //xydisplay
    if (vSerial.read() == 'X'){
      x = getAccelerometerData (xval);
      y = getAccelerometerData (yval);  
      vSerial.print(x);
      vSerial.print(y);
    }
  }
  
}

//test all readings and if there is a problem send back a flag
//upon getting a flag the ttshield will switch to the 4 bar display and the 
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
}*/

/*

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

*/

//code for isspro oil temp sender
/*long lookup_oil_temp(long tval){
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
} */

//code for autometer 2258 sender
/*long lookup_oil_temp(long tval){
   tval = tval * 1000
   if (tval <= 84000){
      return (0);
   }
   if (tval >= 854000){
     return (9999);
   }
   if ((tval > 84000) && (tval <= 182860)
     return (long)((tval * 4)/10 + 67400)/100;
   }
   if ((tval > 182860) && (tval <= 290080)
     return (long)((tval * 28)/100 + 89450)/100;
   }
   if ((tval > 290080) && (tval <= 459190)
     return (long)((tval * 24)/100 + 101590)/100;
   }
   if ((tval > 459190) && (tval <= 541800)
     return (long)((tval * 24)/100 + 98580)/100;
   }   
   if ((tval > 541800) && (tval <= 721130)
     return (long)((tval * 28)/100 + 77720)/100;
   } 
   if ((tval > 721130) && (tval <= 853330)
     return (long)((tval * 45)/100 - 46240)/100;
   }    
}*/

//code for defi/nippon-seiki temp sender  
long lookup_oil_temp(long tval){
//FIX DECIMAL PROBLEM...REMEBRE
  if (tval <= 200){
    return 0;
  }
  
  if (tval > 200 && tval <= 315){
    //return .37 * tval + 47.74;
    return (37 * tval + 4774);
  }
  
  if (tval > 315 && tval <= 477){
    //return .28 * tval + 71.3;
    return (28 * tval + 7130);
  }
  
  if (tval > 477 && tval <= 790){
    //return .33 * tval + 35.59;
    return (33 * tval + 3559);
  }
  
  if (tval > 790){
    return 9999;
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
  float frtrn = (((float)top/(float)158)*100);  //158Vint jumps are 1g for the ADXL213AE (original accel)
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

long numberofdigits2(long value){ 
  
 long digits = 1;
 while (value >= 10){
  value /= 10;
  digits++; 
 }
 return digits; 
}

