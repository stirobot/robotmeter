/*
//credits and such
 -adafruit libraries
 -adafruit bmp and graphics examples, which were very helpful...some of the code is reused here
 -pinouts for lcd...credited below
 
 //M3 sketch
 modes:
 1) water temp big/bar w/peak + little oil p/oil t
 2) big oil t + little oil p/water t
 3) big oil p + little oil t/water t (this should be a rotation thing)
 4) accelerometer + tiny water bar/color coded
 
 develop later:
 round dials
 history plots
 startup graphics animation
 flashing warnings
 piezo warnings
 
 todo:
 create starup graphic "//M"
 spinning //m or spinning //m to car?
 create warning graphic
 curve for water temp sensor
 delete all serial printing stuff
 add graphics drawing functions
 add hold on button to reset
  
 //pin reference for tft from;
 http://webshed.org/wiki/18tftbreakout
 eBay Board	 Adafruit Board	Arduino conections
 VCC	 VCC	 5V
 BKL	 LITE	 GND on eBay, 5V on Adafruit
 RESET	 RESET	 8
 RS	 D/C	 9
 MISO	 MISO	 12
 MOSI	 MOSI	 11
 SCLK	 SCLK	 13
 LCD CS	 TFT CS	 10
 SD CS	 CARD CS 4	
 GND	 GND	 GND
 
 //*****global vars*****
/**********************/

#define SD_CS   4
#define LCD_CS   10
#define LCD_DC   9
#define LCD_RST  8  

#include <Adafruit_GFX.h>    // Core graphics library
#include <Adafruit_ST7735.h> // Hardware-specific library
#include <SPI.h> 
#include <SD.h>

Adafruit_ST7735 tft = Adafruit_ST7735(LCD_CS, LCD_DC, LCD_RST);

int mode = 1;

//two buttons:
int buttonApin = 6;
int buzzerPin = 2;

//global peaks...so that you can switch modes and preserve peaks
long oil_psi_peak = 0;
long temp_peak = 0;
int negpeak = 0;
int pospeak = 0;
int pospeakcount = 0;
int negpeakcount = 0;

//accel zeroing
int zerogy = 512;
int zerogx = 512;

//pins for sensors
int tempPin = 1;
int pressurePin = 2;
int coolantPin = 3;
int xval = 4;
int yval = 5;

//allows for doing something at startup
boolean startuptempswitch = false; 

void setup(){
  Serial.begin(9600);
  tft.initR(INITR_BLACKTAB);
  tft.fillScreen(ST7735_BLACK);

  tft.setRotation(1);
  //splash screen
  Serial.print("SD card start");
  if (!SD.begin(SD_CS)){
    Serial.println("failed to initialize SD");
    return;
  }
  Serial.println("SD OK");

  for (int b=0; b < 5; b++){ 
    tone(2,1500);
    delay(500);
    noTone(2);
  }

  bmpDraw("e36side.bmp",0,0);
  //delay(10);
  bmpDraw("r.bmp",0,0);
  //delay(10);

  int tempreading = analogRead(yval);
  if ((tempreading < 800) && (tempreading > 200)){
    zerogy = tempreading;
  }
  else {
    zerogy = 512;
  }
  tempreading = analogRead(xval);
  if (true) { //((tempreading < 800) && (tempreading > 200)){
    zerogx = tempreading;
  }
  else {
    zerogx = 512;
  }
  //setup the buttons as inputs
  pinMode(buttonApin, INPUT);
}

void loop(){
  //WHAT MODE
  if (digitalRead(buttonApin) == HIGH){
    while (digitalRead(buttonApin)){
      //avoids flipping modes rapidly
    }
    if (mode == 1){
      mode=2;
    }
    else if (mode == 2){
      mode=3;
    }
    else if (mode == 3){
      mode=4;
    }
    else mode = 1;
  }
  if (mode == 1) {
    coolantT_oilT_oilP();
  }
  if (mode == 2){
    oilT_oilP_coolantT(); 
  }
  if (mode == 3){
    oilP_oilT_coolantT(); 
  }
  if (mode == 4){
    accelerometer(); 
  }
}

//code for specific modes:

