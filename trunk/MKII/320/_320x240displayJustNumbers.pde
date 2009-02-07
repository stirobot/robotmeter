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
  
  //canvas stuff
  beginCanvas();
  background(0,0,0); 
  stroke(255,255,255);
  fill(0,0,0); 
}

void loop() {
  background(0,0,0); //blank the screen black
  //labels
  text("meter demo", 100, 5);
  text(" boost pressure: ", 18, 18);
  text("oil temperature: ", 18, 38);
  text("  temperature 1: ", 18, 58);
  text("  temperature 2: ", 18, 78);
  text("accelerometer x: ", 18, 98);
  
  while (!(touch_get_cursor(&m_point))){
    Serial.print('U'); //handshake
    while (Serial.read() != 'U'){}
    Serial.print('F'); //request for data block
    boost = getAValue();
    oilT = getAValue(); 
    temp1 = getAValue();
    temp2 = getAValue();
    Serial.print('U'); //handshake
    while (Serial.read() != 'U'){}
    Serial.print('X'); //request a data block
    accelx = getAValue();
    //display data here
    text((float)boost, 100, 18);
    text((float)oilT, 100, 38);
    text((float)temp1, 100, 58);
    text((float)temp2, 100, 78);
    text((float)accelx, 100, 98);
  
    delay(100); //delay so things are readable
  }
  while (touch_get_cursor(&m_point)){}
  background(0,0,0);
  bmp_draw("mockup",0,0);
  
  //wait until screen is touched
  while(!touch_get_cursor(&m_point)){}
  while(touch_get_cursor(&m_point)){}
}

float getAValue(){
  float getValue = Serial.read();
  getValue = (getValue << 8) + Serial.read(); 
  getValue = (getValue << 16) + Serial.read();
  getValue = (getValue << 24) + Serial.read();
  Serial.print('C');
  return getValue;
}
