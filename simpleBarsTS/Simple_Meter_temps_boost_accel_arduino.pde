//code for arduino to use with touchshield and other programs
//pulls data from sensors and reports it across serial based on a handshake

#include <HardwareSensor.h>
#include <Wire.h>

int t1pin = 2;
int t2pin = 3;
int boostPin = 1;
int xval = 4;
int yval = 5;

void setup(){
  //setup connection to tsshield
  Sensor.begin(19200);
}

void loop (){

  Sensor.print("x", analogRead(xval) );
  Sensor.print("y", analogRead(yval) );
  Sensor.print("t1", analogRead(t1pin) );
  Sensor.print("t2", analogRead(t2pin) );
  Sensor.print("bt", analogRead(boostPin) );
}



