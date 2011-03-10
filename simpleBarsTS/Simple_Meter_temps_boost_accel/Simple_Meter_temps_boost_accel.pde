#include <HardwareSensor.h>
//writen for the touchshield slide
//draws current/peak and a bar graph for:
//  x
//  y
//  bst
//  IC F
//  Turbo F

//debug notes:
bool debugMode = false;
//temperature sensors work
//accel doesn't do anything (probably faulty wiring) (but could be wrong algorithm??)
POINT pt;
float boost = 0;
float temp1 = 0;
float temp2 = 0;
float accelx = 0, accely = 0;
float o_x = 160;
float o_y = 160;
float x_peak_neg = 0;
float x_peak_pos = 0;
float y_peak_neg = 0;
float y_peak_pos = 0;
float peak_boost = 0;
float peak_temp1 = 0;
float peak_temp2 = 0;
float o_boost = 0; 
float o_temp1 = 0;
float o_temp2 = 0;

int maxBoost = 25;
int maxT1 = 300;
int maxT2 = 300;

int warnBoost = 21;
int warnT1 = 200;
int warnT2 = 200;

int severeBoost = 23;
int severeT1 = 300;
int severeT2 = 300;

int zerogy = 512;
int zerogx = 512;

int tempX, tempY;

void setup(){
  Sensor.begin(19200);
  background(0); //black background

  //draw the rectangles and labels
  //-spacing should be 40 pixels tall for each rectangle
  //-all rects start at 50 and go 2xx pixels wide
  //-all rects are 44 high
  fill(0,0,0);
  stroke(255,0,0);
  rect(50,4,220,42);
  rect(50,52,220,42);
  rect(50,100,220,42);
  rect(50,148,220,42);
  rect(50,196,220,42);

  //bar labels
  stroke(255,255,255); //white looks good...red is unreable in sunlight
  text("boost",8,22,8);
  text("x",20, 52+20,18);
  text("y",20,100+20,18);
  text("t1",14,148+20,18);
  text("t2",14,196+20,18);

}

//get the readings from the arduino
void loop(){
  //tapping the bars to the right of the sensor label resets that peak
  //tapping the label change modes (TODO)
  if(touch_getCursor(&pt)){
    if ( (pt.x < 50) && (pt.y < 46) && (pt.y > 4)){
      peak_boost = 0;
    }
    if ( (pt.x < 50) && (pt.y < 94) && (pt.y > 52)){
      x_peak_neg = 0;
      x_peak_pos = 0;
    }
    if ( (pt.x < 50) && (pt.y < 142) && (pt.y > 100)){
      y_peak_neg = 0;
      y_peak_pos = 0;
    }
    if ( (pt.x < 50) && (pt.y < 190) && (pt.y > 148)){
      peak_temp1 = 0;
    }
    if ( (pt.x < 50) && (pt.y < 238) && (pt.y > 196)){
      peak_temp2 = 0;
    }
  }
  //change the below section so that it updates in a nicer/more efficient manner
  if (Sensor.available()){
    int value;
    value = Sensor.read();
    if (!strcmp(Sensor.getName(), "x")) {  
      accelx = getAccelerometerData(value)/100; //get the sensor value 
      update_x();
    }
    if (!strcmp(Sensor.getName(), "y")) {  
      accely = getAccelerometerData(value)/100; //get the sensor value 
      update_y();
    }
    if (!strcmp(Sensor.getName(), "t1")) {  
      temp1 = lookup_temp(value); //get the sensor value 
      update_t1();
    }
    if (!strcmp(Sensor.getName(), "t2")) {  
      temp2 = lookup_temp(value); //get the sensor value 
      update_t2();
    }
    if (!strcmp(Sensor.getName(), "bt")){
      boost = lookup_boost(value);
      update_boost();
    } 
    //  } 
  }
  //for debuging the display without the comms stuff/without sensors
  if(debugMode){
    boost = boost + random(2);
    update_boost();
    accelx = accelx + .01;
    update_x();  
    accely = accely + .01;
    update_y();
    temp1 = temp1 + random(2);
    update_t1();
    temp2 = temp2 + random(2);
    update_t2();
  }
  //avoid flicker as much as possible by only redrawing when there is a change
  //skip the accel readings because they will jump all over the place anyways?
  o_boost = boost;
  o_temp1 = temp1;
  o_temp2 = temp2;
  o_x = abs(accelx);
  o_y = abs(accely);
}

void update_x(){
  if ((accelx > x_peak_pos) && (accelx > 0)){
    x_peak_pos = accelx;
  }
  if ((accelx < x_peak_neg) && (accelx < 0)){
    x_peak_neg = accelx;
  }
  print_values_x();
  draw_bars_x();
}

void update_y(){
  if ((accely > y_peak_pos) && (accely > 0)){
    y_peak_pos = accely;
  }
  if ((accely < y_peak_neg) && (accely < 0)){
    y_peak_neg = accely;
  }        
  print_values_y();
  draw_bars_y();
}

