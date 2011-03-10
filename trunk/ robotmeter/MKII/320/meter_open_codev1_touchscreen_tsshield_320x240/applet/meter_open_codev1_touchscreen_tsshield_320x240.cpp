#include "WProgram.h"
void setup ();
void loop();
void oil_temp_gauge(float oil_temp, float o_oil_temp);
void temp_gauge(float temp1, float temp2);
void boost_gauge(float boost, float o_boost);
void four_bar(float oilT, float boost, float T1, float T2);
void accelDisplay(float x);
unsigned
fmtUnsigned(unsigned long val, char *buf, unsigned bufLen, byte width);
void
fmtDouble(double val, byte precision, char *buf, unsigned bufLen);
float lsin(int angle);
float lcos(int angle);
void warn_flash();
void bar_labels();
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

float oil_temp = 120;
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

float o_oil_temp = 0;
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


//oil temp gauge display is always first
//once it reaches peak it will flash/signal that it is warm
boolean oil_temp_startup = false;
int oil_temp_warn = 150;

int maxBoost = 20;
int maxOilT = 300;
int maxT1 = 300;
int maxT2 = 300;

int warnBoost = 15;
int warnOilT = 200;
int warnT1 = 200;
int warnT2 = 200;

int severeBoost = 18;
int severeOilT = 250;
int severeT1 = 300;
int severeT2 = 300;

int gauge = 1; //gauge mode
int gaugedrawswitch = 0;

void setup (){

  //bmp_draw("robotsh",0,0);
  //image(loadImage("rground.bmp"),0,0);
  //delay(100);
  //display the splash screen 
  //bmp_draw("stisplsh", 0, 0);
  //Serial.begin(9600); //set up the TouchShield serial connection
  //delay(3000); //and wait a little for the Arduino to boot up

  //Serial.print('U'); //send a sync character to the Arduino

}

