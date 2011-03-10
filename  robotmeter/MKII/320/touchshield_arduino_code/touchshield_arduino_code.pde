//code for arduino to use with touchshield and other programs
//pulls data from sensors and reports it across serial based on a handshake

#include <AFSoftSerial.h>

#define rxPin 3
#define txPin 2

AFSoftSerial vSerial = AFSoftSerial(rxPin, txPin);

int rtsPin = 4;
int ctsPin = 5;

int xval = 4;
int yval = 5;
int zerogy = 512;
int zerogx = 512;

//int sprayTriggerPin = 11;
//int piezoTriggerPin = 9;

int t1pin = 2;
int t2pin = 3;
int tempPin = 1;
int boostPin = 0;

float boost;
float oilT;
float t1;
float t2;
float x;
float y;

  
void setup(){
  //setup connection to tsshield
  vSerial.begin(9600);
  while(vSerial.read() != 'U'){}
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
    //full pull
  char readS = vSerial.read();
    if (readS == 'F'){  
      //boost = lookup_boost(analogRead(boostPin));
      boost = analogRead(boostPin);
      oilT = lookup_oil_temp(analogRead(tempPin));
      t1 = lookup_temp(analogRead(t1pin));
      t2 = lookup_temp(analogRead(t2pin));
      sendFloat(t1);
      sendFloat(t2);
      sendFloat(boost);
      sendFloat(oilT);

    }
    //xydisplay
    if (readS == 'X'){
      x = getAccelerometerData (xval);
      //y = getAccelerometerData (yval);  
      sendFloat(x);
      //sendFloat(y);
    }
    return;
}

void sendFloat(float sendVar){
  sendVar = sendVar * 10;
  int sendV = (int)sendVar;
  //TODO: change to using ints with * 10
  
  
  /*unsigned char lowByte, highByte;
  unsigned int val;
  //set val to something
  char firstByte = (unsigned char)val;
  char secondByte = (unsigned char)(val >> 8);
  char thirdByte = (unsigned char)(val >> 16);
  char fourthByte = (unsigned char)(val >> 24);
  vSerial.print(firstByte);
  delay(1);
  vSerial.print(secondByte);
  delay(1);
  vSerial.print(thirdByte);
  delay(1);
  vSerial.print(fourthByte);*/
  char lowByte = (unsigned char)sendV;
  char highByte = (unsigned char)(sendV >> 8);
  vSerial.print(highByte);
  //delay(1);
  vSerial.print(lowByte);
  delay(10);
  //while(vSerial.read() != 'C'){} //check for clear signal before sending next
  //vSerial.print('C');
  return;
}

//correctly changed for float values
float lookup_boost(int boost){
  //boost = ( (boost-106000) / 259000 );
  // boost = ( (( boost * 398) / 1000) + 2); //2 is the y intercept
  //398 changed to 378 for slope...because slope was too steep
  float fboost = ( (( (float)boost * 378.0) / 1000.0) - 4.0)/10.0; //get rid of the divide by ten when adding decimals on display
  return fboost;
}

//code for defi/nippon-seiki temp sender  
float lookup_oil_temp(int tval){
  float ftval = (float)tval;
  if (tval <= 200){
    return 0.0;
  }
  
  if (tval > 200 && tval <= 315){
    return .37 * ftval + 47.74;
    //return (37 * tval + 4774);
  }
  
  if (tval > 315 && tval <= 477){
    return .28 * ftval + 71.3;
    //return (28 * tval + 7130);
  }
  
  if (tval > 477 && tval <= 790){
    return .33 * ftval + 35.59;
    //return (33 * tval + 3559);
  }
  
  if (tval > 790){
    return 999.9;
  } 
  
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


