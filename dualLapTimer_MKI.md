#How to implement a dual lap timer with the MK1.

##### Lap Timer #####

This is the Lap Timer code.  The timer is based on a 9hour timer that runs the moment the arduino starts up.  The 9 hour running time should not be a problem in a car installation.  However, it may be a problem if this device is used in other setting such as robotics, environmental monitoring, etc.

TODO for this code: Make each timer start and stop separately with hold to reset and double (A+B) button press to change modes.

A global variable stores the times so that even when switching modes the timer continues to 'run'.
```
  int timer_state = 0;
  long tempmillisT1 = 0;
  long tempmillisT2 = 0;
```

The main timer function (could be cleaned up a little bit as there is some repetitive code that could be made into other functions)
```
  void runTimer(){
  while (digitalRead(buttonApin) == LOW){
   }
  test_all_meters();
  if (timer_state == 0){
   LCDSerial.print(0xFE, BYTE);   
   LCDSerial.print(0x01, BYTE);
    LCDSerial.print(0xFE, BYTE);   //command flag
    LCDSerial.print(128, BYTE);  
    delay(20);
    LCDSerial.print("T1: 00:00:00.00");
   LCDSerial.print(0xFE, BYTE);   
   LCDSerial.print(192, BYTE);  
    LCDSerial.print("T2: 00:00:00.00"); 
    T1 = 0;
    T2 = 0;
    while (digitalRead(buttonBpin) == HIGH){
     //wait for start
     if (digitalRead(buttonApin) == LOW){
       return;
     } 
    }
    while (digitalRead(buttonBpin) == LOW){
      //we don't want to skip the start if you hold the button too long
     //timing actually happens on button release 
     timer_state = 1;
     tempmillisT1 = millis();
    }
  }
  if (timer_state == 1){
   LCDSerial.print(0xFE, BYTE);   
   LCDSerial.print(0x01, BYTE);
    LCDSerial.print(0xFE, BYTE);   
    LCDSerial.print(128, BYTE); 
    while (digitalRead(buttonBpin) == HIGH){
      test_all_meters();
      //timing
      if (digitalRead(buttonApin) == LOW){
        return;
      }
   LCDSerial.print(0xFE, BYTE);   
   LCDSerial.print(0x01, BYTE);
      T1 = millis() - tempmillisT1;
      //printing to the screen
      print_T1();
      //a short pause
      delay(50);
    }
    while (digitalRead(buttonBpin) == LOW){
      //stop T1 timing
      test_all_meters();
      timer_state = 2;
    }
  }
  if (timer_state == 2){ //timed shown on T1 and zeros on T2 waiting to start T2
    //display T1 if we cycle through modes and reach this
    //---
   LCDSerial.print(0xFE, BYTE);   
   LCDSerial.print(0x01, BYTE);
      //printing to the screen
      print_T1();
      //a short pause
      delay(50);
      
      //display T2 as zeros
   LCDSerial.print(0xFE, BYTE);   
   LCDSerial.print(192, BYTE);  
      LCDSerial.print("T2: 00:00:00.00"); 
    //---
    
    while (digitalRead(buttonBpin) == HIGH){
     //wait for timing T2
     if (digitalRead(buttonApin) == LOW){
      return;
     } 
     test_all_meters();
    }
    while (digitalRead(buttonBpin) == LOW){
     //clicking to start T2 
      timer_state = 3;
      tempmillisT2 = millis();
    }
  }
  if (timer_state == 3){ //T1 is displayed and T2 is running
    //display T1 if this mode is reache durring mode switching
    //--
   LCDSerial.print(0xFE, BYTE);   
   LCDSerial.print(0x01, BYTE);
      //printing to the screen
      print_T1();
      
    //--
    
    delay(10);

    while (digitalRead(buttonBpin) == HIGH){
      test_all_meters();
      if (digitalRead(buttonApin) == LOW){
        return;
       }
      //T2 timing 
      T2 = millis() - tempmillisT2;
      //printing to the screen
      print_T2();
      //a short pause
      delay(50);
    }
    while (digitalRead(buttonBpin) == LOW){
      //click to stop
      timer_state = 4;
    }
  }
  if (timer_state == 4){
   LCDSerial.print(0xFE, BYTE);   
   LCDSerial.print(0x01, BYTE);
    while (digitalRead(buttonBpin) == HIGH){ 
      //what to do if we've reached this direct thru mode switching
      //---
        //printing to the screen
        print_T1();
        //a short pause
        delay(50);
      
        //display T2
        print_T2();
        //a short pause
        delay(50);
       
    //---
      test_all_meters();
      if (digitalRead(buttonApin) == LOW){
        return;
      }
    }
    while (digitalRead(buttonBpin) == LOW){}
    //on release return to main loop
    timer_state = 0;
  }
  return;
  }

The display functions for the timer:
  void print_T1 (){
     //printing to the screen
     LCDSerial.print(0xFE, BYTE);   
     LCDSerial.print(128, BYTE); 
     unsigned long T1millis = T1%1000/10;
     unsigned long T1seconds = T1%60000/1000;
     unsigned long T1minutes = T1%3600000/60000;
     unsigned long T1hours = T1/3600000;
     LCDSerial.print("T1: ");
     printInTens(T1hours);
     LCDSerial.print(":");
     printInTens(T1minutes);
     LCDSerial.print(":");
     printInTens(T1seconds);
     LCDSerial.print(".");
     printInTens(T1millis);
  }

  void print_T2 (){
     //printing to the screen
   LCDSerial.print(0xFE, BYTE);   
   LCDSerial.print(192, BYTE);  
     unsigned long T2millis = T2%1000/10;
     unsigned long T2seconds = T2%60000/1000;
     unsigned long T2minutes = T2%3600000/60000;
     unsigned long T2hours = T2/3600000;
     LCDSerial.print("T2: ");
     printInTens(T2hours);
     LCDSerial.print(":");
     printInTens(T2minutes);
     LCDSerial.print(":");
     printInTens(T2seconds);
     LCDSerial.print(".");
     printInTens(T2millis);
  }
```