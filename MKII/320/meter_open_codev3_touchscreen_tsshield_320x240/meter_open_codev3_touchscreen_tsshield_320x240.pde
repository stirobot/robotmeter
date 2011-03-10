#include <HardwareSensor.h>
const float sintable[90] = {
  0.0175,
  0.0349,
  0.0523,
  0.0698,
  0.0872,
  0.1045,
  0.1219,
  0.1392,
  0.1564,
  0.1736,
  0.1908,
  0.2079,
  0.2250,
  0.2419,
  0.2588,
  0.2756,
  0.2924,
  0.3090,
  0.3256,
  0.3420,
  0.3584,
  0.3746,
  0.3907,
  0.4067,
  0.4226,
  0.4384,
  0.4540,
  0.4695,
  0.4848,
  0.5000,
  0.5150,
  0.5299,
  0.5446,
  0.5592,
  0.5736,
  0.5878,
  0.6018,
  0.6157,
  0.6293,
  0.6428,
  0.6561,
  0.6691,
  0.6820,
  0.6947,
  0.7071,
  0.7193,
  0.7314,
  0.7431,
  0.7547,
  0.7660,
  0.7771,
  0.7880,
  0.7986,
  0.8090,
  0.8192,
  0.8290,
  0.8387,
  0.8480,
  0.8572,
  0.8660,
  0.8746,
  0.8829,
  0.8910,
  0.8988,
  0.9063,
  0.9135,
  0.9205,
  0.9272,
  0.9336,
  0.9397,
  0.9455,
  0.9511,
  0.9563,
  0.9613,
  0.9659,
  0.9703,
  0.9744,
  0.9781,
  0.9816,
  0.9848,
  0.9877,
  0.9903,
  0.9925,
  0.9945,
  0.9962,
  0.9976,
  0.9986,
  0.9994,
  0.9998,
  1.0000  };

//TODO: 
//remove LC-1 stuffs


float boost = 0;
float temp1 = 1;
float temp2 = 1;
float accelx = -1.5, accely = -1.5;
float o_x = 160;
float o_y = 160;
float x_peak_neg = 0;
float x_peak_pos = 0;
float y_peak_neg = 0;
float y_peak_pos = 0;
float o_endy, o_endx;

float o_boost = 0; 

COLOR gaugeRed = {
  224, 38, 41};
COLOR greenLine = {
  26, 255, 26};
COLOR redLine = {
  255, 26, 26};
COLOR yellowLine = {
  255, 255, 26};
COLOR purpleLine = {
  77, 26, 128};
COLOR mwhite = {
  255, 255, 255};
COLOR mblack = {
  0, 0, 0};
COLOR lightBlue = {
  204, 204, 255};

//colors for bar graphs
COLOR fadedRed = {
  255, 102, 102};
COLOR fadedGreen = {
  153, 225, 153};
COLOR fadedYellow = {
  255, 255, 51};

POINT m_point;

//largeNum myFont = largeNum();
boolean timermode = 0; //0 = stopped at 0, 1 = running
int timerStartMillis = 0;
int timerStoppedMillis = 0;

int maxBoost = 20;
int maxT1 = 300;
int maxT2 = 300;

int warnBoost = 15;
int warnT1 = 200;
int warnT2 = 200;

int severeBoost = 18;
int severeT1 = 300;
int severeT2 = 300;

int gauge = 1; //gauge mode
int gaugedrawswitch = 0;

int tempX;
int tempY;

void setup() {
  Sensor.begin(19200);
  background(0); //black background
  gettouch();
  tempX = mouseX;
  tempY = mouseY;
}

