#include "WProgram.h"
void setup();
void loop();
int piezoTriggerPin=5;
  
  
void setup(){
 pinMode(piezoTriggerPin, OUTPUT);
 
}

void loop(){
  for(int i=1;i<100;i++){
    digitalWrite(piezoTriggerPin, HIGH);
 delayMicroseconds(1432/2);
 digitalWrite(piezoTriggerPin,LOW);
 delayMicroseconds(4000);
  }
  delay(6000);
}


int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

