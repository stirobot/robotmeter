int piezoTriggerPin=5;
  
  
void setup(){
 pinMode(piezoTriggerPin, OUTPUT);
 
}

void loop(){
  for(int i=1;i<10;i++){
    digitalWrite(piezoTriggerPin, HIGH);
 delayMicroseconds(1432/2);
 digitalWrite(piezoTriggerPin,LOW);
 delayMicroseconds(4000);
  }
  delay(6000);
}

