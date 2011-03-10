/*COLOR mwhite ={255,255,255};
COLOR mblack ={1,1,1};*/

//simple sketch to check sensor functionality 

float boost = 0;
float oilT = 0;
float temp1 = 0;
float temp2 = 0;
float accely = 0;
float accelx = 0;

POINT m_point;

void setup (){
  //communications with arduino basics
  Serial.begin(9600); 
  delay(3000);
  Serial.print('U');
  //canvas stuff
  //beginCanvas();
  background(0,0,0); 
  stroke(255,255,255);
  fill(255,255,255); 
}

void loop() {
  background(0,0,0); //blank the screen black
  //labels
  text("meter demo (work in progress disregard any readings!)", 0, 5);
  text("  temperature 1: ", 18, 58);
  text("  temperature 2: ", 18, 78);
  text(" boost pressure: ", 18, 18);
  text("oil temperature: ", 18, 38);
 
  text("accelerometer x: ", 18, 98);
  
  while (!(touch_get_cursor(&m_point))){
    Serial.print('F'); //request for data block
    temp1 = getAValue();
    temp2 = getAValue();
    boost = getAValue();
    oilT = getAValue(); 
    Serial.print('X'); //request a data block
    accelx = getAValue();
    //display data here
    text((float)temp1, 120, 58);
    text((float)temp2, 120, 78);
    text((float)boost, 120, 18);
    text((float)oilT, 120, 38);
    text((float)accelx, 120, 98);

    delay(100); //delay so things are readable
  }
  while (touch_get_cursor(&m_point)){}
  background(0,0,0);
  bmp_draw("mockbig",0,0);
  
  //wait until screen is touched
  while(!touch_get_cursor(&m_point)){}
  while(touch_get_cursor(&m_point)){}
}

float getAValue(){
  //while(Serial.available()){}
  int getValue = Serial.read();
  getValue = (getValue << 8) + Serial.read();
  float getValueF = (float)getValue / 10;
  //Serial.print('C');
  delay(20);
  //while(Serial.read()!='C'){}
  return getValueF;
}