void loop() {
  gettouch();
  while (mouseX != tempX || mouseY != tempY){ //while there is no change in the mouse press
    gettouch();
    //random vars to test just the display
    /*oil_temp=oil_temp + random(2);
     if (oil_temp > maxOilT) {
     oil_temp=100;
     }
     boost=boost + random(2);
     if (boost > maxBoost){
     boost=0;
     }
     temp1 = temp1 + random(3); 
     if (temp1 > maxT1){
     temp1 = 0;
     }
     temp2=temp2+random(3);
     if (temp2 > maxT2){
     temp2 = 0;
     }
     
     accelx = accelx + .01;
     //accelx = ((float)random(-15, 15))/10.0;
     */
    if (!strcmp(Sensor.getName(), "x")) {  
      accelx = Sensor.read(); //get the sensor value 
      if ((accelx > x_peak_pos) && (accelx > 0)){
        x_peak_pos = accelx;
      }
      if ((accelx < x_peak_neg) && (accelx < 0)){
        x_peak_neg = accelx;
      }
    }
    if (!strcmp(Sensor.getName(), "y")) {  
      accely = Sensor.read(); //get the sensor value 
      if ((accely > y_peak_pos) && (accely > 0)){
        y_peak_pos = accely;
      }
      if ((accely < y_peak_neg) && (accely < 0)){
        y_peak_neg = accely;
      }        
    }
    if (!strcmp(Sensor.getName(), "t1")) {  
      temp1 = Sensor.read(); //get the sensor value 
      if (temp1 > maxT1){
        maxT1 = temp1;
      }
    }
    if (!strcmp(Sensor.getName(), "t2")) {  
      temp2 = Sensor.read(); //get the sensor value 
      if (temp2 > maxT2){
        maxT2 = temp2;
      }
    }
    if (!strcmp(Sensor.getName(), "bt")){
      boost = Sensor.read();
      if (boost > maxBoost){
        maxBoost = boost;
      }
    }
    //original oil temp and boost vars for drawing purposes??  
    o_boost = 0; 

    //gauge on upper left side
    else if (gauge == 1){
      boost_gauge(boost, o_boost);
    }
    else if (gauge == 2){
      temp_gauge(temp1, temp2);
    }

    //update the bar graphs
    four_bar(x, boost, temp1, temp2);

    //update the accelerometer display
    accelDisplay(accelx);

  }
  tempX = mouseX; 
  tempY = mouseY;
  //when a touch is detected get coords
  //go to mode of what is touched if it is boost or oilT
  //otherwise go to next display
  if ((mouseX < 320) && (mouseX > 182) && (mouseY < 58) && (mouseY > 17)) {
    gauge = 2; 
    gaugedrawswitch = 0;
  }
  //oil temp area
  if ((mouseX < 320) && (mouseX > 182) && (mouseY < 93) && (mouseY > 60)){
    gauge = 1;
    gaugedrawswitch = 0;
  }
  //temp area
  //gauge face area
  if ((mouseX < 150) && (mouseX > 6) && (mouseY < 150) && (mouseY > 6)) {
    gauge++;
    gaugedrawswitch = 0;
  }
  //accelerometer area
}


void boost_gauge(float boost, float o_boost){
  float endy, endx;
  float tangle;
  //display the boost gauge background
  if (gaugedrawswitch == 0){
    background(0, 0, 0);
    //image(loadImage("rground.bmp"),0,0);
    image(loadImage("bstback.bmp"),0,0);
    bar_labels();
    gaugedrawswitch = 1;
  }
  if (int(boost) >= warnBoost){
    warn_flash(); 
  }
  //draw a line to rep this
  //line is 40 pixels long ... this is always the hypotenuse
  //angle formula is ...
  if (boost <= 0){//ok
    endx = 24;
    endy = 94;
  }
  else if ((boost > 0) && (boost < 10)){
    tangle = 9 * (boost); // 90/10 is 9  
    endx = 87 - (40 * lcos(tangle));
    endy = 93 - (40 * lsin(tangle));
  }
  else if (boost == 10){
    endx = 87;
    endy = 94 - 0;
  }
  else if ((boost > 10) && (boost < 20)){
    tangle = 9 * (boost - 10); 
    endx = 87 + (40 * lsin(tangle));
    endy = 93 - (40 * lcos(tangle));
  }
  else if (boost >= 20){
    endx = 87 + 40;
    endy = 93;
  }
  if (abs(o_boost - boost) > 2){
    stroke(224, 38, 41);
    line(87, 93, endx, endy);
    line(88, 93, endx, endy);
    line(86, 93, endx, endy);
    line(87, 94, endx, endy);
    line(87, 92, endx, endy);
    if ((endx + endy >= 2) || (endx + endy >= 2)) {
      stroke(0,0,0);
      line(87, 92, o_endx, o_endy);
      line(87, 94, o_endx, o_endy);
      line(86, 93, o_endx, o_endy);
      line(88, 93, o_endx, o_endy);
      line(87, 93, o_endx, o_endy);
    }

  }
  o_endx = endx;
  o_endy = endy;
  //print deg F
  //do conversion from int to string with decimal places
  /*char char_boost[7];
   fmtDouble(boost, 2, char_boost, 7);
   lcd_puts(char_boost, 65, 82, gaugeRed, mblack);*/
  //delay(200);
  //bmp_draw("bstgaug",0,0); //is this the right way to do a redraw??
  return;
}

