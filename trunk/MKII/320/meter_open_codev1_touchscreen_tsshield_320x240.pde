//#include <graph.h> //for two graph
#include <touchLargeNums.h> //for touch timer
//#include <math.h> //needed for cos/sin/etc. //using lookup table now...for performance reasons
//#define PI 3.14159265
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


COLOR gaugeRed = {224, 38, 41};
COLOR greenLine = {26, 255, 26};
COLOR redLine = {255, 26, 26};
COLOR yellowLine = {255, 255, 26};
COLOR purpleLine = {77, 26, 128};
COLOR mwhite = {255, 255, 255};
COLOR mblack = {0, 0, 0};
COLOR lightBlue = {204, 204, 255};

//colors for bar graphs
COLOR fadedRed = {255, 102, 102};
COLOR fadedGreen = {153, 225, 153};
COLOR fadedYellow = {255, 255, 51};

POINT m_point;

largeNum myFont = largeNum();
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

void setup (){

  fadeIn(10, 5);
  bmp_draw("robotsh",0,0);
  delay(2000);
  fadeOut(10, 5);
  //display the splash screen 
  delay(100);
  fadeIn(10, 5);
  bmp_draw("stisplsh", 0, 0);
  
  //Serial.begin(9600); //set up the TouchShield serial connection
  //delay(3000); //and wait a little for the Arduino to boot up

  //Serial.print('U'); //send a sync character to the Arduino
  fadeOut(10, 5);
  fadeIn(10,5);
}

void loop() {
  //replace with code to get readings from arduino
  float oil_temp = 120;
  float boost = 0;
  float temp1 = 1;
  float temp2 = 1;
  float accelx = 0, accely = 0;
  //gauge on left side
  if (gauge == 1){
    oil_temp_gauge(oil_temp);
  }
  else if (gauge == 1){
    boost_gauge(boost);
  }
  else if (gauge == 3){
    temp_gauge(temp1, temp2);
  }
  
  //update the bar graphs
  four_bar(oil_temp, boost, temp1, temp2);
  
  //update the accelerometer display
  accelDisplay(accelx, accely);
  
}

