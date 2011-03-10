#include <AFSoftSerial.h>
//short version with only accel and temp display
//all readings are spewed to hardware serial, all you have to 
//do is listen

//lcd is using soft serial

//multi mode selection via the "A" button

#define rxPin 2
#define txPin 3


AFSoftSerial vSerial = AFSoftSerial(rxPin, txPin);

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

int mode = 1; 
int buttonApin = 10;
int buttonBpin = 13;

int t1pin = 2;
int t2pin = 3;

long tempmillisT1 = 0;
long tempmillisT2 = 0;

//global peaks...so that you can switch modes and preserve peaks
long temp1_peak = 0;
long temp2_peak = 0;

  
void setup(){
  vSerial.begin(9600);
  Serial.begin(9600);
  delay(10);

   vSerial.print(0xFE, BYTE);   //selects the first line
   vSerial.print(128, BYTE);  
   vSerial.print("----Welcome-----"); //change this to the users greeting...also useful as a LCD communication test
   vSerial.print(0xFE, BYTE);  
   vSerial.print(192, BYTE); //selects the second line
   vSerial.print("robotmeter.com"); //line two of the users splash screen
   delay(4000);  //how long to delay on the startup screen.  
 
  vSerial.print(0x7C, BYTE);  
  vSerial.print(157, BYTE);   //light level to 157 out of 157
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
  
  vSerial.print(0xFE, BYTE);  
  vSerial.print(0x01, BYTE); //clear LCD
}

void loop (){
  //WHAT MODE
  if (digitalRead(buttonApin) == LOW){
    while (digitalRead(buttonApin)){
     //avoids flipping modes rapidly
    }
     if (mode == 1){mode=2;}
     else mode = 1;
  }
  //ACCELEROMETER
 if (mode == 2) {
    accelerometer();
 }
 //Engine temps
 if (mode == 1){
  two_temp_meter(); 
 }
 
 //log to hardware serial: x, y, t1, t2
 Serial.print(analogRead(xval));
 Serial.print(",");
 Serial.print(analogRead(yval));
 Serial.print(",");
 Serial.print(analogRead(t1pin));
 Serial.print(",");
 Serial.print(analogRead(t2pin));
 Serial.print("\n");
 
}

void accelerometer(){
    
    int accelx = ( getAccelerometerData (xval) );
    int accely = ( getAccelerometerData (yval) );
 
    pospeakcount++;
    negpeakcount++;
  
    peak(accely);
    vSerial.print(0xFE, BYTE);   //command flag
    vSerial.print(128, BYTE); 
    delay(60);
    printBarGraph(accely);
    vSerial.print(0xFE, BYTE);   
    vSerial.print(192, BYTE);  
    delay(60);
    vSerial.print("x:");
    printAccelerometerReadout(accelx);
    vSerial.print(" y: ");
    printAccelerometerReadout(accely);
}

void two_temp_meter(){ 
 while (digitalRead(buttonApin) == LOW){}
   meter_splash("2 Temp Meter", "");
 long reading1 = 0;
 long reading2 = 0;
 while (digitalRead(buttonApin) == HIGH){
  /*if (digitalRead(buttonBpin) == LOW) {
    temp1_peak = 0;
    temp2_peak = 0;
  }*/
  reading2 = lookup_temp((long)analogRead(t2pin));
  reading1 = lookup_temp((long)analogRead(t1pin));
  //reading1 = analogRead(t1pin);
  temp1_peak = max (temp1_peak, reading1);
  temp2_peak = max (temp2_peak, reading2); 
  generic_dual_display ("F 1", 1400, reading1, temp1_peak, 9999, 0, true, "F 2", 1400, reading2, temp2_peak, 1700, 0, true);
  delay(20);    
 }
 return;
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
    vSerial.print("+");
  }
  if (reading < 0) {
    vSerial.print("-");
  }
  
  int afterdecimal = reading % 100;
  vSerial.print(abs(reading/100));
  if ( (afterdecimal > 9) || (afterdecimal < -9) ){
    vSerial.print(".");
  }
  else {
    vSerial.print(".0");
  }
  vSerial.print(abs(afterdecimal));
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

//use only 4 char titles (should be changed soon)
void generic_dual_display (char title1[ ], long high1, long cur_value1, long peak1, long hiWarn1, long loWarn1, boolean hilo1, char title2[ ], long high2, long cur_value2, long peak2, long hiWarn2, long loWarn2, boolean hilo2){
  int ndigits = 0;
  vSerial.print(0xFE, BYTE);  
  vSerial.print(128, BYTE);
  vSerial.print(title1);
  vSerial.print(" ");
  if ( (hilo1 == true) && (cur_value1 == 0) ){
   vSerial.print("LOW  "); 
  }
  else if ( (hilo1 == true) && (cur_value1 == 9999) ){
   vSerial.print("HIGH "); 
  }
  else {
    vSerial.print(cur_value1/10);
    vSerial.print(".");
    vSerial.print(cur_value1%10);
    ndigits = numberofdigits(cur_value1) + 1;
    if (ndigits <= 2){ ndigits = ndigits + 1;}
    for (int i = 0; i < 5 - ndigits; i++) {
     vSerial.print(" "); 
    }
  }
  vSerial.print("/");
  ndigits = numberofdigits(peak1) + 1;
  if (ndigits <= 2){ ndigits = ndigits + 1;}
  for (int i = 0; i < 6 - ndigits; i++){
   vSerial.print(" "); 
  }
  vSerial.print(peak1/10);
  vSerial.print(".");
  vSerial.print(peak1%10);
  if ( (cur_value1 > hiWarn1) || (cur_value1 < loWarn1) ){ //blink if warning threshold is met
    warn_flash();
  }
   vSerial.print(0xFE, BYTE);   //select the second line
   vSerial.print(192, BYTE);  
  vSerial.print(title2);
  vSerial.print(" ");
  if ( (hilo2 == true) && (cur_value2 == 0) ){
    vSerial.print("LOW  ");
  }
  else if ( (hilo2 == true) && (cur_value2 == 9999) ){
    vSerial.print("HIGH ");
  }
  else {
    vSerial.print(cur_value2/10);
    vSerial.print(".");
    vSerial.print(cur_value2%10);
    ndigits = numberofdigits(cur_value2) + 1;
    if (ndigits <= 2){ ndigits = ndigits + 1;}
    for (int i = 0; i < 5 - ndigits; i++) {
     vSerial.print(" "); 
    }
  }
  vSerial.print("/");
  ndigits = numberofdigits(peak2) + 1;
  if (ndigits <= 2){ ndigits = ndigits + 1;}
  for (int i = 0; i < 6 - ndigits; i++){
   vSerial.print(" "); 
  }
  vSerial.print(peak2/10);
  vSerial.print(".");
  vSerial.print(peak2%10);
  if ( (cur_value2 > hiWarn2) || (cur_value2 < loWarn2) ){ //blink if warning threshold is met
     warn_flash();
  }
  delay(100);
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

void warn_flash(){
  vSerial.print(0x7C, BYTE);  
  vSerial.print(128, BYTE);  //backlight off
  vSerial.print(0x7C, BYTE);  
  vSerial.print(157, BYTE);  //backlight on
  delay(300);
}


