//code for arduino to use with touchshield and other programs
//pulls data from sensors and reports it across serial based on a handshake

#include <HardwareSensor.h>
#include <Wire.h>

int xval = 4;
int yval = 5;
int zerogy = 512;
int zerogx = 512;

int t1pin = 2;
int t2pin = 3;
int boostPin = 0;

float boost;
float t1;
float t2;
float x;
float y;


void setup(){
  //setup connection to tsshield
  Sensor.begin(19200);
  zeroAccelerometer();
}

void zeroAccelerometer(){
  //zero the accelerometer on startup
  int tempreading = analogRead(yval);
  if ((tempreading < 800) && (tempreading > 200)){
    zerogy = tempreading;
  }
  else {
    zerogy = 512;
  }
  tempreading = analogRead(xval);
  if (true) { 
    zerogx = tempreading;
  }
  else {
    zerogx = 512;
  }
}

void loop (){
  //listen for queries from tsshield

  //boost = lookup_boost(analogRead(boostPin));
  boost = lookup_boost(analogRead(boostPin));
  t1 = lookup_temp(analogRead(t1pin));
  t2 = lookup_temp(analogRead(t2pin));
  x = getAccelerometerData(xval);
  y = getAccelerometerData(yval);
  Sensor.print("x", x);
  Sensor.print("y", y);
  Sensor.print("t1", t1);
  Sensor.print("t2", t2);
  Sensor.print("bt", boost);
}


//correctly changed for float values
float lookup_boost(int boost){
  //boost = ( (boost-106000) / 259000 );
  // boost = ( (( boost * 398) / 1000) + 2); //2 is the y intercept
  //398 changed to 378 for slope...because slope was too steep
  float fboost = ( (( (float)boost * 378.0) / 1000.0) - 4.0)/10.0; //get rid of the divide by ten when adding decimals on display
  return fboost;
}

//correctly converted to float values
float lookup_temp(int tval){
  float ftval = (float)tval;
  if (tval < 89){
    return (999.9); 
  }
  if (tval > 960){
    return (0.0);
  }
  if ((tval <= 960)&&(tval > 932)){
    return (((ftval-1015.77))/(-1.72));
  }
  if ((tval <= 932)&&(tval > 896)){
    return (((ftval-1042.01))/(-2.26));
  }
  if ((tval <= 896)&&(tval > 851)){
    return (((ftval-1077.38))/(-2.80));
  }
  if ((tval <= 851)&&(tval > 791)){
    return (((ftval-1122.64))/(-3.35));
  }
  if ((tval <= 791)&&(tval > 707)){
    return (((ftval-1175.88))/(-3.88));
  }
  if ((tval <= 707)&&(tval > 624)){
    return (((ftval-1214.41))/(-4.21));
  }
  if ((tval <= 624)&&(tval > 532)){
    return (((ftval-1223.67))/(-4.28));
  }
  if ((tval <= 532)&&(tval > 437)){
    return (((ftval-1186.51))/(-4.05));
  }
  if ((tval <= 437)&&(tval > 364)){
    return (((ftval-1113.49))/(-3.66));
  }
  if ((tval <= 364)&&(tval > 306)){
    return (((ftval-1022.32))/(-3.21));
  }
  if ((tval <= 306)&&(tval > 248)){
    return (((ftval-90.78))/(-2.70));
  }
  if ((tval <= 248)&&(tval > 200)){
    return (((ftval-785.75))/(-2.20));
  }
  if ((tval <= 200)&&(tval > 158)){
    return (((ftval-665.07))/(-1.75));
  }
  if ((tval <= 158)&&(tval > 123)){
    return (((ftval-553.00))/(-1.37));
  }
  if ((tval <= 123)&&(tval > 90)){
    return (((ftval-417.52))/(-.94));
  }
}

//correctly converted to use float values
float getAccelerometerData (int axis){
  int zerog = 512;
  if (axis == 4){
    zerog = zerogx; 
  }  
  if (axis == 5){
    zerog = zerogy;
  }

  int rc = analogRead(axis);
  int top =( (zerog - rc) ) ; 
  float frtrn = ((float)top/(float)158);  //158Vint jumps are 1g for the ADXL213AE (original accel)
  //154Vint jumps are 1g for the ADXL322 (updated one)
  return frtrn;
}