//TODO: 
//-bottom two bars not right
//-fix filler calcs for x bar...should work though
void four_bar(float x,float boost, float T1, float T2){
  //draw rectangles inside rectangles 
  //only 86 ticks on a bar
  //bst rect = (old 128)(39, 13) to (125, 33) (320x240)[(219,27),(305,47)]
  if (boost >= severeBoost){
    fill(255, 102, 102); 
    stroke(255,102,102);
  }
  else if (boost >= warnBoost){
    fill(255, 255, 51); 
    stroke(255, 255, 51);
  }
  else {
    fill(153, 225, 153); 
    stroke(153, 225, 153);
  }
  rect(219,27,(boost * 86.0/maxBoost),20);
  fill(0,0,0); 
  //stroke(0,0,0);
  rect(int((219+(boost * 86.0/maxBoost))),27,(86 - boost * 86.0/maxBoost),20); //blacken the rest 
  //oilt rect = (old 128)(39, 38) to (125, 58)  (320x240)[(219,63),(305,83)]
  if (LC_1 >= severeLC1){
    fill(255, 102, 102); 
    stroke(255,102,102);
  }
  else if (LC_1 >= warnLC1){
    fill(255, 255, 51); 
    stroke(255, 255, 51);
  }
  else {
    fill(153, 225, 153); 
    stroke(153, 225, 153);
  }
  rect(219,63,(LC_1 * 86/maxLC1),20);
  fill(0,0,0); 
  //stroke(0,0,0);
  rect((219+(LC_1 * 86/maxLC1)),63,(86 - LC_1 * 86/maxLC1),20); 
  //t1 rect = (old 128) (39, 64) to (125, 84)  (320x240)[(219,99),(305,119)]
  if (T1 >= severeT1){
    fill(255, 102, 102); 
    stroke(255,102,102);
  }
  else if (T1 >= warnT1){
    fill(255, 255, 51); 
    stroke(255, 255, 51);
  }
  else {
    fill(153, 225, 153); 
    stroke(153, 225, 153);
  }
  rect(219,99,(T1 * 86/maxT1),20);
  fill(0,0,0); 
  //stroke(0,0,0);
  rect((219+(T1 * 86/maxT1)),99,(86 - T1 * 86/maxT1),20);    
  //T2 rect = (old 128)(39, 90) to (125, 110) (320x240)[(219,136),(305,156)]
  if (T2 >= severeT2){
    fill(255, 102, 102); 
    stroke(255,102,102);
  }
  else if (T2 >= warnT2){
    fill(255, 255, 51); 
    stroke(255, 255, 51);
  }
  else {
    fill(153, 225, 153); 
    stroke(153, 225, 153);
  }
  rect(219,136,(T2 * 86/maxT2),20);
  fill(0,0,0); 
  //stroke(0,0,0);
  rect((219+(T2 * 86/maxT2)),136,(86 - T2 * 86/maxT2),20); 
  //print values on top of bars in white
  fill(0, 0, 0); 
  stroke(49, 79, 79);
  char thechar[7];
  fmtDouble(boost, 2, thechar, 7);
  text(thechar, 227, 36, 10);
  fmtDouble(LC1, 2, thechar, 7);
  text(thechar, 227, 72, 10);
  fmtDouble(T1, 2, thechar, 7);
  text(thechar, 227, 108, 10);
  fmtDouble(T2, 2, thechar, 7);
  text(thechar, 227, 146, 10);

  //delay (100);
  //bmp_draw("fourbar",0,0);
  return;
}

//*TODO fill out temp_gauge based on oil_temp, but draw 2 needles
void temp_gauge(float temp1, float temp2){

  return;
}

void accelDisplay(float x){
  //scale x position of -1.5 to 1.5 G's to 300 pixels
  /*stroke(0,255,255); fill(0,255,255);
   char thechar[7];
   fmtDouble(x, 2, thechar, 7);
   text(thechar, 155, 210, 12);*/
  int xplot=x*10*160/15;
  stroke(0,0,0);
  fill(0,0,0);
  ellipse(160 + o_x, 230, 6, 6); //erase old
  stroke(0,255,255);
  fill(0,255,255);
  ellipse((160 + xplot), 230, 6, 6); //draw new
  o_x = xplot; //set old position
  if (o_x > x_peak_pos){
    stroke(0,0,0); 
    fill(0,0,0);
    rect(160 + x_peak_pos - 35, 193, 45, 11); //erase old text
    ellipse(160 + x_peak_pos, 210, 2, 5); //erase old
    stroke(255,255,0); 
    fill(255,255,0);
    x_peak_pos=o_x;
    ellipse(160 + x_peak_pos, 210, 2, 5); //draw new
    char thechar[7];
    fmtDouble(x, 2, thechar, 7);
    text(thechar, 160 + x_peak_pos - 30, 200, 10); //draw new text
  }
  if (o_x < x_peak_neg){
    stroke(0,0,0); 
    fill(0,0,0);
    rect(160 + x_peak_neg - 5, 193, 45, 11); //erase old tex   
    ellipse(160 + x_peak_neg, 210, 2, 5); //erase old
    stroke(255,255,0); 
    fill(255,255,0);
    x_peak_neg=o_x;
    ellipse(160 + x_peak_neg, 210, 2, 5); //draw new
    char thechar[7];
    fmtDouble(x, 2, thechar, 7);
    text(thechar, 160 + x_peak_neg, 200, 10); //draw new text
  }

  return;
}