//accelerometer readings
//x: <number> / <peaknumber>
//y: <number> / <peaknumber>
//scatterplot thing
//small coolantT line
void accelerometer(){
  tft.fillScreen(ST7735_BLACK);
  tft.setCursor(0,0);
  tft.setTextColor(ST7735_RED);
  tft.setTextSize(2);
  tft.print("X");
  tft.setCursor(0,64);
  tft.print("Y");
  
  tft.setTextSize(1);
  tft.setTextColor(ST7735_GREEN);
  tft.setCursor(154,0);
  tft.print("C");
  
  if (startuptempswitch == true){
    while (digitalRead(buttonApin) == HIGH){
    }
  }
  while (digitalRead(buttonApin) == HIGH){
  }
  //test_all_meters();
  while (digitalRead(buttonApin) == LOW){
    startuptempswitch = true;
    int accelx = getAccelerometerData(xval);
    int accely = getAccelerometerData(yval);
    int coolantTemp = 130;//getCoolantTemp(coolantPin);
    pospeakcount++;
    negpeakcount++;

    peak(accely);
  }
}

void oilT_oilP_coolantT(){
  return;
}

void oilP_oilT_coolantT(){
  return;
}


void coolantT_oilT_oilP(){
  return;
}

//displays one item as big number and indicator
//  and two as small numbers and indicators
void oneBigTwoSmall(){
  return;
}

void temp_meter(){
  if (startuptempswitch == false){
    while (digitalRead(buttonApin) == HIGH){
    }
  }
  Serial.write(0xFE);   
  Serial.write(0x01);
  Serial.write(0xFE);   
  Serial.write(128); 
  long reading = 0;
  while (digitalRead(buttonApin) == LOW){
    //test_all_meters(); 
    //non sensor code
    reading = reading + 10;
    //real reading code
    //0 psi = 12 Vcount;
    //reading = lookup_oil_temp( long(analogRead(tempPin)) ); 
    if ((startuptempswitch == false) && (reading > 1300)){
      mode = 2;
      Serial.write(0xFE);  
      Serial.write(0x01); //clear LCD
      Serial.write(0xFE);   
      Serial.write(128);  
      Serial.print("Engine Warmed");
      for (int i=0; i<50;i++){
        warn_flash();
      }
      delay(1500);  
      return;
    }
    temp_peak = max (reading, temp_peak); 
    //generic_bar_display ("psi", 1700, reading, oil_psi_peak, 1450, 0, true);
    generic_bar_display ("tmp", 3500, reading, temp_peak, 2600, 0, true);
    delay(50);    
  }
  return;
}

void temp_and_pressure(){
  while (digitalRead(buttonApin) == HIGH){
  }
  long reading1 = 0;
  long reading2 = 0;
  while (digitalRead(buttonApin) == LOW){
    //test_all_meters();
    //reading1 = random(100,350);
    reading1 = lookup_oil_temp(analogRead(tempPin));
    reading2 = lookup_oil_psi( long(analogRead(pressurePin)) );
    temp_peak = max (temp_peak, reading1);
    oil_psi_peak = max (oil_psi_peak, reading2); 
    generic_dual_display ("tmp", 3500, reading1, temp_peak, 2000, 0, true, "psi", 1700, reading2, oil_psi_peak, 1450, 0, true);
    delay(50);    
  }
  return;
}

void oil_psi_meter(){ 
  while (digitalRead(buttonApin) == HIGH){
  }
  Serial.write(0xFE);   
  Serial.write(0x01);
  Serial.write(0xFE);   
  Serial.write(128); 
  long reading = 0;
  while (digitalRead(buttonApin) == LOW){
    //test_all_meters();b 
    //non sensor code
    //reading = reading + 1;
    //real reading code
    //0 psi = 12 Vcount;
    reading = lookup_oil_psi( long(analogRead(pressurePin)) ); 
    oil_psi_peak = max (reading, oil_psi_peak); 
    generic_bar_display ("psi", 1700, reading, oil_psi_peak, 1450, 0, true);
    delay(50);    
  }
  return;
}

//code for generic graphs:

void printAccelerometerReadout(int reading){
  if (reading >= 0 ) {
    Serial.print("+");
  }
  if (reading < 0) {
    Serial.print("-");
  }

  int afterdecimal = reading % 100;
  Serial.print(abs(reading/100));
  if ( (afterdecimal > 9) || (afterdecimal < -9) ){
    Serial.print(".");
  }
  else {
    Serial.print(".0");
  }
  Serial.print(abs(afterdecimal));
}