void oil_temp_gauge(){
 float endy, endx, o_endx, o_endy;
 float tangle;
 //display the oil temp gauge background
 bmp_draw("oilgaug",0,0);
  while (!(touch_get_cursor(&m_point))){
   //if warmed and not previously warmed then flash message
   if ( (oil_temp_startup == false) && (oil_temp >= oil_temp_warn) ){
      oil_temp_startup = true;
      lcd_clearScreen(mblack);
      //*TODO: change this to use largenumbs*
      lcd_puts("Engine Warmed!",10,30,gaugeRed,mblack); 
            lcd_puts("Engine Warmed!",20,40,gaugeRed,mblack); 
                  lcd_puts("Engine Warmed!",30,50,gaugeRed,mblack); 
                        lcd_puts("Engine Warmed!",40,60,gaugeRed,mblack); 
      delay (2000);
      lcd_clearScreen(mblack);
      bmp_draw("oilgaug",0,0);
   }
   //if the warn point is met flash the circle encompassing the gauge
   if (int(oil_temp) >= warnOilT){
    lcd_circle(142,20,9, gaugeRed, gaugeRed);
    delay(90);
    lcd_circle(142,20,9, gaugeRed, mblack);  
   }
   //draw a line to rep this
   //line is 40 pixels long ... this is always the hypotenuse
     //angle formula is ...
   if (oil_temp <= 120){ //ok
     endx = 87;
     endy = 94;
   }
   else if ((oil_temp > 120) && (oil_temp < 180)){ //not ok
     tangle = 1.5 * (oil_temp - 120); //1.5 is 90degrees/60degF or the scaling factor
     endx = 87 - (30.0 * lsin(tangle)); 
     endy = 94 + (30.0 * lcos(tangle));
   }
   else if ((oil_temp >= 180) && (oil_temp < 240)){ //ok
     tangle = 1.5 * (oil_temp - 180);
     endx = 87 - (30 * lcos(tangle));
     endy = 94 - (30 * lsin(tangle));
   }
   else if ((oil_temp >= 240) && (oil_temp < 300)){ //not ok
     tangle = 90 - 1.5 * (oil_temp - 240); //inverse...because we are actually looking for the angle down from 90 deg up
     endx = 87 + (30 * lcos(tangle));
     endy = 94 - (30 * lsin(tangle));
   }
   else if (oil_temp > 300){//ok
     endx = 94;
     endy = 87;
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
   //for debugging --v
   /*char char_xy[7];
   fmtDouble(endx, 2, char_xy, 7);
   lcd_puts(char_xy, 10, 10, gaugeRed, black);
   fmtDouble(endy, 2, char_xy, 7);
   lcd_puts(char_xy, 20, 20, gaugeRed, black);*/
   //--^
   //print deg F
   //do conversion from int to string with decimal places
   //*TODO: move and and use largenumbs*
   char char_oil_temp[7];
   fmtDouble(oil_temp, 2, char_oil_temp, 7);
   lcd_puts(char_oil_temp, 80, 72, gaugeRed, mblack);
   //delay(500); //for testing
   //bmp_draw("oilgaug",0,0);
   return();
  }
  while (touch_get_cursor(&m_point)){} //debounce
  boost_gauge(); //next gauge
}

//*TODO fill out temp_gauge based on oil_temp, but draw 2 needles
void temp_gauge(){

  return();
}

void boost_gauge(){
  float endy, endx, o_endy, o_endx;
  float tangle;
  float boost = 0.0, o_boost = 0.0;
  //display the boost gauge background
  bmp_draw("bstgaug",0,0);
  //loop
  while (!(touch_get_cursor(&m_point))){
     //get boost reading
     boost++; //for testing
     if (int(boost) >= warnBoost){
      lcd_circle(11,10,9, gaugeRed, gaugeRed);
      delay(90);
      lcd_circle(11,10,9, gaugeRed, mblack);  
     }
     //draw a line to rep this
     //line is 40 pixels long ... this is always the hypotenuse
       //angle formula is ...
     if (boost <= 0){//ok
       endx = 24;
       endy = 93;
     }
     else if ((boost > 0) && (boost < 10)){
       tangle = 9 * (boost); // 90/10 is 9  
       endx = 87 - (40 * lcos(tangle));
       endy = 93 - (40 * lsin(tangle));
     }
     else if ((boost >= 10) && (boost < 20)){
       tangle = 9 * (boost - 10); 
       endx = 87 + (40 * lsin(tangle));
       endy = 93 - (40 * lcos(tangle));
     }
     else if (boost >= 20){
       endx = 104;
       endy = 93;
     }
   if (abs(o_boost - boost) > 2){
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
     //print deg F
     //do conversion from int to string with decimal places
     char char_boost[7];
     fmtDouble(boost, 2, char_boost, 7);
     lcd_puts(char_boost, 65, 82, gaugeRed, mblack);
     //delay(200);
     //bmp_draw("bstgaug",0,0); //is this the right way to do a redraw??
  }
  while (touch_get_cursor(&m_point)){}
  //go to the next display if a touch is detected
  four_bar();
}

void four_bar(){
  //for debugging
  float boost = 0;
  float oilT = 0;
  float T1 = 0; 
  float T2 = 0;
  bmp_draw("fourbar",0,0);
  while (!(touch_get_cursor(&m_point))){
    //get Boost, OilT, T1, and T2
    boost++;
    oilT++;
    T1++;
    T2++;
    if (boost >= maxBoost){boost = 0;}
    if (oilT >= maxOilT){oilT = 0;}
    if (T1 >= maxT1){T1 = 0;}
    if (T2 >= maxT1){T2 = 0;}
    COLOR conditionColor = mwhite;
    //draw rectangles inside rectangles 
    //only 86 ticks on a bar
      //lcd_clear (x, y, x1, y2, fill); //draws a solid rect fill with no border
      //bst rect = (39, 13) to (125, 33)
      if (boost >= severeBoost){conditionColor = fadedRed;}
      else if (boost >= warnBoost){conditionColor = fadedYellow;}
      else {conditionColor = fadedGreen;}
      lcd_rectangle(39,13,(int(39.0+(boost * 86.0/maxBoost))),33,conditionColor,conditionColor);
      lcd_rectangle(int((39.0+(boost * 86.0/(float)maxBoost))),13,125,33,mblack,mblack); //blacken the rest 
      //oilt rect = (39, 38) to (125, 58)
      if (oilT >= severeOilT){conditionColor = fadedRed;}
      else if (oilT >= warnOilT){conditionColor = fadedYellow;}
      else {conditionColor = fadedGreen;}
      lcd_rectangle(39,38,(39+(oilT * 86/maxOilT)),58,conditionColor,conditionColor);
      lcd_rectangle((39+(oilT * 86/maxOilT)),38,125,58,mblack,mblack);
      //t1 rect = (39, 64) to (125, 84)
      if (T1 >= severeT1){conditionColor = fadedRed;}
      else if (T1 >= warnT1){conditionColor = fadedYellow;}
      else {conditionColor = fadedGreen;}
      lcd_rectangle(39,64,(39+(T1 * 86/maxT1)),84,conditionColor,conditionColor);
      lcd_rectangle((39+(T1 * 86/maxT1)),64,125,84,mblack,mblack);      
      //T2 rect = (39, 90) to (125, 110)
      if (T2 >= severeT2){conditionColor = fadedRed;}
      else if (T2 >= warnT2){conditionColor = fadedYellow;}
      else {conditionColor = fadedGreen;}
      lcd_rectangle(39,90,(39+(T2 * 86/maxT2)),110,conditionColor,conditionColor);
      lcd_rectangle((39+(T2 * 86/maxT2)),90,125,110,mblack,mblack);
    //print values on top of bars in white
    char out[7];
    fmtDouble(boost, 2, out, 7);
    lcd_puts(out, 95, 18, lightBlue, mblack);
    fmtDouble(oilT, 2, out, 7);
    lcd_puts(out, 95, 43, lightBlue, mblack);
    fmtDouble(T1, 2, out, 7);
    lcd_puts(out, 95, 69, lightBlue, mblack);     
    fmtDouble(T2, 2, out, 7);
    lcd_puts(out, 95, 93, lightBlue, mblack);
    
    delay (100);
    //bmp_draw("fourbar",0,0);
  }
  
  //when a touch is detected get coords
  //go to mode of what is touched if it is boost or oilT
  //otherwise go to next display
  while (touch_get_cursor(&m_point)){ //debounce hold
  LCD_RECT boostRect; boostRect.left = 0; boostRect.right = 128; boostRect.top = 11; boostRect.bottom = 34;
  LCD_RECT oilRect; oilRect.left = 0; oilRect.right = 128; oilRect.top = 36; oilRect.bottom = 59;
  if (pointInRect(m_point,boostRect)){boost_gauge();}
  if (pointInRect(m_point,oilRect)){oil_temp_gauge();}
  }
  xygraph(); //click anywhere else and it goes to xygraph
  
}

void xygraph(){//won't work until they start fixing the lines code
  int xs[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
  int ys[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
  int curx=0;
  int cury=0;
  int erasex=0;
  int erasey=0;
  bmp_draw("xygraph",0,0);
  
   while (!(touch_get_cursor(&m_point))){
     //get x and y from acceleromter from arduino
     int curx=random(0 ,200);
     int cury=random(0, 200);
     //draw an x and y dot where it goes //line is better
     //lcd_pixel(curx, cury, white);
    stroke(255,255,255);
    line(curx, cury, xs[19], ys[19]);  //add scaling stuff (scale 2.00 G's (200) to 64 pixel spaces)
     //store that dot in an array
     erasex = xs[0];
     erasey = ys[0];
     for (int j=0; j>=18; j++){
       xs[j]=xs[j+1];
       ys[j]=ys[j+1];
     }
     xs[19]=curx;
     ys[19]=cury;
     //undraw the last dot in the array and remove it from the array
       //problem because we dont know if the pixel used to be black or one of the circles
     stroke(255,255,255);
     line(erasex, erasey, xs[0], ys[0]); //add scaling stuff
     //write the numbers in the correct position
   //when a touch is detected go to the next gauge
   }
   while (touch_get_cursor(&m_point)){} //debounce
   
   four_line();
   
}

void four_line(){ //won't work until they fix lines code
  //display the four line background
   bmp_draw("lingrph",0,0);
   while (!(touch_get_cursor(&m_point))){
    //check for touch w/debounce
    //get boost, oilT, T1, T2 readings
    //store current reading at and of array...bump out the last reading of the array
    //draw boost line purple
    //draw oil line green
    //draw t1 line yellow
    //draw t2 line red
  //when a touch is detected if it is boost or oil go to that guage
  //else go to the next mode
   }
   
   while (touch_get_cursor(&m_point)){} //debounce
   
  touch_timer();
}

void touch_timer(){
  LCD_RECT timerRect; timerRect.left = 0; timerRect.right = 128; timerRect.top = 46; timerRect.bottom = 66;
  lcd_clearScreen(mblack);
  while (!(touch_get_cursor(&m_point))){
  //what timer mode?
    if (timermode == 0){ //stopped mode
    //TODO: print 00:00:00.00 to screen in bignum, centered
     while (!(touch_get_cursor(&m_point))){}
     while ((touch_get_cursor(&m_point))){} //debounce
        //if it is outside numbers go to next display mode
        if (!pointInRect(m_point,timerRect)){oil_temp_gauge();}
        //if it is on numbers go to mode 1
        if (pointInRect(m_point,timerRect)){
           //store millis of start time
           timerStartMillis = millis();
           timermode = 1;
        }
    }
    if (timermode == 1){ //running and screen mode
      while (!(touch_get_cursor(&m_point))){
       //TODO: display code for running timer goes here 
       //current timer value = millis() - timer start
      }
      while (touch_get_cursor(&m_point)){} //debounce
        //if it is on numbers go to mode 2
      if (pointInRect(m_point,timerRect)){
        timermode == 0;
        timerStoppedMillis = 0;
        touch_timer();
      }
    }
    //if it is outside go to next display mode
    if (!(pointInRect(m_point,timerRect))){
        oil_temp_gauge();
    }
  }
}


//misc functions

void fadeIn(int fader, int brightness) {

  SETBIT(PORTE, PE3);

 

  for (int i = 0; i<(brightness+1); i++) {

    lcd_setBrightness(i);

    delay(fader);

  }
}

void fadeOut (int fader, int brightness) {

  for (int i = brightness; i>0; i--) {

    lcd_setBrightness(i);

    delay(fader);

  }

 

  CLRBIT(PORTE, PE3);

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
