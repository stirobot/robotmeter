#include <AFSoftSerial.h>

//boost only gauge...stripped down code...somewhat messy

#define rxPin 2
#define txPin 3


AFSoftSerial vSerial = AFSoftSerial(rxPin, txPin);

int buttonApin = 10;

int boostPin = 0;
int negpeak = 0;
int pospeak = 0;
int pospeakcount = 0;
int negpeakcount = 0;
int reading;
//global peaks...so that you can switch modes and preserve peaks
long boost_peak = 0;
  
void setup(){
  vSerial.begin(9600);
  Serial.begin(9600);
  delay(10);
  
   vSerial.print(0xFE, BYTE);   //selects the first line
   vSerial.print(128, BYTE);  
   vSerial.print("----Welcome-----"); //change this to the users greeting...also useful as a LCD communication test
   vSerial.print(0xFE, BYTE);  
   vSerial.print(192, BYTE); //selects the second line
   vSerial.print(""); //line two of the users splash screen
   /*for (int i=0; i<100; i++){
     play_piezo();
   }*/
   delay(4000);  //how long to delay on the startup screen.  
  vSerial.print(0x7C, BYTE);  
  vSerial.print(157, BYTE);   //light level to 157 out of 157
  //zero the accelerometer...but only for small tilts
  delay(1000);
  
  //setup the buttons as inputs
  pinMode(buttonApin, INPUT);

  vSerial.print(0xFE, BYTE);  
  vSerial.print(0x01, BYTE); //clear LCD
}

void loop (){
  
  while (digitalRead(buttonApin) == LOW){boost_peak=0;}
  reading = lookup_boost( long(analogRead(boostPin)) );
  boost_peak = max (reading, boost_peak); 
  generic_bar_display ("psi", 170, reading, boost_peak, 165, 0, false);
  delay(50);    

}

void printInTens(int Tvar){
    if (Tvar < 10){
      vSerial.print("0");
      vSerial.print(Tvar);
    }
    else vSerial.print(Tvar);
    return;
}

void printBarGraph(int y) { 
  //clear the 1st 8 spacesb
  if ( y >= 0){
    vSerial.print("        ");  
    for(int i=1; i <= y/16; i++){
       vSerial.print(0xFF, BYTE);
    }
    //fill the rest with spacesloo
    for(int i=1; i <= (8-y/16); i++){ 
      vSerial.print(" "); 
    }
  }
  if (y < 0) {
    //1 - print spaces at the beginning
    for (int i=1; i <= (8-abs(y/16)); i++){
      vSerial.print(" "); 
    }
    //2 - print blocks till the middle
    for (int i=1; i <= abs(y/16); i++){
      vSerial.print(0xFF, BYTE);
    }
    //3 - print spaces till the end
    for (int i=1; i<=8; i++){
      vSerial.print(" ");
    }
  }
 
 //print the peaks if there are any
 //negative
 vSerial.print(0xFE, BYTE);  
 vSerial.print(128, BYTE);
 if (negpeak/16 < 0){
   vSerial.print(0xFE, BYTE);
   int npos = 128 + (8 - abs(negpeak/16));
   vSerial.print(npos, BYTE);
   vSerial.print(0xFF, BYTE);
 }
 
 //positive
 if (pospeak/16 > 0){
   vSerial.print(0xFE, BYTE);
   int ppos = 128 + (8 + (pospeak/16));
   vSerial.print(ppos, BYTE);
   vSerial.print(0xFF, BYTE);
 }
  
}

long lookup_boost(long boost){
  //boost = ( (boost-106000) / 259000 );
  // boost = ( (( boost * 398) / 1000) + 2); //2 is the y intercept
  //398 changed to 378 for slope...because slope was too steep
  boost = ( (( boost * 378) / 1000) - 4); ///10; //get rid of the divide by ten when adding decimals on display
  return boost;
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

//positive only value 0 to X
//only 4 char titles (should be changed soon)
//1234567890123456
//TMP 134.5/ 314.5
//psi 14.5 /  14.5 
//oil 1.0  /   1.4
//oil 0.3  /   0.4
void generic_bar_display(char title[ ], long high, long cur_value, long peak, long hiWarn, long loWarn, boolean hiloswitch){
  int ndigits = 0;
  vSerial.print(0xFE, BYTE);  
  vSerial.print(128, BYTE);
  vSerial.print(title);
  if( (hiloswitch == true) && (cur_value == 0) ){
   vSerial.print(" LOW ");
  } 
  else if ( (hiloswitch == true) && (cur_value == 9999) ){
   vSerial.print(" HIGH"); 
   cur_value = high;
  }
  else {
    vSerial.print(" ");
    vSerial.print(cur_value/10);
    vSerial.print(".");
    vSerial.print(cur_value%10);
    ndigits = numberofdigits(cur_value) + 1;
    if (ndigits <= 2){ ndigits = ndigits + 1;}
    for (int i = 0; i < 5 - ndigits; i++) {
     vSerial.print(" "); 
    }
  }
  vSerial.print("/");
  ndigits = numberofdigits(peak) + 1;
  if (ndigits <= 2){ ndigits = ndigits + 1;}
  for (int i = 0; i < 6 - ndigits; i++){
   vSerial.print(" "); 
  }
  vSerial.print(peak/10);
  vSerial.print(".");
  vSerial.print(peak%10);
  if ( (cur_value > hiWarn) || (cur_value < loWarn) ){ //blink if warning threshold is met
    warn_flash();
  }
   vSerial.print(0xFE, BYTE);   
   vSerial.print(192, BYTE);  
  unsigned long abar = high/16;
  unsigned long n_bars = cur_value/abar;
  if (cur_value <= 0){n_bars=0;}
  for(int i=1; i< n_bars; i++){ 
     vSerial.print(0xFF, BYTE);
  }
  for (int i=1; i < (16 - n_bars); i++){
     vSerial.print(" "); 
  }
  delay(100); //gauge refresh rate in ms
}

void warn_flash(){
  vSerial.print(0x7C, BYTE);  
  vSerial.print(128, BYTE);  //backlight off
  
  vSerial.print(0x7C, BYTE);  
  vSerial.print(157, BYTE);  //backlight on
  delay(300);
}

void meter_splash(char line1[], char line2[]){
   vSerial.print(0xFE, BYTE);   
   vSerial.print(0x01, BYTE); //clear
   vSerial.print(0xFE, BYTE);  
   vSerial.print(128, BYTE); //select line 1
   vSerial.print(line1);
   vSerial.print(0xFE, BYTE);   
   vSerial.print(192, BYTE);  //select line 2
   vSerial.print(line2); 
   delay(1000);                  //wait
   vSerial.print(0xFE, BYTE);   //clear
   vSerial.print(0x01, BYTE);
}

