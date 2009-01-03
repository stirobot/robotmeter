//resets the serial LCD to its factory settings
//Leave power to the LCD unpluged
//turn on arduino (ie plug it into USB)
//turn on serial monitor on arduino IDE
//once you see the control r character being sent plug in the power to the LCD

void setup(){
 Serial.begin(9600);
}

void loop(){
 //Serial.print(0x7C, BYTE);  //special character
 Serial.print(0x12, BYTE);  //reset character
 //delay(50); 
}
