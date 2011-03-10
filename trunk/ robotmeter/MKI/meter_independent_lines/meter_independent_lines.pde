//kitchen sink accelerometer and car gauge meter
//independent line version

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
int buttonBpin = 13;
int buttonBval = HIGH;

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
long temp_peak = 0;
long temp1_peak = 0;
long temp2_peak = 0;

int major_mode = 0; //0=independent_lines, 1=timer, 2=usb logging
int topmode=2; int bottommode=0;
//minor modes: 0=matching_bargraph, 1=accelerometer, 2=oil temp, 3=boost, 4=temp1, 5=temp2

void setup(){
  //setup the accelerometer and screen
  Serial.begin(9600);
  backlightOn(); 
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
 if ( (digitalRead(buttonApin) == LOW)  || (digitalRead(buttonBpin) == LOW) ){
   while ( (digitalRead(buttonApin) == LOW)  || (digitalRead(buttonBpin) == LOW) ){
     //sit until the buttons are released
   }   
 }
 
 if (major_mode == 0){
   display();
 }
 if (major_mode == 1){
   runTimer();
 }
 if (major_mode == 2){
   usb_logger();
 }
 
}

void display(){
  int reading = 0;
  while (true){
    //dual button press gets a major mode change
    //single button press gets a minor mode change
    //single hold resets peaks on that line
    if (digitalRead(buttonApin) == LOW){
      int holdmillis = millis();
      while (digitalRead(buttonApin)==LOW){
        if (digitalRead(buttonBpin) == LOW){
         //dual buttons - go to main
         major_mode == 1;
         return; 
        }
        if ((millis()-holdmillis) > 3000){
          //if button is held reset the peak of this line
        }
      }
      //after the button is release w/o another button pressed...change the line specific mode
      if (topmode==5){topmode=0;}
      else topmode++;
    }
    //TODO: finish above and copy/mod for buttonB
    
    //do the display
    selectLineOne();
    if ((topmode==0) && (bottommode==0)){
      topmode==1;
    }
    if (topmode==0){
     bardisplay(); 
    }
    else if (topmode==1){
      accelerometerdisplay();
    }
    else if (topmode==2){
      reading = lookup_oil_temp(analogRead(tempPin));
      if ((startuptempswitch == false) && (reading > 145)){
       topmode=1;
       bottommode=0;
       startuptempswitch = true;
      }
      temp_peak = max (temp_peak, reading);
      regdisplay("oil", reading, temp_peak, 260);
    }
    else if (topmode==3){
      reading = lookup_boost(analogRead(boostPin));
      boost_peak = max (boost_peak, reading);
      regdisplay("psi", reading, boost_peak, 15);
    }
    else if (topmode==4){
      reading = lookup_temp(analogRead(t1pin));
      temp2_peak = max (temp1_peak, reading);
      regdisplay("tmp1", reading, temp1_peak, 300);
    }
    else if (topmode==5){
      reading = lookup_temp(analogRead(t2pin));
      temp2_peak = max (temp2_peak, reading);
      regdisplay("tmp2", reading, temp2_peak, 300);
    }
    
    selectLineTwo();
    if ((topmode==0) && (bottommode==0)){
      bottommode==1; 
    }
    if (bottommode==0){
      bardisplay(); 
    }
    else if (bottommode==1){
      accelerometerdisplay();
    }
    else if (bottommode==2){
      reading = lookup_oil_temp(analogRead(tempPin));
      temp_peak = max (temp_peak, reading);
      regdisplay("oil", reading, temp_peak, 260);
    }
    else if (bottommode==3){
      reading = lookup_boost(analogRead(boostPin));
      boost_peak = max (boost_peak, reading);
      regdisplay("psi", reading, boost_peak, 15);
    }
    else if (bottommode==4){
      reading = lookup_temp(analogRead(t1pin));
      temp2_peak = max (temp1_peak, reading);
      regdisplay("tmp1", reading, temp1_peak, 300);
    }
    else if (bottommode==5){
      reading = lookup_temp(analogRead(t2pin));
      temp2_peak = max (temp2_peak, reading);
      regdisplay("tmp2", reading, temp2_peak, 300);
    }
    
  }
}

void regdisplay(char title[ ], long cur_value, long peak, long warn){
  //displays the var selected in the format name: curr  / peak
  Serial.print(title);
  Serial.print(":");
  Serial.print(cur_value);
  int ndigits = numberofdigits(cur_value);
  for (int i = 0; i < 5 - ndigits; i++) {
   Serial.print(" "); 
  }
  Serial.print("/");
  ndigits = numberofdigits(peak);
  for (int i = 0; i < 5 - ndigits; i++){
   Serial.print(" "); 
  }
  Serial.print(peak);
  if (cur_value > warn){ //blink if warning threshold is met
    selectLineOne();
    delay(300);
    Serial.print ("                ");
    
    //beep if piezo present...add code
    //add warning led if present...add code
  }
}

