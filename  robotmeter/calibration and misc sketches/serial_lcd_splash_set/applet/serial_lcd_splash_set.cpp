#include "WProgram.h"
void selectLineOne();
void selectLineTwo();
void clearLCD();
void backlightOn();
void backlightOff();
void serCommand();
//sets LCDSerial lcd splash screen

// 1)make sure tx of lcd is unplugged
// 2)change lines to whatever you want (see below)
// 3)upload sketch to board
// 4)power down board and plug in tx of lcd
// 5)power up board
// 6)reset to test after the screen goes blank (old splash - new splash - blank screen - reset to test)

void setup()
{
  Serial.begin(9600);
  backlightOn();
  selectLineOne();
  //Serial.print(0x7C, BYTE);
  //Serial.print(18, BYTE);  //set to 9600 baud
  delay(50);
  Serial.print("Welcome Ben!");
  delay(50);
  Serial.print(0x7C, BYTE);  
  Serial.print(0x0A, BYTE);  //set the splash
  delay(100);
}

void loop()
{  
   // selectLineOne();
  //toggle the splash screen
  //Serial.print(0x7C, BYTE);
  //Serial.print(9, BYTE);
  //turn the display on
  /*Serial.print(0x7C, BYTE);
  Serial.print(0x0C,BYTE);
  //set to 2 lines
  Serial.print(0x07, BYTE);
  Serial.print(6, BYTE);
  //set to 16 chars wide
  Serial.print(0x07, BYTE);
  Serial.print(4, BYTE);  
  //set to 9600 Baud
  Serial.print(0x07, BYTE);
  Serial.print(13, BYTE);*/ 
  
  //the reset signal
  //Serial.print(0x07, BYTE);
  //Serial.print(18, BYTE); 
  
  clearLCD();
  delay(100);
  selectLineOne();
  Serial.print("W00t!");
  delay(500);

}

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

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

