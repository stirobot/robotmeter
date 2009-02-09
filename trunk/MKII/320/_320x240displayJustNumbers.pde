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
  
  //canvas stuff
  //beginCanvas();
  background(0,0,0); 
  stroke(255,255,255);
  fill(255,255,255); 
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
  /*lcd_puts(" boost pressure: ", 18, 18, mwhite, mblack);
  lcd_puts("oil temperature: ", 18, 38, mwhite, mblack);
  lcd_puts("  tempearture 1: ", 18, 58, mwhite, mblack);
  lcd_puts("  temperature 2: ", 18, 78, mwhite, mblack);
  lcd_puts("accelerometer x: ", 18, 98, mwhite, mblack);*/
  
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
    
   /* char out[7];
    fmtDouble((double)boost, 2, out, 7);
    lcd_puts(out, 100, 18, mwhite, mblack);
    fmtDouble((double)oilT, 2, out, 7);
    lcd_puts(out, 100, 38, mwhite, mblack);
    fmtDouble((double)temp1, 2, out, 7);
    lcd_puts(out, 100, 58, mwhite, mblack);     
    fmtDouble((double)temp2, 2, out, 7);
    lcd_puts(out, 100, 78, mwhite, mblack);
    fmtDouble((double)accelx, 2, out, 7);
    lcd_puts(out, 100, 98, mwhite, mblack);
  */
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
  float getValue = (Serial.read() << 24) + (Serial.read() << 16) + (Serial.read() << 8) + Serial.read(); 
  //float getValue = Serial.read();
  getValue = (getValue << 8) + Serial.read();
  getValue = (getValue << 16) + Serial.read();
  getValue = (getValue << 24) + Serial.read();
  Serial.print('C');
  return getValue;
}
/*
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
} */
