#How the accelerometer works.
##### Accelerometer #####

This sensor measures the G forces +/-2G's on the car at any given time.  Logging these may give reasonable estimates of braking power, cornering ability and horsepower.


The sensor used is an ADXL322 on a sparkfun breakout board:
  * [sparkfun product page](http://www.sparkfun.com/commerce/product_info.php?products_id=849)
  * [datasheet](http://www.sparkfun.com/datasheets/Accelerometers/ADXL320_0.pdf)

This accelerometer was chosen due to its cost, accuracy, measurement range, and ease of integration due to its 0-5v output.

Code to read from the acceleromter:
```
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
  float frtrn = (((float)top/(float)158)*100);  //158Vint jumps are 1g for the ADXL213AE (original accel)
  //154Vint jumps are 1g for the ADXL322 (updated one)
  int rtrn = (int)frtrn;
  return rtrn;
  }
```

Code to zero the left/right axis of the accerlerometer upon startup in case it is slightly off:
```
  int tempreading = analogRead(yval);
  if ((tempreading < 600) && (tempreading > 400)){
    zerogy = tempreading;
    LCDSerial.print("1");
  }
  else {
    zerogy = 512;
    LCDSerial.print("2");
  }
  tempreading = analogRead(xval);
  if ((tempreading < 600) && (tempreading > 400)){
    zerogx = tempreading;
  }
  else {
    zerogx = 512;
  }
```

---


##### The Accelerometer Display #####

The accelerometer uses a unique display that resembles a VU meter on an expensive stereo system.  It holds its peaks on a horizontal bar with 0 in the center for a number of seconds.
```
void printBarGraph(int y) { 
  //clear the 1st 8 spaces
  if ( y >= 0){
    LCDSerial.print("        ");  
    for(int i=1; i <= y/16; i++){
       LCDSerial.print(0xFF, BYTE);
    }
    //fill the rest with spacesloo
    for(int i=1; i <= (8-y/16); i++){ 
      LCDSerial.print(" "); 
    }
  }
  if (y < 0) {
    //1 - print spaces at the beginning
    for (int i=1; i <= (8-abs(y/16)); i++){
      LCDSerial.print(" "); 
    }
    //2 - print blocks till the middle
    for (int i=1; i <= abs(y/16); i++){
      LCDSerial.print(0xFF, BYTE);
    }
    //3 - print spaces till the end
    for (int i=1; i<=8; i++){
      LCDSerial.print(" ");
    }
  }
```