void loop() {
  while (!(touch_get_cursor(&m_point))){
    //replace with code to get readings from arduino
    oil_temp=oil_temp + random(2);
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

    o_oil_temp = 0;
    o_boost = 0; 

    //gauge on upper left side
    if (gauge == 1){
      oil_temp_gauge(oil_temp, o_oil_temp);
    }
    else if (gauge == 2){
      boost_gauge(boost, o_boost);
    }
    else if (gauge == 3){
      temp_gauge(temp1, temp2);
    }

    //update the bar graphs
    four_bar(oil_temp, boost, temp1, temp2);

    //update the accelerometer display
    accelDisplay(accelx);

  }
  //when a touch is detected get coords
  //go to mode of what is touched if it is boost or oilT
  //otherwise go to next display
  while (gettouch()){ //debounce hold
    //boost bar and word area
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
}

void oil_temp_gauge(float oil_temp, float o_oil_temp){
  float endy, endx;
  float tangle;

  //display the oil temp gauge background
  if (gaugedrawswitch == 0){
    background(0,0,0);
    image(loadImage("oilback.bmp"),0,0);
    bar_labels();
    gaugedrawswitch = 1;
  }
  //if warmed and not previously warmed then flash message
  if ( (oil_temp_startup == false) && (oil_temp >= oil_temp_warn) ){
    //add new engine warmed code here!
  }
  //if the warn point is met flash the circle encompassing the gauge
  if (int(oil_temp) >= warnOilT){
    warn_flash();
  }
  //draw a line to rep this
  //line is 40 pixels long ... this is always the hypotenuse
  //angle formula is ...
  if (oil_temp <= 120){ //ok
    endx = 87;
    endy = 94 + 30;
  }
  else if ((oil_temp > 120) && (oil_temp < 180)){ //not ok
    tangle = 1.5 * (oil_temp - 120); //1.5 is 90degrees/60degF or the scaling factor
    endx = 87 - (30.0 * lsin(tangle)); 
    endy = 94 + (30.0 * lcos(tangle));
  }
  else if (oil_temp == 180){ //necessary because trig does weird things at the 90deg's
    endx = 87 - 30;
    endy = 94;
  }
  else if ((oil_temp > 180) && (oil_temp < 240)){ //ok
    tangle = 1.5 * (oil_temp - 180);
    endx = 87 - (30 * lcos(tangle));
    endy = 94 - (30 * lsin(tangle));
  }
  else if (oil_temp == 240){
    endx = 87;
    endy = 94 - 30;
  }
  else if ((oil_temp > 240) && (oil_temp < 300)){ //not ok
    tangle = 90 - 1.5 * (oil_temp - 240); //inverse...because we are actually looking for the angle down from 90 deg up
    endx = 87 + (30 * lcos(tangle));
    endy = 94 - (30 * lsin(tangle));
  }
  else if (oil_temp > 300){//ok
    endx = 87 + 30;
    endy = 94;
  }
  if (abs(o_oil_temp - oil_temp) > 2){
    stroke(224, 38, 41);
    line(87, 93, endx, endy);
    line(88, 93, endx, endy);
    line(86, 93, endx, endy);
    line(87, 94, endx, endy);
    line(87, 92, endx, endy);
    stroke(0,0,0);
    line(87, 92, o_endx, o_endy);
    line(87, 94, o_endx, o_endy);
    line(86, 93, o_endx, o_endy);
    line(88, 93, o_endx, o_endy);
    line(87, 93, o_endx, o_endy);
  }
  o_endx = endx;
  o_endy = endy;

  /*stroke(224, 38, 41); 
  fill(0,0,0);
  char char_oil_temp[7];
  fmtDouble(oil_temp, 2, char_oil_temp, 7);
  text(char_oil_temp, 90, 115, 10);*/
  return;
}

//*TODO fill out temp_gauge based on oil_temp, but draw 2 needles
void temp_gauge(float temp1, float temp2){

  return;
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

//TODO: bottom two bars not right
void four_bar(float oilT, float boost, float T1, float T2){
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
  if (oilT >= severeOilT){
    fill(255, 102, 102); 
    stroke(255,102,102);
  }
  else if (oilT >= warnOilT){
    fill(255, 255, 51); 
    stroke(255, 255, 51);
  }
  else {
    fill(153, 225, 153); 
    stroke(153, 225, 153);
  }
  rect(219,63,(oilT * 86/maxOilT),20);
  fill(0,0,0); 
  //stroke(0,0,0);
  rect((219+(oilT * 86/maxOilT)),63,(86 - oilT * 86/maxOilT),20); 
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
  fmtDouble(oilT, 2, thechar, 7);
  text(thechar, 227, 72, 10);
  fmtDouble(T1, 2, thechar, 7);
  text(thechar, 227, 108, 10);
  fmtDouble(T2, 2, thechar, 7);
  text(thechar, 227, 146, 10);

  //delay (100);
  //bmp_draw("fourbar",0,0);
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
    stroke(0,0,0); fill(0,0,0);
    rect(160 + x_peak_pos - 35, 193, 45, 11); //erase old text
    ellipse(160 + x_peak_pos, 210, 2, 5); //erase old
    stroke(255,255,0); fill(255,255,0);
    x_peak_pos=o_x;
    ellipse(160 + x_peak_pos, 210, 2, 5); //draw new
    char thechar[7];
    fmtDouble(x, 2, thechar, 7);
    text(thechar, 160 + x_peak_pos - 30, 200, 10); //draw new text
  }
  if (o_x < x_peak_neg){
    stroke(0,0,0); fill(0,0,0);
    rect(160 + x_peak_neg - 5, 193, 45, 11); //erase old tex   
    ellipse(160 + x_peak_neg, 210, 2, 5); //erase old
    stroke(255,255,0); fill(255,255,0);
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
 text("OilT", 180, 72, 10);
 text("T1", 180, 107, 12);
 text("T2", 180, 145, 12);
 return; 
}

//*******************************************************************************
//*	Detailed edit history
//*	<MLS> is Mark Sproul msproul@jove.rutgers.edu
//*			http://coewww.rutgers.edu/~msproul/
//*	Detailed edit history
//*******************************************************************************
//*	Dec 26,	2008	Mark Sproul <MLS> meet with Matt and Chris in New Haven
//*	Dec 26,	2008	<MLS> Will be taking over the development of the SubProcessing files
//*******************************************************************************

#include	"HardwareDef.h"
#include	"SubPOptions.h"
#include	"SubPGraphics.h"
#include	"graphics.h"

//*	if you need more code space in the STELTH or SLIDE
//*	comment out one or more of these lines to get rid of the start up splash
#define	_STARTUPSCREEN_VERSION_
//#define	_STARTUPSCREEN_LIQUIDWARE_
//#define	_STARTUPSCREEN_MATRIX_

//#define	_DEBUG_RECTS_

void	DisplaySplashScreen(void);



//*******************************************************************************
int main(void)
{


	init();

	DisplaySplashScreen();
	
	setup();
    
	for (;;)
		loop();
        
	return 0;
}

short	gTextYloc	=	45;
//*******************************************************************************
void	DebugText(char *textMsg)
{

	text(textMsg, 5, gTextYloc);
	gTextYloc	+=	15;
	if (gTextYloc > kSCREEN_Y_size)
	{
		gTextYloc	=	15;
	}
}

#ifdef _STARTUPSCREEN_LIQUIDWARE_
//*********************************************************
//*	Dec 26,	2008	Run Length Encoding for RGB
void	DisplayRLE_RGB(unsigned char *rleBuff, COLOR *colorFade, boolean fillBack, int startY)
{
COLOR	bgColor;
COLOR	rleColor;
int		ii, jj;
int		cc;
int		rlePixCount;
int		pixelX, pixelY;
int		rleColorValue;
int		pixlesWide, pixelsTall;
int		rowCount;
int		byte1, byte2, byte3, byte4;
int		adjusted_Red;
int		adjusted_Green;
int		adjusted_Blue;

	cc		=	0;
	
	byte1			=	rleBuff[cc++] & 0x00ff;
	byte2			=	rleBuff[cc++] & 0x00ff;
	byte3			=	rleBuff[cc++] & 0x00ff;
	byte4			=	rleBuff[cc++] & 0x00ff;
	pixlesWide		=	(byte1 << 8) + byte2;
	pixelsTall		=	(byte3 << 8) + byte4;


	adjusted_Red	=	(rleBuff[cc++] & 0x00ff)		- colorFade->red;
	adjusted_Green	=	(rleBuff[cc++] & 0x00ff)	- colorFade->green;
	adjusted_Blue	=	(rleBuff[cc++] & 0x00ff)	- colorFade->blue;
	cc++;			//*	1 filler char

	if (adjusted_Red < 0)	adjusted_Red	=	0;
	if (adjusted_Green < 0)	adjusted_Green	=	0;
	if (adjusted_Blue < 0)	adjusted_Blue	=	0;

	bgColor.red		=	adjusted_Red;
	bgColor.green	=	adjusted_Green;
	bgColor.blue	=	adjusted_Blue;


	pixelX		=	(kSCREEN_X_size / 2) - (pixlesWide / 2);
	pixelY		=	(kSCREEN_Y_size / 2) - (pixelsTall / 2);

	//*	is the background supposed to be filled in
	if (fillBack)
	{
   		dispColor(bgColor);
		for (jj=startY; jj<pixelY; jj++)
		{
			for (ii=0; ii<=kSCREEN_X_size; ii++)
			{
				dispPixel(ii, jj);
			}
		}
	}

	rowCount	=	0;
	
	while ((cc < 5000) && (rowCount < pixelsTall))
	{
		adjusted_Red	=	(rleBuff[cc] & 0x00ff)		- colorFade->red;
		adjusted_Green	=	(rleBuff[cc + 1] & 0x00ff)	- colorFade->green;
		adjusted_Blue	=	(rleBuff[cc + 2] & 0x00ff)	- colorFade->blue;
		if (adjusted_Red < 0)	adjusted_Red	=	0;
		if (adjusted_Green < 0)	adjusted_Green	=	0;
		if (adjusted_Blue < 0)	adjusted_Blue	=	0;

		rleColor.red	=	adjusted_Red;
		rleColor.green	=	adjusted_Green;
		rleColor.blue	=	adjusted_Blue;
		
		rlePixCount		=	rleBuff[cc + 3] & 0x00ff;

		if ((rleColor.red == 0) && (rleColor.green == 0) && (rleColor.blue == 0) && (rlePixCount == 0))
		{
			//*	we have a new line
			rowCount++;
			pixelX	=	(kSCREEN_X_size / 2) - (pixlesWide / 2);

			//*	as good a time as any to fill in the rest of the row
			if (fillBack)
			{
 		  		dispColor(bgColor);
				for (ii=0; ii<pixelX; ii++)
				{
					dispPixel(ii, pixelY);
				}
				for (ii=(pixelX + pixlesWide); ii<kSCREEN_X_size; ii++)
				{
					dispPixel(ii, pixelY);
				}
			}

			pixelY++;
		}
		else if ((rlePixCount > 0) && (rlePixCount < 256))
		{
	   			
   			dispColor(rleColor);
		
			for (jj=0; jj<rlePixCount; jj++)
			{
				dispPixel(pixelX, pixelY);
				pixelX++;
			}
		}
		cc	+=	4;
	}
	if (fillBack)
	{
   		dispColor(bgColor);
		for (jj=pixelY; jj<=kSCREEN_Y_size; jj++)
		{
			for (ii=0; ii<=kSCREEN_X_size; ii++)
			{
				dispPixel(ii, jj);
			}
		}
	}
}
#endif


#ifdef _STARTUPSCREEN_MATRIX_
//*******************************************************************************
void	MatrixDisplay(int topOffset, int iterations)
{
//int		ii,jj;
int		cc;
int		xx, yy;
char	myChar;
char	myString[4];

	
	fill(0);
	
	cc	=	0;
	while (cc < iterations)
	{
		//*	this gives 1 pixel between columns
		xx	=	random(kSCREEN_X_size / 12) * 13;
		yy	=	topOffset;
		while (yy < kSCREEN_Y_size)
		{
			stroke(0, 50 + random(200), 0);
			myChar	=	random(33, 72);
			drawchar(xx, yy, myChar);
		
		//	myString[0]	=	myChar;
		//	myString[1]	=	0;
		//	drawstring(xx, yy, myString);

			yy	+=	10;
		}
		cc++;
	}
}
#endif

#define	kLinrSpacing	11
#define	kMatixTopOffset	36
extern	unsigned char	gLiquidWareLogo[];

//*******************************************************************************
void	DisplaySplashScreen(void)
{
COLOR	bgColor;
COLOR	fontColor;
int		ii;
int		yTextLoc;

#ifdef _STARTUPSCREEN_VERSION_
	char	startupMsg[128];
#endif

#ifdef _STARTUPSCREEN_VERSION_
	bgColor.red		=	0;
	bgColor.green	=	0;
	bgColor.blue	=	0;

	fontColor.red	=	0;
	fontColor.green	=	255;
	fontColor.blue	=	0;
	
	//*	display the overall library version
	yTextLoc	=	10;
	strcpy(startupMsg, kDisplayHardwareString);
	strcat(startupMsg, " ");
	strcat(startupMsg, kDisplayHardwareVersion);
	dispPutS(startupMsg, 5, yTextLoc, fontColor, bgColor);
	yTextLoc	+=	kLinrSpacing;
	
	
	//*	display the SubProcessing library version
	strcpy(startupMsg, "Arduino Processing Library ");
	strcat(startupMsg, kSubP_VersionString);
	strcat(startupMsg, " ");

#ifdef _SUBP_OPTION_GAMES_
	strcat(startupMsg, "+G");
#endif
#ifdef _SUBP_OPTION_KEYBOARD_
	strcat(startupMsg, "+K");
#endif

	dispPutS(startupMsg, 5, yTextLoc, fontColor, bgColor);
	yTextLoc	+=	kLinrSpacing;

#endif

#ifdef _DEBUG_RECTS_
 	dispColor(bgColor);
 	ii	=	kSCREEN_Y_size / 2;
 	ii	-=	25;
 	ii	=	kSCREEN_Y_size / 3;
 	while (ii > 30)
 	{
		fill(random(255), random(255), random(255));
		stroke(random(255), random(255), random(255));
		drawrect((kSCREEN_X_size / 2) - ii, (kSCREEN_Y_size / 2) - ii, (ii * 2), (ii * 2));
		
		ii	-=	10;
 	}
	fill(0);
	stroke(255);
#endif

#ifdef _STARTUPSCREEN_LIQUIDWARE_
   	for (ii=0; ii<190; ii+=10)
	{
		//*	this is the FADE color, how much to subtract from the actual colors
		//*	0 means none.
		bgColor.red		=	ii;
		bgColor.green	=	ii;
		bgColor.blue	=	ii;
		DisplayRLE_RGB(gLiquidWareLogo, &bgColor, false, kMatixTopOffset);
#ifdef _STARTUPSCREEN_MATRIX_
		if (ii > 100)
		{
			MatrixDisplay(kMatixTopOffset, 3);
		}
#endif
	}
#endif
#ifdef _STARTUPSCREEN_MATRIX_
	ii	=	0;
	while(!serialAvailable() && (ii < 2000))
	{
		MatrixDisplay(kMatixTopOffset, 2);
		ii++;

		gettouch();
		if ((mouseX > 200) && (mouseY < 100))
		{
			break;
		}
	}
#endif



#ifdef _SUBP_OPTION_7_SEGMENT_dontDisplay
int	xx, yy;
//	dispClearScreen();

	xx	=	10;
	yy	=	50;
	for (ii=5; ii<30; ii += 4)
	{
		Display7SegmentString(xx, yy, "0123456789ABCDEF", ii);
		yy	+=	(ii * 2);
		yy	+=	8;
		if (ii > 230)
		{
			break;
		}
	}
	while (true)
	{
		//*	do nothing
	}
#endif



	bgColor.red		=	0;
	bgColor.green	=	0;
	bgColor.blue	=	0;
 	dispColor(bgColor);
//	drawrect(0, yTextLoc, 320, 240);
	
}



#ifdef _STARTUPSCREEN_LIQUIDWARE_
unsigned char	gLiquidWareLogo[]	=	{
0,75,0,75,	//xSize_hi, xSize_lo ,ySize_hi, ySize_lo
150,207,14,0,		//*	background color
150,207,14,75,  		0,0,0,0,
150,207,14,75,  		0,0,0,0,
150,207,14,75,  		0,0,0,0,
150,207,14,75,  		0,0,0,0,
150,207,14,37,  183,183,183,1,  150,207,14,37,  		0,0,0,0,
150,207,14,36,  183,183,183,3,  150,207,14,36,  		0,0,0,0,
150,207,14,35,  183,183,183,5,  150,207,14,35,  		0,0,0,0,
150,207,14,35,  183,183,183,5,  150,207,14,35,  		0,0,0,0,
150,207,14,34,  183,183,183,7,  150,207,14,34,  		0,0,0,0,
150,207,14,33,  183,183,183,9,  150,207,14,33,  		0,0,0,0,
150,207,14,33,  183,183,183,10,  150,207,14,32,  		0,0,0,0,
150,207,14,32,  183,183,183,12,  150,207,14,31,  		0,0,0,0,
150,207,14,31,  183,183,183,12,  0,0,0,3,  150,207,14,29,  		0,0,0,0,
150,207,14,31,  183,183,183,12,  0,0,0,4,  150,207,14,28,  		0,0,0,0,
150,207,14,30,  183,183,183,12,  0,0,0,6,  150,207,14,27,  		0,0,0,0,
150,207,14,29,  183,183,183,13,  0,0,0,7,  150,207,14,26,  		0,0,0,0,
150,207,14,29,  183,183,183,12,  0,0,0,8,  150,207,14,26,  		0,0,0,0,
150,207,14,28,  183,183,183,12,  182,181,177,1,  0,0,0,4,  4,7,0,1,  0,5,0,1,  0,0,0,3,  150,207,14,25,  		0,0,0,0,
150,207,14,27,  183,183,183,13,  0,0,0,7,  68,79,19,1,  0,0,0,3,  150,207,14,24,  		0,0,0,0,
150,207,14,27,  183,183,183,13,  0,0,0,1,  4,1,10,1,  0,0,0,2,  0,2,0,1,  0,7,0,1,  94,111,17,1,  150,207,14,1,  34,46,0,1,  0,0,0,3,  150,207,14,23,  		0,0,0,0,
150,207,14,26,  183,183,183,13,  0,0,0,6,  26,39,0,1,  168,195,56,1,  150,207,14,1,  125,144,26,1,  1,13,0,1,  0,0,0,2,  150,207,14,23,  		0,0,0,0,
150,207,14,26,  183,183,183,13,  1,1,0,1,  0,0,0,1,  4,0,15,1,  0,0,0,1,  0,2,0,1,  0,0,0,1,  110,132,23,1,  150,207,14,3,  53,70,0,1,  0,0,0,2,  0,2,0,1,  150,207,14,22,  		0,0,0,0,
150,207,14,25,  183,183,183,13,  0,0,0,1,  1,0,0,1,  1,0,4,1,  0,0,0,3,  43,60,0,1,  150,207,14,5,  0,0,0,3,  150,207,14,22,  		0,0,0,0,
150,207,14,25,  183,183,183,12,  0,11,0,1,  1,0,0,1,  0,0,0,5,  128,154,19,1,  150,207,14,5,  60,79,0,1,  0,0,0,3,  150,207,14,21,  		0,0,0,0,
150,207,14,24,  183,183,183,13,  0,0,0,6,  60,78,2,1,  150,207,14,7,  0,0,0,1,  0,11,0,2,  150,207,14,21,  		0,0,0,0,
150,207,14,24,  183,183,183,12,  0,0,0,3,  1,0,5,1,  0,0,0,2,  3,18,0,1,  134,161,46,1,  150,207,14,7,  74,98,0,1,  0,10,0,1,  0,11,0,1,  0,0,0,1,  150,207,14,20,  		0,0,0,0,
150,207,14,23,  183,183,183,13,  0,0,0,6,  57,82,0,1,  150,207,14,9,  0,0,0,1,  0,5,0,1,  0,0,0,1,  150,207,14,20,  		0,0,0,0,
150,207,14,23,  183,183,183,12,  0,0,0,6,  0,19,0,1,  150,207,14,10,  79,103,9,1,  0,9,0,1,  0,11,0,1,  0,0,0,1,  150,207,14,19,  		0,0,0,0,
150,207,14,22,  183,183,183,13,  0,0,0,6,  56,80,0,1,  150,207,14,3,  158,210,3,1,  150,207,14,7,  0,0,0,3,  150,207,14,19,  		0,0,0,0,
150,207,14,22,  183,183,183,12,  0,0,0,5,  0,7,0,1,  0,0,0,1,  130,162,29,1,  150,207,14,11,  79,104,2,1,  0,8,0,1,  0,0,0,2,  150,207,14,18,  		0,0,0,0,
150,207,14,21,  183,183,183,13,  0,11,0,2,  0,3,8,1,  0,0,5,1,  0,5,1,1,  0,13,0,1,  58,86,0,1,  150,207,14,7,  150,209,0,1,  150,207,14,1,  156,210,0,1,  150,207,14,3,  0,0,0,4,  150,207,14,17,  		0,0,0,0,
150,207,14,21,  183,183,183,12,  0,11,0,2,  0,2,0,1,  0,4,3,1,  0,2,1,1,  0,4,0,1,  0,14,0,1,  120,154,15,1,  150,207,14,2,  152,206,0,1,  150,207,14,7,  154,206,0,1,  150,207,14,3,  0,8,0,1,  0,0,0,2,  150,207,14,17,  		0,0,0,0,
150,207,14,20,  183,183,183,3,  181,181,181,1,  183,183,183,9,  0,11,0,1,  0,0,0,2,  0,5,0,1,  0,4,0,1,  0,8,0,1,  43,65,0,1,  150,207,14,3,  153,209,0,1,  150,207,14,6,  151,207,10,1,  153,209,12,1,  150,207,14,3,  0,0,0,3,  150,207,14,17,  		0,0,0,0,
150,207,14,20,  183,183,183,1,  181,181,181,1,  183,183,183,10,  0,0,0,1,  0,11,0,2,  0,0,0,4,  108,135,38,1,  150,207,14,5,  148,211,8,1,  147,212,4,1,  150,207,14,5,  151,210,6,1,  150,207,14,2,  50,85,0,1,  0,0,0,1,  0,2,0,1,  150,207,14,17,  		0,0,0,0,
150,207,14,20,  183,183,183,12,  0,0,0,6,  15,39,0,1,  150,207,14,2,  153,205,8,1,  149,207,1,1,  148,208,0,1,  150,207,14,12,  0,11,0,1,  3,9,7,1,  0,11,0,1,  150,207,14,16,  		0,0,0,0,
150,207,14,19,  183,183,183,13,  0,0,0,2,  0,11,0,1,  0,0,0,1,  0,4,0,1,  0,0,0,1,  79,111,2,1,  150,207,14,17,  30,52,0,1,  0,6,0,1,  0,11,0,1,  150,207,14,16,  		0,0,0,0,
150,207,14,19,  183,183,183,2,  181,181,181,1,  183,183,183,9,  0,0,0,5,  0,5,0,1,  0,0,0,1,  138,179,41,1,  150,207,14,18,  0,9,0,1,  0,2,0,1,  0,11,0,1,  150,207,14,15,  		0,0,0,0,
150,207,14,19,  183,183,183,12,  0,0,0,3,  6,6,4,1,  0,0,0,2,  40,68,0,1,  156,203,47,1,  150,207,14,18,  0,23,0,1,  0,7,0,1,  0,11,0,1,  150,207,14,15,  		0,0,0,0,
150,207,14,18,  183,183,183,13,  0,0,0,6,  93,129,31,1,  148,201,33,1,  150,207,14,17,  147,194,52,1,  43,74,0,1,  0,9,0,1,  0,11,0,1,  150,207,14,15,  		0,0,0,0,
150,207,14,18,  183,183,183,12,  0,0,0,3,  1,0,5,1,  0,3,0,1,  0,0,0,2,  150,207,14,21,  0,11,0,1,  0,2,0,1,  150,207,14,15,  		0,0,0,0,
150,207,14,17,  183,183,183,13,  0,0,0,6,  31,67,0,1,  151,202,61,1,  150,207,14,9,  138,188,37,1,  150,207,14,10,  0,14,0,1,  0,2,0,1,  0,11,0,1,  150,207,14,14,  		0,0,0,0,
150,207,14,16,  183,183,183,14,  0,0,0,1,  1,0,5,1,  0,0,0,4,  60,101,0,1,  147,205,43,1,  150,207,14,8,  98,142,18,1,  38,81,0,1,  136,189,37,1,  150,207,14,9,  11,40,0,1,  0,0,0,2,  150,207,14,14,  		0,0,0,0,
150,207,14,16,  183,183,183,14,  0,11,0,1,  0,0,4,1,  5,0,11,1,  0,0,5,1,  0,6,0,1,  0,0,0,1,  150,207,14,10,  38,73,0,1,  0,18,0,1,  90,133,18,1,  139,193,45,1,  150,207,14,8,  45,77,4,1,  0,0,0,2,  150,207,14,14,  		0,0,0,0,
150,207,14,16,  183,183,183,14,  0,11,0,1,  1,1,3,1,  7,0,0,2,  0,0,0,2,  150,207,14,8,  141,197,26,1,  104,147,16,1,  0,0,0,1,  0,11,0,1,  0,0,0,1,  138,186,64,1,  150,207,14,8,  72,106,29,1,  0,0,0,2,  150,207,14,14,  		0,0,0,0,
150,207,14,16,  183,183,183,14,  2,2,2,2,  1,0,0,1,  5,7,4,1,  0,0,0,2,  150,207,14,9,  25,59,0,1,  0,8,0,1,  0,0,0,2,  85,124,31,1,  150,207,14,9,  0,0,0,2,  150,207,14,14,  		0,0,0,0,
150,207,14,16,  183,183,183,14,  0,0,0,2,  1,0,0,1,  7,9,4,1,  0,0,0,2,  150,207,14,8,  95,137,25,1,  0,18,0,1,  2,10,0,1,  0,2,2,1,  0,0,0,1,  7,40,0,1,  132,183,42,1,  150,207,14,8,  0,0,0,2,  150,207,14,14,  		0,0,0,0,
150,207,14,15,  183,183,183,15,  0,0,0,3,  7,0,0,1,  0,0,0,2,  150,207,14,7,  134,195,32,1,  30,65,0,1,  0,14,0,1,  4,8,7,1,  0,0,0,1,  0,12,8,1,  0,14,0,1,  85,134,6,1,  133,196,21,1,  150,207,14,7,  0,0,0,2,  150,207,14,14,  		0,0,0,0,
150,207,14,15,  183,183,183,15,  0,0,0,2,  1,1,0,1,  0,4,0,1,  0,0,0,2,  150,207,14,7,  105,163,16,1,  0,28,0,1,  0,0,0,5,  31,71,0,1,  123,182,28,1,  150,207,14,7,  0,0,0,2,  150,207,14,14,  		0,0,0,0,
150,207,14,15,  183,183,183,15,  0,0,0,3,  3,5,0,1,  0,7,2,1,  0,0,0,1,  150,207,14,7,  61,117,0,1,  0,0,0,7,  112,166,52,1,  150,207,14,7,  0,0,0,2,  150,207,14,14,  		0,0,0,0,
150,207,14,15,  183,183,183,15,  7,0,0,2,  0,0,0,1,  7,0,0,1,  0,0,0,2,  150,207,14,7,  21,72,0,1,  0,0,0,7,  84,136,38,1,  150,207,14,7,  0,0,0,2,  150,207,14,14,  		0,0,0,0,
150,207,14,15,  183,183,183,15,  0,11,0,1,  1,1,1,1,  0,0,0,3,  0,10,0,1,  150,207,14,7,  9,55,0,1,  0,0,0,7,  51,99,0,1,  150,207,14,6,  3,31,0,1,  0,6,0,1,  0,0,0,1,  150,207,14,14,  		0,0,0,0,
150,207,14,15,  183,183,183,15,  0,11,0,1,  0,0,0,1,  0,1,0,1,  0,0,0,2,  0,8,0,1,  0,0,0,1,  150,207,14,6,  8,57,0,1,  0,0,0,7,  62,114,6,1,  150,207,14,6,  0,0,0,2,  0,4,0,1,  150,207,14,14,  		0,0,0,0,
150,207,14,16,  183,183,183,14,  0,11,0,2,  0,0,0,5,  150,207,14,6,  35,91,0,1,  7,0,0,1,  0,0,0,5,  0,20,0,1,  96,155,35,1,  150,207,14,5,  21,62,0,1,  0,0,0,1,  0,8,0,1,  0,5,0,1,  150,207,14,14,  		0,0,0,0,
150,207,14,17,  183,183,183,14,  0,11,0,1,  0,0,0,6,  150,207,14,5,  88,154,22,1,  22,77,0,1,  0,0,0,5,  22,77,0,1,  106,175,33,1,  150,207,14,5,  0,0,0,2,  0,5,2,1,  0,6,5,1,  150,207,14,14,  		0,0,0,0,
150,207,14,17,  183,183,183,14,  0,11,0,2,  0,0,0,5,  150,207,14,6,  71,135,13,1,  0,51,0,1,  0,29,0,1,  0,21,0,1,  0,25,0,1,  22,85,0,1,  98,172,23,1,  150,207,14,5,  0,0,0,1,  0,6,0,1,  0,0,0,3,  150,207,14,14,  		0,0,0,0,
150,207,14,17,  183,183,183,15,  0,11,0,2,  11,0,4,1,  0,0,0,4,  150,207,14,17,  0,8,0,1,  0,0,0,3,  150,207,14,15,  		0,0,0,0,
150,207,14,17,  183,183,183,15,  0,11,0,2,  4,0,2,1,  0,0,0,2,  7,6,12,1,  0,0,0,2,  150,207,14,14,  0,0,0,2,  0,3,2,1,  0,0,0,3,  150,207,14,15,  		0,0,0,0,
150,207,14,18,  183,183,183,14,  0,11,0,2,  4,4,2,1,  0,0,0,6,  0,17,0,1,  150,207,14,11,  0,0,0,5,  6,0,0,1,  150,207,14,16,  		0,0,0,0,
150,207,14,19,  183,183,183,14,  0,11,0,1,  0,0,0,5,  1,1,0,1,  0,0,0,18,  150,207,14,17,  		0,0,0,0,
150,207,14,19,  183,183,183,15,  0,11,0,3,  0,0,0,21,  150,207,14,17,  		0,0,0,0,
150,207,14,20,  183,183,183,16,  0,11,0,3,  3,0,0,1,  0,0,0,17,  150,207,14,18,  		0,0,0,0,
150,207,14,20,  183,183,183,18,  0,11,0,4,  0,4,0,1,  0,3,0,1,  0,0,0,8,  0,0,5,1,  0,0,0,2,  0,11,0,1,  150,207,14,19,  		0,0,0,0,
150,207,14,21,  183,183,183,21,  0,11,0,1,  0,0,0,12,  150,207,14,20,  		0,0,0,0,
150,207,14,22,  183,183,183,24,  0,0,0,8,  150,207,14,21,  		0,0,0,0,
150,207,14,22,  183,183,183,31,  150,207,14,22,  		0,0,0,0,
150,207,14,23,  183,183,183,29,  150,207,14,23,  		0,0,0,0,
150,207,14,24,  183,183,183,27,  150,207,14,24,  		0,0,0,0,
150,207,14,25,  183,183,183,24,  150,207,14,26,  		0,0,0,0,
150,207,14,26,  183,183,183,22,  150,207,14,27,  		0,0,0,0,
150,207,14,28,  183,183,183,19,  150,207,14,28,  		0,0,0,0,
150,207,14,34,  183,183,183,8,  150,207,14,33,  		0,0,0,0,
150,207,14,75,  		0,0,0,0,
150,207,14,75,  		0,0,0,0,
150,207,14,75,  		0,0,0,0,
150,207,14,75,  		0,0,0,0,

//total values=716,  
//EOF
};

#endif

