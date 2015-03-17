#How to use the character display from the MKI

##### Displays #####

The LCD I've chose to use is the [Sparkfun serial enabled LCD](http://www.sparkfun.com/commerce/product_info.php?products_id=812).  This is a singe communications wire LCD that accepts simple text and commands.  I chose red because it matches my car.  Other colors are available.  In addition the code presented on these pages will work with other serial LCD's with minor modifications.
  * http://www.arduino.cc/playground/Learning/SparkFunSerLCD Arduino playground tutorial for sparkfun serial lcd]
  * http://www.sparkfun.com/datasheets/LCD/SerLCD_V2_5.PDF Serial backpack specifications]
  * http://www.arduino.cc/playground/Learning/SerialLCD Another serial LCD tutorial]


---

#### Splash between modes ####

A splash screen for switching modes:
```
  void meter_splash(char line1[], char line2[]){
   LCDSerial.print(0xFE, BYTE);   
   LCDSerial.print(0x01, BYTE); //clear
   LCDSerial.print(0xFE, BYTE);  
   LCDSerial.print(128, BYTE); //select line 1
   LCDSerial.print(line1);
   LCDSerial.print(0xFE, BYTE);   
   LCDSerial.print(192, BYTE);  //select line 2
   LCDSerial.print(line2); 
   delay(1000);                  //wait
   LCDSerial.print(0xFE, BYTE);   //clear
   LCDSerial.print(0x01, BYTE);
  }
```

#### Generic Dual Display ####
```
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
   Serial.print("HIGH"); 
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
  delay(60);
  }
```

#### Generic Single Display w/bar graph ####
```
  void generic_bar_display(char title[ ], long high, long cur_value, long peak, long hiWarn, long loWarn, boolean hiloswitch){
  int ndigits = 0;
  Serial.print(0xFE, BYTE);  
  Serial.print(128, BYTE);
  Serial.print(title);
  if( (hiloswitch == true) && (cur_value == 0) ){
   Serial.print("LOW  ");
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
  delay(60);
  }
```