//positive only value 0 to X
//only 4 char titles (should be changed soon)
//1234567890123456
//TMP 134.5/ 314.5
//psi 14.5 /  14.5 
//oil 1.0  /   1.4
//oil 0.3  /   0.4
void generic_bar_display(char title[ ], long high, long cur_value, long peak, long hiWarn, long loWarn, boolean hiloswitch){
  int ndigits = 0;
  Serial.write(0xFE);  
  Serial.write(128);
  Serial.print(title);
  if( (hiloswitch == true) && (cur_value == 0) ){
    Serial.print("LOW ");
  } 
  if ( (hiloswitch == true) && (cur_value == 9999) ){
    Serial.print("HIGH "); 
  }
  else {
    Serial.print(" ");
    Serial.print(cur_value/10);
    Serial.print(".");
    Serial.print(cur_value%10);
    ndigits = numberofdigits(cur_value) + 1;
    if (ndigits <= 2){ 
      ndigits = ndigits + 1;
    }
    for (int i = 0; i < 5 - ndigits; i++) {
      Serial.print(" "); 
    }
  }
  Serial.print("/");
  ndigits = numberofdigits(peak) + 1;
  if (ndigits <= 2){ 
    ndigits = ndigits + 1;
  }
  for (int i = 0; i < 6 - ndigits; i++){
    Serial.print(" "); 
  }
  Serial.print(peak/10);
  Serial.print(".");
  Serial.print(peak%10);
  if ( (cur_value > hiWarn) || (cur_value < loWarn) ){ //blink if warning threshold is met
    warn_flash();
  }
  Serial.write(0xFE);   
  Serial.write(192);  
  unsigned long abar = high/16;
  unsigned long n_bars = cur_value/abar;
  if (cur_value <= 0){
    n_bars=0;
  }
  for(int i=1; i< n_bars; i++){ 
    Serial.write(0xFF);
  }
  for (int i=1; i < (16 - n_bars); i++){
    Serial.print(" "); 
  }
  delay(100); //gauge refresh rate in ms
}

//use only 4 char titles (should be changed soon)
void generic_dual_display (char title1[ ], long high1, long cur_value1, long peak1, long hiWarn1, long loWarn1, boolean hilo1, char title2[ ], long high2, long cur_value2, long peak2, long hiWarn2, long loWarn2, boolean hilo2){
  int ndigits = 0;
  Serial.write(0xFE);  
  Serial.write(128);
  Serial.print(title1);
  Serial.print(" ");
  if ( (hilo1 == true) && (cur_value1 == 0) ){
    Serial.print("LOW  "); 
  }
  else if ( (hilo1 == true) && (cur_value1 == 9999) ){
    Serial.print("HIGH  "); 
  }
  else {
    Serial.print(cur_value1/10);
    Serial.print(".");
    Serial.print(cur_value1%10);
    ndigits = numberofdigits(cur_value1) + 1;
    if (ndigits <= 2){ 
      ndigits = ndigits + 1;
    }
    for (int i = 0; i < 5 - ndigits; i++) {
      Serial.print(" "); 
    }
  }
  Serial.print("/");
  ndigits = numberofdigits(peak1) + 1;
  if (ndigits <= 2){ 
    ndigits = ndigits + 1;
  }
  for (int i = 0; i < 6 - ndigits; i++){
    Serial.print(" "); 
  }
  Serial.print(peak1/10);
  Serial.print(".");
  Serial.print(peak1%10);
  if ( (cur_value1 > hiWarn1) || (cur_value1 < loWarn1) ){ //blink if warning threshold is met
    warn_flash();
  }
  Serial.write(0xFE);   //select the second line
  Serial.write(192);  
  Serial.print(title2);
  Serial.print(" ");
  if ( (hilo2 == true) && (cur_value2 == 0) ){
    Serial.print("LOW  ");
  }
  else if ( (hilo2 == true) && (cur_value2 == 9999) ){
    Serial.print("HIGH ");
  }
  else {
    Serial.print(cur_value2/10);
    Serial.print(".");
    Serial.print(cur_value2%10);
    ndigits = numberofdigits(cur_value2) + 1;
    if (ndigits <= 2){ 
      ndigits = ndigits + 1;
    }
    for (int i = 0; i < 5 - ndigits; i++) {
      Serial.print(" "); 
    }
  }
  Serial.print("/");
  ndigits = numberofdigits(peak2) + 1;
  if (ndigits <= 2){ 
    ndigits = ndigits + 1;
  }
  for (int i = 0; i < 6 - ndigits; i++){
    Serial.print(" "); 
  }
  Serial.print(peak2/10);
  Serial.print(".");
  Serial.print(peak2%10);
  if ( (cur_value2 > hiWarn2) || (cur_value2 < loWarn2) ){ //blink if warning threshold is met
    warn_flash();
  }
  delay(100);
}