//code from: http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1207226548/11#11
//*************
void fmtDouble(double val, byte precision, char *buf, unsigned bufLen = 0xffff);
unsigned fmtUnsigned(unsigned long val, char *buf, unsigned bufLen = 0xffff, byte width = 0);

//
// Produce a formatted string in a buffer corresponding to the value provided.
// If the 'width' parameter is non-zero, the value will be padded with leading
// zeroes to achieve the specified width.  The number of characters added to
// the buffer (not including the null termination) is returned.
//
unsigned
fmtUnsigned(unsigned long val, char *buf, unsigned bufLen, byte width)
{
  if (!buf || !bufLen)
    return(0);

  // produce the digit string (backwards in the digit buffer)
  char dbuf[10];
  unsigned idx = 0;
  while (idx < sizeof(dbuf))
  {
    dbuf[idx++] = (val % 10) + '0';
    if ((val /= 10) == 0)
      break;
  }

  // copy the optional leading zeroes and digits to the target buffer
  unsigned len = 0;
  byte padding = (width > idx) ? width - idx : 0;
  char c = '0';
  while ((--bufLen > 0) && (idx || padding))
  {
    if (padding)
      padding--;
    else
      c = dbuf[--idx];
    *buf++ = c;
    len++;
  }

  // add the null termination
  *buf = '\0';
  return(len);
}

//
// Format a floating point value with number of decimal places.
// The 'precision' parameter is a number from 0 to 6 indicating the desired decimal places.
// The 'buf' parameter points to a buffer to receive the formatted string.  This must be
// sufficiently large to contain the resulting string.  The buffer's length may be
// optionally specified.  If it is given, the maximum length of the generated string
// will be one less than the specified value.
//
// example: fmtDouble(3.1415, 2, buf); // produces 3.14 (two decimal places)
//
void
fmtDouble(double val, byte precision, char *buf, unsigned bufLen)
{
  if (!buf || !bufLen)
    return;

  // limit the precision to the maximum allowed value
  const byte maxPrecision = 6;
  if (precision > maxPrecision)
    precision = maxPrecision;

  if (--bufLen > 0)
  {
    // check for a negative value
    if (val < 0.0)
    {
      val = -val;
      *buf = '-';
      bufLen--;
    }

    // compute the rounding factor and fractional multiplier
    double roundingFactor = 0.5;
    unsigned long mult = 1;
    for (byte i = 0; i < precision; i++)
    {
      roundingFactor /= 10.0;
      mult *= 10;
    }

    if (bufLen > 0)
    {
      // apply the rounding factor
      val += roundingFactor;

      // add the integral portion to the buffer
      unsigned len = fmtUnsigned((unsigned long)val, buf, bufLen);
      buf += len;
      bufLen -= len;
    }

    // handle the fractional portion
    if ((precision > 0) && (bufLen > 0))
    {
      *buf++ = '.';
      if (--bufLen > 0)
        buf += fmtUnsigned((unsigned long)((val - (unsigned long)val) * mult), buf, bufLen, precision);
    }
  }

  // null-terminate the string
  *buf = '\0';
} 
//*************

//lookup functions for sin and cos
float lsin(int angle){
  return (sintable[angle+1]);
}

float lcos(int angle){
  return (sintable[90-angle]);
}

void warn_flash(){
  fill(224, 38, 41); 
  stroke(224, 38, 41); 
  ellipse(142,20,9,9);
  delay(90);
  fill(0,0,0);
  ellipse(142,20,9,9);  
  return;
}

void bar_labels(){
  fill(0,0,0);
  stroke(238,233,233); 
  text("Bst", 180, 36, 12);
  text("A/F", 180, 72, 10);
  text("T1", 180, 107, 12);
  text("T2", 180, 145, 12);
  return; 
}