void bardisplay(){
  int high = 16;
  int cur_value = 0;
  //displays the horizontal bar graph
  if ( (topmode==1)||(bottommode==1) ){
    accelerometergraph();
  }
  if ( (topmode==2) || (bottommode==2) ){
    high = 350;
    cur_value=lookup_oil_temp(analogRead(tempPin));
  }
  if ( (topmode==3) || (bottommode==3) ){
    high = 20;
    cur_value=lookup_boost(analogRead(boostPin));
  }
  if ( (topmode==4) || (bottommode==4) ){
    high = 350;
    cur_value=lookup_temp(analogRead(t1pin));
  }
  if ( (topmode==5) || (bottommode==5) ){
    high = 350;
    cur_value=lookup_temp(analogRead(t2pin));
  }
  //do the actual display
  unsigned long abar = high/16;
  unsigned long n_bars = cur_value/abar;
  if (cur_value <= 0){n_bars=0;}
  for(int i=1; i< n_bars; i++){ 
     Serial.print(0xFF, BYTE);
  }
  for (int i=1; i < (16 - n_bars); i++){
     Serial.print(" "); 
  }
}

void accelerometergraph(){
  //displys the centered VU-meter style accelerometer meter
  int accely = ( getAccelerometerData (yval) );
 
  pospeakcount++;
  negpeakcount++;
  
  peak(accely);
  printBarGraph(accely);
}

void accelerometerdisplay(){
  int accely = ( getAccelerometerData (yval) );
  int accelx = ( getAccelerometerData (xval) );
  //displays the accelerometer data itself in y: #.##x: #.## format
  Serial.print("x:");
  printAccelerometerReadout(accelx);
  Serial.print(" y: ");
  printAccelerometerReadout(accely);
}

void test_all_meters(){
/* if (analogRead(tempPin) > 512){ //oil temp
   mode = 1;
   temp_meter();
 } 
 if (analogRead(t1pin) > 512){ //temp1
   mode = 6;
   two_temp_meter();
 }
 if (analogRead(t2pin) > 512){ //temp2
   mode = 6;
   two_temp_meter();
 }
 if ( (lookup_boost(analogRead(boostPin)) - 12) >  14){ //boost
   mode = 3;
   boost_meter();
 }*/
 return;
}

