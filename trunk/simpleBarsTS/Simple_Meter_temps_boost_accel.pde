#include <HardwareSensor.h>
//writen for the touchshield slide
//draws current/peak and a bar graph for:
//  x
//  y
//  bst
//  IC F
//  Turbo F

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

void setup(){
  Sensor.begin(19200);
  background(0); //black background
  
  //draw the rectangles and labels
  //-spacing should be 40 pixels tall for each rectangle
  //-all rects start at 50 and go 2xx pixels widen
  //-all rects are 44 high
  fill(0,0,0);
  stroke(255,0,0);
  rect(50,4,220,42);
  rect(50,52,220,42);
  rect(50,100,220,42);
  rect(50,148,220,42);
  rect(50,196,220,42);
  
  //bar labels
  text("boost",8,22,8);
  text("x",20, 52+20,18);
  text("y",20,100+20,18);
  text("t1",14,148+20,18);
  text("t2",14,196+20,18);
  
}

//get the readings from the arduino
void loop(){
  gettouch(); //update the mouse coordinates
  //add section to reset peaks on touch per area

  //change the below section so that it updates in a nicer/more efficient manner
  if (Sensor.available()){
    int value;
    value = Sensor.read();
    if (strcmp(Sensor.getName(), "x")) {  
        accelx = value/100; //get the sensor value 
        if ((accelx > x_peak_pos) && (accelx > 0)){
          x_peak_pos = accelx;
        }
        if ((accelx < x_peak_neg) && (accelx < 0)){
          x_peak_neg = accelx;
        }
      }
      if (strcmp(Sensor.getName(), "y")) {  
        accely = value/100; //get the sensor value 
        if ((accely > y_peak_pos) && (accely > 0)){
          y_peak_pos = accely;
        }
        if ((accely < y_peak_neg) && (accely < 0)){
          y_peak_neg = accely;
        }        
      }
      if (strcmp(Sensor.getName(), "t1")) {  
        temp1 = value; //get the sensor value 
        if (temp1 > peak_temp1){
          peak_temp1 = temp1;
        }
      }
      if (strcmp(Sensor.getName(), "t2")) {  
        temp2 = value; //get the sensor value 
        if (temp2 > peak_temp2){
          peak_temp2 = temp2;
        }
      }
      if (strcmp(Sensor.getName(), "bt")){
        boost = value;
        if (boost > peak_boost){
          peak_boost = boost;
        }
      }  
  }
    //for debuging the display without the comms stuff/without sensors
    /*boost = boost + random(2);
    accelx = accelx + .01;
    accely = accely + .01;
    temp1 = temp1 + random(2);
    temp2 = temp2 + random(2); */
    //draw the bars
    draw_bars();
    //print the values
    print_values();
    
    //avoid flicker as much as possible by only redrawing when there is a change
    //skip the accel readings because they will jump all over the place anyways?
    o_boost = boost;
    o_temp1 = temp1;
    o_temp2 = temp2;
    o_x = abs(accelx);
    o_y = abs(accely);
}

void print_values(){
  fill(0,0,0);
  stroke(0,255,255); //light blue 
  //current
  text(boost,274,4+6);
  text(accelx,274,52+6);
  text(accely,274,100+6);
  text(temp1,274,148+6);
  text(temp2,274,196+6);
  
  //peak
  text(peak_boost,274,30);
  text(x_peak_pos,274,52+20);
  text(x_peak_neg,274,52+30);
  text(y_peak_pos,274,100+20);
  text(y_peak_neg,274,100+30);
  text(peak_temp1,274,148+26);
  text(peak_temp2,274,196+26);
  
}

void draw_bars(){
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
  
  //x and y will be displayed as positive only (absolute value) in the bar graph
  //they will be light blue and have no warning/severe values
  //x
  fill(0,255,255); //light blue
  stroke(0,255,255);
  twidth = 218/200*abs(accelx*100);
  rect(51,53,twidth,40);
  if(o_x >= abs(accelx)){
    stroke(0,0,0);
    fill(0,0,0);
    rect(twidth+1+51,53,218-twidth-1,40);
  }
  
  //y
  fill(0,255,255); //light blue
  stroke(0,255,255);
  twidth=218/200*abs(accely*100);
  rect(51,101,twidth,40);
  if (o_y >= abs(accely)){
    stroke(0,0,0);
    fill(0,0,0);
    rect(twidth+1+51,101,218-twidth-1,40);
  }
  
  //t1
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
  
  //t2 
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
