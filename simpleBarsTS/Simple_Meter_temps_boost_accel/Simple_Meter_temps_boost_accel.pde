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
int severeT1 = 280;
int severeT2 = 380;

int zerogy = 512;
int zerogx = 512;

int tempX, tempY;
int indexMapping[5];

int o_zone_boost = 0; //used to store old state of which zone we were in
void setup(){
  Sensor.begin(19200);
  background(0); //black background

  indexMapping[0] = 1; //index 0 is boost
  indexMapping[1] = 2; //index 1 is x
  indexMapping[2] = 3; //index 2 is y
  indexMapping[3] = 4; //index 3 is tempature 1
  indexMapping[4] = 0; //index 4 is tempature 2
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
  text("boost",8,4+18+48*indexMapping[0],8); 
  text("x",20, 4+20+48*indexMapping[1],18);
  text("y",20,4+20+48*indexMapping[2],18);
  text("t1",14,4+20+48*indexMapping[3],18);
  text("t2",14,4+20+48*indexMapping[4],18);

}

//get the readings from the arduino
void loop(){
  //tapping the bars to the right of the sensor label resets that peak
  //tapping the label change modes (TODO)
  if(touch_getCursor(&pt)){
    if ( (pt.x < 50) && (pt.y < 46+indexMapping[0]*48) && (pt.y > 4+indexMapping[0]*48)){
      peak_boost = 0;
      draw_bars_boost_simple();
    }
    if ( (pt.x < 50) && (pt.y < 46+indexMapping[1]*48) && (pt.y > 4+indexMapping[1]*48)){
      x_peak_neg = 0;
      x_peak_pos = 0;
    }
    if ( (pt.x < 50) && (pt.y < indexMapping[2]*48) && (pt.y > 4+indexMapping[2]*48)){
      y_peak_neg = 0;
      y_peak_pos = 0;
    }
    if ( (pt.x < 50) && (pt.y < 46+indexMapping[3]*48) && (pt.y > 4+indexMapping[3]*48)){
      peak_temp1 = 0;
    }
    if ( (pt.x < 50) && (pt.y < 46+indexMapping[4]*48) && (pt.y > 46+indexMapping[4]*48)){
      peak_temp2 = 0;
    }
  }
  //change the below section so that it updates in a nicer/more efficient manner
  if(!debugMode) {
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
    }
  } else {
    //for debuging the display without the comms stuff/without sensors
    boost = boost + random(2) - .5+random(10)/10;
    if (boost > maxBoost) {
      boost -= maxBoost;
    }
    if (boost < 0 ) {
      boost += maxBoost;
    }
    update_boost();
    accelx = accelx + (float)(random(5)-1)/100;
    if (accelx > 2.18) {
      accelx -= 4.36;
    }
    if (accelx < -2.18) {
      accelx += 4.36;
    }
    update_x();  

    accely = accely + (float)(random(5)-1)/100;
    if (accely > 2.18) {
      accely -= 4.36;
    }
    if (accely < -2.18) {
      accely += 4.36;
    }
    update_y();
    temp1 = temp1 + random(5);
    if(temp1 > maxT1) {
      temp1 -= maxT1;
    } 
    if(temp1 < 0) {
      temp1 += maxT1;
    }
    update_t1();
    temp2 = temp2 + random(5);
    if(temp2 > maxT2){
      temp2 -= maxT2;
    }
    if(temp2 < 0){
      temp2 += maxT2;
    }
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
  print_values_x(indexMapping[1]);
  draw_bars_x(indexMapping[1]);
}

void update_y(){
  if ((accely > y_peak_pos) && (accely > 0)){
    y_peak_pos = accely;
  }
  if ((accely < y_peak_neg) && (accely < 0)){
    y_peak_neg = accely;
  }        
  print_values_y(indexMapping[2]);
  draw_bars_y(indexMapping[2]);
}

void update_t1(){
  if (temp1 > peak_temp1){
    peak_temp1 = temp1;
  }
  print_values_t1(indexMapping[3]);
  draw_bars_t1(indexMapping[3]);
}

void update_t2(){
  if (temp2 > peak_temp2){
    peak_temp2 = temp2;
  }
  print_values_t2(indexMapping[4]);
  draw_bars_t2(indexMapping[4]);
}

void update_boost(){ 
  if (boost > peak_boost){
    peak_boost = boost;
  }
  print_values_boost(indexMapping[0]);
  draw_bars_boost(indexMapping[0]);
}

//TODO split this into many functions
void print_values_boost(int rowIndex){
  int row = rowIndex*48+4+6;
  fill(0,0,0);
  stroke(0,255,255); //light blue 
  //current
  text(boost,274,row);//trying out other font sizes
  //peak
  text(peak_boost,274,20+row);
}

void print_values_x(int rowIndex){
  int row = rowIndex*48+4+6;
  fill(0,0,0);
  stroke(0,255,255); //light blue 
  text(accelx,274,row);
  text(x_peak_pos,274,row+10);
  text(x_peak_neg,274,row+20);
}

void print_values_y(int rowIndex){
  int row = rowIndex*48+4+6;
  fill(0,0,0);
  stroke(0,255,255); //light blue 
  text(accely,274,row);
  text(y_peak_pos,274,row+10);
  text(y_peak_neg,274,row+20);
}

