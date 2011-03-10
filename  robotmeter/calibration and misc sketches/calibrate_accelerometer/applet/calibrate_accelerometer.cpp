//use this to calibrate new accelerometers
//spams output to serial and serial LCD to test LCD's

//#include <SoftwareSerial.h> 
//#define rxPin 4
//#define txPin 5

/*SoftwareSerial LCDSerial =  SoftwareSerial(rxPin, txPin);
byte pinState = 0;
*/
  #include "WProgram.h"
void setup();
void loop();
int calc (int val);
int xpin = 4;
  int ypin = 5;

void setup(){
  /*pinMode(rxPin, INPUT);
  pinMode(txPin, OUTPUT);
  LCDSerial.begin(9600);
  LCDSerial.print(0x7C, BYTE);  
  LCDSerial.print(150, BYTE); */
  Serial.begin(9600);
  pinMode(4, INPUT);
  pinMode(5, INPUT);

  delay(100);
  Serial.print("begin");
}

void loop(){
  int xval = analogRead(xpin);
  int yval = analogRead(ypin);
 /* selectLineOne();
  //raw 0-1024 value
  LCDSerial.print("X:");
  LCDSerial.print(xval);
  LCDSerial.print("Y:");
  LCDSerial.print(yval);
  //calculated value
  selectLineTwo();
  LCDSerial.print("X:");
  LCDSerial.print(calc(xval));
  LCDSerial.print("Y:");
  LCDSerial.print(calc(yval));
  */
  Serial.print("X: ");
  Serial.print((xval));
  Serial.print("/");
  Serial.print(calc(xval));
  
  Serial.print("\n");
  
  Serial.print("Y: ");
  Serial.print(yval);
  Serial.print("/");
  Serial.print(calc(yval));
  
  Serial.print("\n");
  
  delay(300);
}

int calc (int val){
  val = 512 - val;
  float frtrn = (((float)val/(float)154)*100);  //156Vint jumps are 1g
  val = (int)frtrn;
  return val;  
}

/*void selectLineOne(){  //puts the cursor at line 0 char 0.
   LCDSerial.print(0xFE, BYTE);   //command flag
   LCDSerial.print(128, BYTE);    //position
}
void selectLineTwo(){  //puts the cursor at line 0 char 0.
   LCDSerial.print(0xFE, BYTE);   //command flag
   LCDSerial.print(192, BYTE);    //position
}
void clearLCD(){
   LCDSerial.print(0xFE, BYTE);   //command flag
   LCDSerial.print(0x01, BYTE);   //clear command.
}
void backlightOn(){  //turns on the backlight
    LCDSerial.print(0x7C, BYTE);   //command flag for backlight stuff
    LCDSerial.print(157, BYTE);    //light level.
}
void backlightOff(){  //turns off the backlight
    LCDSerial.print(0x7C, BYTE);   //command flag for backlight stuff
    Serial.print(128, BYTE);     //light level for off.
}
void serCommand(){   //a general function to call the command flag for issuing all other commands   
  LCDSerial.print(0xFE, BYTE);
} */


int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

