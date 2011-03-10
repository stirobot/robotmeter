//simple boost guage useing sparkfun 4 digit 7 segment display and
//a freescale (motorola) MPX4250GP

void setup(){
  Serial.begin(9600);
  delay(10);
  Serial.print("v");
  //display "trbo"
  Serial.print("TRBO");
  delay(800);
  
  //display "psi"
  Serial.print("xBST");  
  delay(800);  
  Serial.print("xxxx"); //blank display x = blank space
  
    Serial.print("v");
  //display "trbo"
  Serial.print("TRBO");
  delay(800);
  
  //display "psi"
  Serial.print("xBST");  
  delay(800);  
  Serial.print("xxxx"); //blank display x = blank space
  
  //turn on the decimal point
  Serial.print(0x77,BYTE);//command character
  Serial.print(B00000010, BYTE); //the decimal
}

int boostpin = 0;
int buttonpin = 7;
int buttonstate = 0;

int psi = 0000;
//one variable for each numeral that will be printed
int tens = 0;
int ones = 0;
int first_dec = 0;
int second_dec = 0;

int warningpsi = 2000;
int peakpsi = 0;

void loop(){
  /*buttonstate = digitalRead(buttonpin);
  if (buttonstate == HIGH){
    display_peak();
  }*/
  delay(20);
  //lookup the boost
  //psi = lookup_boost(analogRead(boostpin));
  psi = analogRead(boostpin);
  //psi = psi + 1;
  if (psi>peakpsi){peakpsi=psi;} //update the peak if necessary
  tens = (int)psi / 1000;
  ones = (int)psi % 1000 / 100;
  first_dec = (int)psi % 100 / 10;
  second_dec = (int)psi % 10;
  
  if ( ( (int)psi/1000) == 0){Serial.print("x");}
  if ( ( (int)psi/100) == 0){Serial.print("x");}
  if ( ( (int)psi/10) == 0){Serial.print("x");}
  if ( ( (int)psi) == 0){Serial.print("x");}
  Serial.print(psi);
  
  if (psi > warningpsi){
    Serial.print("xxxx");
    delay(45);
    Serial.print(psi);
    //could also add peizo call here
  }

}

long lookup_boost(long boost){
  //boost = ( (boost-106000) / 259000 );
  // boost = ( (( boost * 398) / 1000) + 2); //2 is the y intercept
  //398 changed to 378 for slope...because slope was too steep
  boost = ( (( boost * 378) / 1000) - 4)/10; //get rid of the divide by ten when adding decimals on display
  return boost;
}

void display_peak(){
  if ( ( (int)peakpsi/1000) == 0){Serial.print("x");}
  if ( ( (int)peakpsi/100) == 0){Serial.print("x");}
  if ( ( (int)peakpsi/10) == 0){Serial.print("x");}
  if ( ( (int)peakpsi) == 0){Serial.print("x");}
  Serial.print(peakpsi);
  delay(5000);
}