void print_values_t1(int rowIndex){
  int row = rowIndex*48+4+6;
  fill(0,0,0);
  stroke(0,255,255); //light blue 
  text(temp1,274,row);
  text(peak_temp1,274,row+20);
}

void print_values_t2(int rowIndex){
  int row = 4+6+48*rowIndex;
  fill(0,0,0);
  stroke(0,255,255); //light blue 
  text(temp2,274,row);
  text(peak_temp2,274,row+20);  
}

void draw_bars_boost_simple(){
  int width=218*boost/maxBoost;
  int top = indexMapping[0]*48+5;
  if(boost>severeBoost){
    fill(255,0,0);
    stroke(255,0,0);
  } else if(boost > warnBoost){
    fill(255,255,0);
    stroke(255,255,0);
  } else {
    fill(0,255,0);
    stroke(0,255,0);
  }
  rect(51,top,width,40);
  fill(0,0,0);
  stroke(0,0,0);
  rect(width+51,top,218-width,40);
}
void draw_bars_boost(int rowIndex){
  int row = rowIndex*48+5;
  float left=51;
  float o_right=218*o_boost/maxBoost;
  float right=218*boost/maxBoost;
  //boost
  if(o_right != right){
    int zone=0;
    if(boost > severeBoost){
      zone = 2;
    } else if (boost > warnBoost) {
      zone = 1;
    }
    if(o_right < right){
      //we are increasing
      if(zone == 0){
        //still in the normal zone so just do the delta
        fill(0,255,0);
        stroke(0,255,0);
        rect(o_right+left,row,right-o_right,40);
      }
      if(zone == 1){
        //in the warning zone
        if(o_zone_boost == 0){
          //was in the normal zone so we need to recolor the whole range
          fill(255,255,0);
          stroke(255,255,0);
          rect(left,row,right,40);
        } else {
          //we were in zone 1 so just do the delta
          fill(255,255,0);
          stroke(255,255,0);
          rect(o_right+left,row,right-o_right,40);
        }
      }
      if(zone == 2){
        //in the severe zone
        if(o_zone_boost == 2)
        {
          //we are in the same zone just do the delta
          fill(255,0,0);
          stroke(255,0,0);
          rect(o_right+left,row,right-o_right,40);
        } else {
          //we were in an old zone so just fill in the whole range
          fill(255,0,0);
          stroke(255,0,0);
          rect(left,row,right,40);
        }
      }
    } else { //we are going backwards
      if(zone != o_zone_boost){
        //we are going from one zone to the next so we have to recolor the full bar
        if(zone == 0){
          fill(0,255,0);
          stroke(0,255,0);
          rect(left,row,right,40);
        } else {
          //we have to be in the warn zone
          fill(255,255,0);
          stroke(255,255,0);
          rect(left,row,right,40);
        }
      }
      //we still have to do the blank delta
      fill(0,0,0);
      stroke(0,0,0); 
      float peak_right=218*peak_boost/maxBoost;
      if(right >= peak_right-2) {
        //do nothing as we are in the peak line area
      } else if(o_right >= peak_right-2){
        //we were in the peak line area but are not any more
        rect(right+left,row,peak_right-2-right,40);
      } else {
        //we weren't in the peak line area so just do normal delta
        rect(right+left,row,o_right-right+1,40);
      }  
    }
    o_zone_boost = zone;
    o_boost = boost;
  }
}


//x and y will be displayed as positive only (absolute value) in the bar graph
//they will be light blue and have no warning/severe values

void draw_bars_x(int rowIndex){
  //x
  int row = rowIndex*48+5;
  float twidth=0;
  fill(0,255,255); //light blue
  stroke(0,255,255);
  twidth = 218/200*abs(accelx*100);
  rect(51,row,twidth,40);
  if(o_x >= abs(accelx)){
    stroke(0,0,0);
    fill(0,0,0);
    rect(twidth+1+51,row,218-twidth-1,40);
  }
}

void draw_bars_y(int rowIndex){
  int row = rowIndex*48+5;
  float twidth=0;
  fill(0,255,255); //light blue
  stroke(0,255,255);
  twidth=218/200*abs(accely*100);
  rect(51,row,twidth,40);
  if (o_y >= abs(accely)){
    stroke(0,0,0);
    fill(0,0,0);
    rect(twidth+1+51,row,218-twidth-1,40);
  }
}

void draw_bars_t1(int rowIndex){
  //t1
  int row = rowIndex*48+5;
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
    twidth = temp1/maxT1*218;
    rect(51,row,twidth,40);
    if (o_temp1 >= temp1){
      stroke(0,0,0);
      fill(0,0,0);
      rect(twidth+1+51,row,218-twidth,40);
    }
  }
}

void draw_bars_t2(int rowIndex){
  //t2 
  int row = rowIndex*48+5;
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
    twidth = temp2/maxT2*218;
    rect(51,row,twidth,40);
    if (o_temp2 >= temp2){
      stroke(0,0,0);
      fill(0,0,0);
      rect(twidth+1+51,row,218-twidth,40);
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