void update_t1(){
  if (temp1 > peak_temp1){
    peak_temp1 = temp1;
  }
  print_values_t1();
  draw_bars_t1();
}

void update_t2(){
  if (temp2 > peak_temp2){
    peak_temp2 = temp2;
  }
  print_values_t2();
  draw_bars_t2();
}

void update_boost(){ 
  if (boost > peak_boost){
    peak_boost = boost;
  }
  print_values_boost();
  draw_bars_boost();
}

//TODO split this into many functions
void print_values_boost(){
  fill(0,0,0);
  stroke(0,255,255); //light blue 
  //current
  text(boost,274,4+6);//trying out other font sizes
  //peak
  text(peak_boost,274,30);
}

void print_values_x(){
  fill(0,0,0);
  stroke(0,255,255); //light blue 
  text(accelx,274,52+6);
  text(x_peak_pos,274,52+20);
  text(x_peak_neg,274,52+30);
}

void print_values_y(){
  fill(0,0,0);
  stroke(0,255,255); //light blue 
  text(accely,274,100+6);
  text(y_peak_pos,274,100+20);
  text(y_peak_neg,274,100+30);
}

void print_values_t1(){
  fill(0,0,0);
  stroke(0,255,255); //light blue 
  text(temp1,274,148+6);
  text(peak_temp2,274,196+26);
}

void print_values_t2(){
  fill(0,0,0);
  stroke(0,255,255); //light blue 
  text(temp2,274,196+6);
  text(peak_temp1,274,148+26);  
}


void draw_bars_boost(){
  float twidth=0;
  //boost
  if(boost != o_boost){
    fill(0,255,0); //green
    stroke(0,255,0);
    if (boost > warnBoost){
      fill(255,255,0);
      stroke(255,255,0);
    }
    if (boost > severeBoost){
      fill(255,0,0);
      stroke(255,0,0);
    }
    twidth=218/maxBoost*boost;
    rect(51,5,twidth,40);
    if (o_boost >= boost){
      stroke(0,0,0);
      fill(0,0,0);
      rect(twidth+1+51,5,218-twidth,40);
    }
  }
}


//x and y will be displayed as positive only (absolute value) in the bar graph
//they will be light blue and have no warning/severe values

void draw_bars_x(){
  //x
  float twidth=0;
  fill(0,255,255); //light blue
  stroke(0,255,255);
  twidth = 218/200*abs(accelx*100);
  rect(51,53,twidth,40);
  if(o_x >= abs(accelx)){
    stroke(0,0,0);
    fill(0,0,0);
    rect(twidth+1+51,53,218-twidth-1,40);
  }
}

void draw_bars_y(){
  //y
  float twidth=0;
  fill(0,255,255); //light blue
  stroke(0,255,255);
  twidth=218/200*abs(accely*100);
  rect(51,101,twidth,40);
  if (o_y >= abs(accely)){
    stroke(0,0,0);
    fill(0,0,0);
    rect(twidth+1+51,101,218-twidth-1,40);
  }
}

void draw_bars_t1(){
  //t1
  float twidth=0;
  if (temp1 != o_temp1){
    fill(0,255,0); //green
    stroke(0,255,0);
    if (temp1 > warnT1){
      fill(255,255,0);
      stroke(255,255,0);
    }
    if (temp1 > severeT1){
      fill(255,0,0);
      stroke(255,0,0);
    }
    twidth = temp1;
    rect(51,149,twidth,40);
    if (o_temp1 >= temp1){
      stroke(0,0,0);
      fill(0,0,0);
      rect(twidth+1+51,149,218-twidth,40);
    }
  }
}

void draw_bars_t2(){
  //t2 
  float twidth=0;
  if (temp2 != o_temp2){
    fill(0,255,0); //green
    stroke(0,255,0);
    if (temp2 > warnT2){
      fill(255,255,0);
      stroke(255,255,0);
    }
    if (temp2 > severeT2){
      fill(255,0,0);
      stroke(255,0,0);
    }
    twidth = temp2;
    rect(51,197,twidth,40);
    if (o_temp2 >= temp2){
      stroke(0,0,0);
      fill(0,0,0);
      rect(twidth+1+51,197,218-twidth,40);
    }
  }
}

/*(on the first draw fill from zero to the reading location)
  (the colors matters here)
  (the simple solution here is to set the original reading to 0...then it will draw from zero
  to the proper location in the proper color)
  if increase 
    if normal range fill is green
    if warn range fill is yellow
    if severe range fill is red
    rect starts at last reading and draws to the current reading
  if decrease
    fill is black
    rect starts at this reading's position ends at the previous readings position
    if old reading was in a different normal/warn/severe range
      redraw the rect to the left (starting at zero and going to 
  if current reading is more than the peak
    draw a line at the peak location + 1 (so it doesn't get erased on the next lower reading)
  
  add a part in the touch-to-reset-peaks section to erase the peak line
*/ 
  