void printBarGraph(int y) { 
  //clear the 1st 8 spacesb
  if ( y >= 0){
    Serial.print("        ");  
    for(int i=1; i <= y/16; i++){
      Serial.write(0xFF);
    }
    //fill the rest with spacesloo
    for(int i=1; i <= (8-y/16); i++){ 
      Serial.print(" "); 
    }
  }
  if (y < 0) {
    //1 - print spaces at the beginning
    for (int i=1; i <= (8-abs(y/16)); i++){
      Serial.print(" "); 
    }
    //2 - print blocks till the middle
    for (int i=1; i <= abs(y/16); i++){
      Serial.write(0xFF);
    }
    //3 - print spaces till the end
    for (int i=1; i<=8; i++){
      Serial.print(" ");
    }
  }

  //print the peaks if there are any
  //negative
  Serial.write(0xFE);  
  Serial.write(128);
  if (negpeak/16 < 0){
    Serial.write(0xFE);
    int npos = 128 + (8 - abs(negpeak/16));
    Serial.write(npos);
    Serial.write(0xFF);
  }

  //positive
  if (pospeak/16 > 0){
    Serial.write(0xFE);
    int ppos = 128 + (8 + (pospeak/16));
    Serial.write(ppos);
    Serial.write(0xFF);
  }

}

//lookups for sensors:

//accelerometer
int getAccelerometerData (int axis){
  int zerog = 512;
  if (axis == 5){
    zerog = zerogy;
  }
  if (axis == 3){
    zerog = zerogx; 
  }

  int rc = analogRead(axis);
  int top =( (zerog - rc) ) ; 
  float frtrn = (((float)top/(float)154)*100);  //158Vint jumps are 1g for the ADXL213AE (original accel)
  //154Vint jumps are 1g for the ADXL322 (updated one)
  int rtrn = (int)frtrn;
  return rtrn;
}

//oil temp
long lookup_oil_temp(long tval){
  tval = tval * 1000; //added an extra 0
  if (tval <= 11500){
    return (9999); 
  }
  if (tval >= 68100){
    return (0);
  }
  if ((tval <= 68000)&&(tval > 39600)){
    return (long)(((tval-134266)*10)/(-473));
  }
  if ((tval <= 39600)&&(tval > 28200)){
    return (long)(((tval-115600)*10)/(-380));
  }
  if ((tval <= 28200)&&(tval > 19700)){
    return (long)(((tval-93366)*10)/(-283));
  }  
  if ((tval <= 19700)&&(tval > 11600)){
    return (long)(((tval-54800)*10)/(-135));
  }  
}

//oil pressure
long lookup_oil_psi(long psival){
  if (psival > 722){
    return (0);
  }
  if (psival < 257){
    return(9999);
  }
  if ((psival <= 722)&&(psival > 619)) {
    return 1747 - (psival*240)/100; 
  } 
  if ((psival <= 619)&&(psival > 520)) {
    return 1802 - (psival*250)/100;
  }
  if ((psival <= 520)&&(psival > 411)) {
    return 1694 - (psival*230)/100;     
  }
  if ((psival <= 411)&&(psival > 257)){
    return 1418 - (psival*160)/100;
  }
} 

//test all meters:

//misc helper functions:
void warn_flash(){
  Serial.write(0x7C);  
  Serial.write(128);  //backlight off
  Serial.write(0x7C);  
  Serial.write(157);  //backlight on
  delay(300);
}

int numberofdigits(long value){

  int digits = 1;
  while (value/10 > 0){
    value = value/10;
    digits++; 
  }

  if (value < 0){
    digits ++;
  }
  return digits; 
}

void peak(int val){

  if ( (val > 0) && (val > pospeak) ){       //pos peak compare and set
    pospeak = val;
    pospeakcount = 0;
  }

  if ( (val < 0) && (val < negpeak) ) {     //neg peak compare and set 
    negpeak = val;
    negpeakcount = 0;
  }

  else {                                    //peak mark expires after x time
    if (pospeakcount >= 20){
      pospeakcount = 0;
      pospeak = 0;
    }
    if (negpeakcount >= 20){
      negpeakcount = 0;
      negpeak = 0;
    }
  }
}

#define BUFFPIXEL 20

