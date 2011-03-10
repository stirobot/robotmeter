#include <HardwareSensor.h>
//writen for the touchshield slide

//mode 1: draws current/peak and a bar graph for:
//  x
//  y
//  bst
//  IC F
//  Turbo F
//mode 2: draws a round gauge to the left, bars to the right, and an accelerometer slider on the bottom

//progress to integrate both modes;
/*
-bring in sine table - done
-fix modes section to work nicely
-move over other mode
-make polling for the sensor a common thing
-decide what to show to right (bars vs large numbers)
  -if bars - draw prettier with new method
-add commentable flash directive to put bground image on the device
-somehow make round gauge animate smoother (redraw less stuff)
*/



//debug notes:
//temperature sensors work
///need to post about strcompare working backwards???
//boost sensor always shows full high (faulty wiring or faulty sensor)
//accel doesn't do anything (probably faulty wiring) (but could be wrong algorithm??)

const float sintable[90] = {
  0.0175, 0.0349, 0.0523, 0.0698, 0.0872, 0.1045, 0.1219, 0.1392, 0.1564, 0.1736, 0.1908,
  0.2079, 0.2250, 0.2419, 0.2588, 0.2756, 0.2924, 0.3090, 0.3256, 0.3420, 0.3584, 0.3746,
  0.3907, 0.4067, 0.4226, 0.4384, 0.4540, 0.4695, 0.4848, 0.5000, 0.5150, 0.5299, 0.5446,
  0.5592, 0.5736, 0.5878, 0.6018, 0.6157, 0.6293, 0.6428, 0.6561, 0.6691, 0.6820, 0.6947,
  0.7071, 0.7193, 0.7314, 0.7431, 0.7547, 0.7660, 0.7771, 0.7880, 0.7986, 0.8090, 0.8192,
  0.8290, 0.8387, 0.8480, 0.8572, 0.8660, 0.8746, 0.8829, 0.8910, 0.8988, 0.9063, 0.9135,
  0.9205, 0.9272, 0.9336, 0.9397, 0.9455, 0.9511, 0.9563, 0.9613, 0.9659, 0.9703, 0.9744,
  0.9781, 0.9816, 0.9848, 0.9877, 0.9903, 0.9925, 0.9945, 0.9962, 0.9976, 0.9986, 0.9994,
  0.9998, 1.0000  };

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

//mode = major screen mode
//gauge = the gauge that is round or focused (depends on the mode)
int mode = 1;
int gauge = 1;

void setup(){
  Sensor.begin(19200);
  background(0); //black background
  setup_bars();
  tempX = mouseX;
  tempY = mouseY;
}

//get the readings from the arduino
void loop(){
  gettouch();
  while (mouseX != tempX || mouseY != tempY){//trap mouse taps to change major mode
    gettouch(); 
    if (Sensor.available()){
      get_sensor_readings();
    }
  o_boost = boost;
  o_temp1 = temp1;
  o_temp2 = temp2;
  o_x = abs(accelx);
  o_y = abs(accely);
  }
  tempX = mouseX; 
  tempY = mouseY;
}

void handle_mouse_bars_mode(){
    if ( (mouseX < 50) && (mouseY < 46) && (mouseY > 4)){
      peak_boost = 0;
    }
    if ( (mouseX < 50) && (mouseY < 94) && (mouseY > 52)){
      x_peak_neg = 0;
      x_peak_pos = 0;
    }
    if ( (mouseX < 50) && (mouseY < 142) && (mouseY > 100)){
      y_peak_neg = 0;
      y_peak_pos = 0;
    }
    if ( (mouseX < 50) && (mouseY < 190) && (mouseY > 148)){
      peak_temp1 = 0;
    }
    if ( (mouseX < 50) && (mouseY < 238) && (mouseY > 196)){
      peak_temp2 = 0;
    }
}

void handle_mouse_round_and_bar(){
  
}


void get_sensor_readings(){
  int value;
  value = Sensor.read();
  if (!strcmp(Sensor.getName(), "x")) {  
      accelx = getAccelerometerData(value)/100; //get the sensor value 
      //accelx = value;
      if ((accelx > x_peak_pos) && (accelx > 0)){
        x_peak_pos = accelx;
      }
      if ((accelx < x_peak_neg) && (accelx < 0)){
        x_peak_neg = accelx;
      }
      print_values_x();
      draw_bars_x();
    }
    if (!strcmp(Sensor.getName(), "y")) {  
      accely = getAccelerometerData(value)/100; //get the sensor value 
      //accely = value;
      if ((accely > y_peak_pos) && (accely > 0)){
        y_peak_pos = accely;
      }
      if ((accely < y_peak_neg) && (accely < 0)){
        y_peak_neg = accely;
      }        
      print_values_y();
      draw_bars_y();
    }
    if (!strcmp(Sensor.getName(), "t1")) {  
      temp1 = lookup_temp(value); //get the sensor value 
      //temp1 = value;
      if (temp1 > peak_temp1){
        peak_temp1 = temp1;
      }
      print_values_t1();
      draw_bars_t1();
    }
    if (!strcmp(Sensor.getName(), "t2")) {  
      temp2 = lookup_temp(value); //get the sensor value 
      //temp2=value;
      if (temp2 > peak_temp2){
        peak_temp2 = temp2;
      }
      print_values_t2();
      draw_bars_t2();
    }
    if (!strcmp(Sensor.getName(), "bt")){
      //boost = lookup_boost(value);
      boost=value;
      if (boost > peak_boost){
        peak_boost = boost;
      }
      print_values_boost();
      //draw_bars_boost();
    }  
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

void setup_bars(){
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