void runTimer(){
  while (digitalRead(buttonApin) == LOW){
   }
  test_all_meters();
  if (timer_state == 0){
    clearLCD();
    selectLineOne(); 
    delay(20);
    Serial.print("T1: 00:00:00.00");
    selectLineTwo();
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
    clearLCD();
    selectLineOne();
    while (digitalRead(buttonBpin) == HIGH){
      test_all_meters();
      //timing
      if (digitalRead(buttonApin) == LOW){
        return;
      }
      clearLCD();
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
      clearLCD();
      //printing to the screen
      print_T1();
      //a short pause
      delay(50);
      
      //display T2 as zeros
      selectLineTwo();
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
      clearLCD();
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
    clearLCD();
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
     selectLineOne();
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
     selectLineTwo();
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


void printInTens(int Tvar){
    if (Tvar < 10){
      Serial.print("0");
      Serial.print(Tvar);
    }
    else Serial.print(Tvar);
    return;
}

void printBarGraph(int y) { 
  //clear the 1st 8 spaces
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
 selectLineOne();
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
  boost = boost * 10;
  return ( (boost-10.6) * 0.0359 );
}

long lookup_oil_temp(long tval){
  tval = tval * 100;
  if (tval <= 11500){
    return (999); 
  }
  if (tval >= 68100){
    return (0);
  }
  if ((tval <= 68000)&&(tval > 39600)){
    return (long)((tval-134266)/(-473));
  }
  if ((tval <= 39600)&&(tval > 28200)){
    return (long)((tval-115600)/(-380));
  }
  if ((tval <= 28200)&&(tval > 19700)){
    return (long)((tval-93366)/(-283));
  }  
  if ((tval <= 19700)&&(tval > 11600)){
    return (long)((tval-54800)/(-135));
  }  
}

long lookup_temp(long tval){
  tval = tval * 100;
  //tval = (long)(tval - (long)117588);
  //return tval;
  if (tval < 8900){
   return (999); 
  }
  if (tval > 96000){
    return (0);
  }
  if ((tval <= 96000)&&(tval > 93221)){
    return ((long)(tval-101577)/(-172));
  }
  if ((tval <= 93221)&&(tval > 89610)){
    return ((tval-104201)/(-226));
  }
  if ((tval <= 89610)&&(tval > 85125)){
    return ((tval-107738)/(-280));
  }
  if ((tval <= 85125)&&(tval > 79139)){
    return ((tval-112264)/(-335));
  }
  if ((tval <= 79139)&&(tval > 70799)){
    return ((tval-117588)/(-388));
  }
  if ((tval <= 70799)&&(tval > 62470)){
    return ((tval-121441)/(-421));
  }
  if ((tval <= 62470)&&(tval > 53230)){
    return ((tval-122367)/(-428));
  }
  if ((tval <= 53230)&&(tval > 43707)){
    return ((tval-118651)/(-405));
  }
  if ((tval <= 43707)&&(tval > 36471)){
    return ((tval-111349)/(-366));
  }
  if ((tval <= 36471)&&(tval > 30685)){
    return ((tval-102232)/(-321));
  }
  if ((tval <= 30685)&&(tval > 24800)){
    return ((tval-9078)/(-270));
  }
  if ((tval <= 24800)&&(tval > 20000)){
    return ((tval-78575)/(-220));
  }
  if ((tval <= 20000)&&(tval > 15851)){
    return ((tval-66507)/(-175));
  }
  if ((tval <= 15851)&&(tval > 12380)){
    return ((tval-55300)/(-137));
  }
  if ((tval <= 12380)&&(tval > 9085)){
    return ((tval-41752)/(-94));
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


void usb_logger(){
 while (digitalRead(buttonApin) == LOW){}
 clearLCD();
 selectLineOne();
 Serial.print("USB Logging");
 selectLineTwo();
 Serial.print("Press B"); 
 while (digitalRead(buttonBpin) == HIGH){
   if (digitalRead(buttonApin)==LOW){
     return;
   }
 }
 delay(500);
 clearLCD();
 Serial.print(0xFE, BYTE);   //command flag
 Serial.print(0x08, BYTE);   //turn off visual display
 Serial.print("Data logger: \n");
 Serial.print("T1, T2, Oil Temp, Boost, x accel, y accel\n"); 
 while (digitalRead(buttonBpin) == LOW){}
 while ( (digitalRead(buttonApin) == HIGH) && (digitalRead(buttonBpin) == HIGH) ){
   //logging output
   //get T1 and convert
   Serial.print( (lookup_temp(analogRead(t1pin))) );
   Serial.print(",");
   //get T2 and convert
   Serial.print( lookup_temp(analogRead(t2pin)) );
   //Serial.print("###");
   Serial.print(",");
   //get oil temp and convert
   //Serial.print( analogRead(tempPin) );
   Serial.print( lookup_oil_temp(analogRead(tempPin)));
   Serial.print(",");
   //get boost and convert
   Serial.print( lookup_boost(analogRead(boostPin)) - 12);
   //Serial.print("###");
   Serial.print(",");
   //get x accel
   Serial.print(getAccelerometerData (xval));
   Serial.print(",");
   //get y accel
   Serial.print(getAccelerometerData (yval));
   Serial.print("\n");
 }
 while ( (digitalRead(buttonApin) == LOW) && (digitalRead(buttonBpin) == LOW) ){}
 Serial.print(0xFE, BYTE);   //command flag
 Serial.print(0x0C, BYTE);   //turn on visual display
 return;
}

//functions from Serial example
void selectLineOne(){  //puts the cursor at line 0 char 0.
   Serial.print(0xFE, BYTE);   //command flag
   Serial.print(128, BYTE);    //position
}
void selectLineTwo(){  //puts the cursor at line 0 char 0.
   Serial.print(0xFE, BYTE);   //command flag
   Serial.print(192, BYTE);    //position
}
void clearLCD(){
   Serial.print(0xFE, BYTE);   //command flag
   Serial.print(0x01, BYTE);   //clear command.
}
void backlightOn(){  //turns on the backlight
    Serial.print(0x7C, BYTE);   //command flag for backlight stuff
    Serial.print(157, BYTE);    //light level.
}
void backlightOff(){  //turns off the backlight
    Serial.print(0x7C, BYTE);   //command flag for backlight stuff
    Serial.print(128, BYTE);     //light level for off.
}
void serCommand(){   //a general function to call the command flag for issuing all other commands   
  Serial.print(0xFE, BYTE);
}