void bmpDraw(char *filename, uint8_t x, uint8_t y) {

  File     bmpFile;
  int      bmpWidth, bmpHeight;   // W+H in pixels
  uint8_t  bmpDepth;              // Bit depth (currently must be 24)
  uint32_t bmpImageoffset;        // Start of image data in file
  uint32_t rowSize;               // Not always = bmpWidth; may have padding
  uint8_t  sdbuffer[3*BUFFPIXEL]; // pixel buffer (R+G+B per pixel)
  uint8_t  buffidx = sizeof(sdbuffer); // Current position in sdbuffer
  boolean  goodBmp = false;       // Set to true on valid header parse
  boolean  flip    = true;        // BMP is stored bottom-to-top
  int      w, h, row, col;
  uint8_t  r, g, b;
  uint32_t pos = 0, startTime = millis();

  if((x >= tft.width()) || (y >= tft.height())) return;

  Serial.println();
  Serial.print("Loading image '");
  Serial.print(filename);
  Serial.println('\'');

  // Open requested file on SD card
  if ((bmpFile = SD.open(filename)) == NULL) {
    Serial.print("File not found");
    return;
  }

  // Parse BMP header
  if(read16(bmpFile) == 0x4D42) { // BMP signature
    Serial.print("File size: "); 
    Serial.println(read32(bmpFile));
    (void)read32(bmpFile); // Read & ignore creator bytes
    bmpImageoffset = read32(bmpFile); // Start of image data
    Serial.print("Image Offset: "); 
    Serial.println(bmpImageoffset, DEC);
    // Read DIB header
    Serial.print("Header size: "); 
    Serial.println(read32(bmpFile));
    bmpWidth  = read32(bmpFile);
    bmpHeight = read32(bmpFile);
    if(read16(bmpFile) == 1) { // # planes -- must be '1'
      bmpDepth = read16(bmpFile); // bits per pixel
      Serial.print("Bit Depth: "); 
      Serial.println(bmpDepth);
      if((bmpDepth == 24) && (read32(bmpFile) == 0)) { // 0 = uncompressed

        goodBmp = true; // Supported BMP format -- proceed!
        Serial.print("Image size: ");
        Serial.print(bmpWidth);
        Serial.print('x');
        Serial.println(bmpHeight);

        // BMP rows are padded (if needed) to 4-byte boundary
        rowSize = (bmpWidth * 3 + 3) & ~3;

        // If bmpHeight is negative, image is in top-down order.
        // This is not canon but has been observed in the wild.
        if(bmpHeight < 0) {
          bmpHeight = -bmpHeight;
          flip      = false;
        }

        // Crop area to be loaded
        w = bmpWidth;
        h = bmpHeight;
        if((x+w-1) >= tft.width())  w = tft.width()  - x;
        if((y+h-1) >= tft.height()) h = tft.height() - y;

        // Set TFT address window to clipped image bounds
        tft.setAddrWindow(x, y, x+w-1, y+h-1);

        for (row=0; row<h; row++) { // For each scanline...

          // Seek to start of scan line.  It might seem labor-
          // intensive to be doing this on every line, but this
          // method covers a lot of gritty details like cropping
          // and scanline padding.  Also, the seek only takes
          // place if the file position actually needs to change
          // (avoids a lot of cluster math in SD library).
          if(flip) // Bitmap is stored bottom-to-top order (normal BMP)
            pos = bmpImageoffset + (bmpHeight - 1 - row) * rowSize;
          else     // Bitmap is stored top-to-bottom
          pos = bmpImageoffset + row * rowSize;
          if(bmpFile.position() != pos) { // Need seek?
            bmpFile.seek(pos);
            buffidx = sizeof(sdbuffer); // Force buffer reload
          }

          for (col=0; col<w; col++) { // For each pixel...
            // Time to read more pixel data?
            if (buffidx >= sizeof(sdbuffer)) { // Indeed
              bmpFile.read(sdbuffer, sizeof(sdbuffer));
              buffidx = 0; // Set index to beginning
            }

            // Convert pixel from BMP to TFT format, push to display
            b = sdbuffer[buffidx++];
            g = sdbuffer[buffidx++];
            r = sdbuffer[buffidx++];
            tft.pushColor(tft.Color565(r,g,b));
          } // end pixel
        } // end scanline
        Serial.print("Loaded in ");
        Serial.print(millis() - startTime);
        Serial.println(" ms");
      } // end goodBmp
    }
  }

  bmpFile.close();
  if(!goodBmp) Serial.println("BMP format not recognized.");
}

// These read 16- and 32-bit types from the SD card file.
// BMP data is stored little-endian, Arduino is little-endian too.
// May need to reverse subscript order if porting elsewhere.

uint16_t read16(File f) {
  uint16_t result;
  ((uint8_t *)&result)[0] = f.read(); // LSB
  ((uint8_t *)&result)[1] = f.read(); // MSB
  return result;
}

uint32_t read32(File f) {
  uint32_t result;
  ((uint8_t *)&result)[0] = f.read(); // LSB
  ((uint8_t *)&result)[1] = f.read();
  ((uint8_t *)&result)[2] = f.read();
  ((uint8_t *)&result)[3] = f.read(); // MSB
  return result;
}