/*  Justin D stuff below...needs some work
 1) fill out the left side of the bar only on startup
 2) grow bar to right or shrink to left by drawing small color or black rectangles
 3) if the color changes due to a warning change the whole bar to the left (need to keep track of colors)
 4) keep peaks 
 OR just touch up the code to fix the left side of the bar thing to work
 void draw_bars_boost(){
 float twidth=0;
 float o_twidth=0;
 float peak_twidth=0;
 
 o_twidth=218/maxBoost*o_boost;
 peak_twidth=218/maxBoost*o_boost;
 if(boost > o_boost) { //the bar is getting bigger
 fill(0,255,0); //green
 stroke(0,255,0);
 if (boost > warnBoost){
 fill(255,255,0);
 stroke(255,255,0);
 }
 if (boost > severeBoost){
 fill(255,0,0);
 stroke(255,0,0);
 }
 rect(51+o_twidth+1,5,twidth-o_twidth,40);
 } 
 else {  //the bar is getting smaller
 
 stroke(0,0,0);
 fill(0,0,0);
 rect(twidth+1+51,5,218-twidth,40);
 if(o_twidth == peak_twidth) { //old width was the highest yet lets leave a line behind
 if(o_twidth-peak_twidth-1 > 0) { 
 rect(twidth+1+51,5,o_twidth-twidth-1,40);
 } 
 else {
 //only one pixel less so do nothing.
 }
 } 
 else {
 rect(twidth+1+51,5,o_twidth-twidth,40);
 }
 }
 }
 
 
 //x and y will be displayed as positive only (absolute value) in the bar graph
 //they will be light blue and have no warning/severe values
 
 void draw_bars_x(){
 //x
 float twidth=0;
 fill(0,255,255); //light blue
 stroke(0,255,255);
 twidth = 218/200*abs(accelx*100);
 rect(51,53,twidth,40);
 if(o_x >= abs(accelx)){
 stroke(0,0,0);
 fill(0,0,0);
 rect(twidth+1+51,53,218-twidth-1,40);
 }
 }
 
 void draw_bars_y(){
 //y
 float twidth=0;
 fill(0,255,255); //light blue
 stroke(0,255,255);
 twidth=218/200*abs(accely*100);
 rect(51,101,twidth,40);
 if (o_y >= abs(accely)){
 stroke(0,0,0);
 fill(0,0,0);
 rect(twidth+1+51,101,218-twidth-1,40);
 }
 }
 
 void draw_bars_t1(){
 //t1
 float twidth=0;
 if(temp1 > o_temp1) { //the bar is getting bigger
 fill(0,255,0); //green
 stroke(0,255,0);
 if (temp1 > warnT1){
 fill(255,255,0);
 stroke(255,255,0);
 }
 if (temp1 > severeT1){
 fill(255,0,0);
 stroke(255,0,0);
 }
 twidth = temp1;
 rect(51+o_temp1+1,149,temp1-o_temp1,40);
 } 
 else { // the bar is getting smaller
 stroke(0,0,0);
 fill(0,0,0);
 rect(twidth+1+51,149,218-twidth,40);
 if(o_temp1 == peak_temp1) {
 if(o_temp1-1-temp1>0) {//leave a pixelwidth peak line
 rect(twidth+1+51,149,o_temp1-temp1-1,40); 
 } 
 else {
 //only one less so do nothing
 }
 } 
 else {
 rect(twidth+1+51,149,o_temp1-temp1,40);
 }
 }
 }
 
 void draw_bars_t2(){
 //t2 
 float twidth=0;
 if(temp2 > o_temp2) { //the bar is getting bigger
 fill(0,255,0); //green
 stroke(0,255,0);
 if (temp2 > warnT2){
 fill(255,255,0);
 stroke(255,255,0);
 }
 if (temp2 > severeT2){
 fill(255,0,0);
 stroke(255,0,0);
 }
 twidth = temp2;
 rect(51+o_temp2+1,197,temp2-o_temp2,40);
 } 
 else { // the bar is getting smaller
 stroke(0,0,0);
 fill(0,0,0);
 rect(twidth+1+51,197,218-twidth,40);
 if(o_temp2==peak_temp2) { 
 if((o_temp2-temp2-1)>0){
 rect(twidth+1+51,197,o_temp2-temp2-1,40);
 } else {
 //one one pixel less so do nothing
 }
 } else {
 rect(twidth+1+51,197,o_temp2-temp2,40);
 } 
 }
 }
 */

//correctly changed for float values
float lookup_boost(int boost){
  //boost = ( (boost-106000) / 259000 );
  // boost = ( (( boost * 398) / 1000) + 2); //2 is the y intercept
  //398 changed to 378 for slope...because slope was too steep
  float fboost = ( (( (float)boost * 378.0) / 1000.0) - 4.0)/10.0; //divide by 10.0 when adding decimals on the display code
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

