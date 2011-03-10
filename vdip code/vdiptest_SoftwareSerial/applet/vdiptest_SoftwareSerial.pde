
#include <AFSoftSerial.h>

int incomingByte=0;
int fileNumber=1;
int noOfChars;
long int valToWrite;
char activityToLog;
long int x;
long int startLogTime = 0;

#define rxPin 2
#define txPin 3

AFSoftSerial vSerial = AFSoftSerial(rxPin, txPin);

void setup() {
        Serial.begin(9600);
  
	vSerial.begin(9600);	              // opens serial port, sets data rate to 9600 bps
        vSerial.print("IPA");                  // sets the vdip to use ascii numbers (so I can read them in the code easily!)
        vSerial.print(13, BYTE);               // return character to tell vdip its end of message
        delay(10000);  //10 seconds to init the disk before writing (some disks may take longer)

}

void loop() {

  //get_file_num();
  
  vSerial.print("OPW LOG%");                  // open to write creates a file - named
  vSerial.print(fileNumber);                  // LOG%1.TXT first time round - .TXT is for the computer
  vSerial.print(".TXT");                      // I have used the % sign in the name so I can search the disk for log files that it has created so as not to overwrite any that may be on already
  vSerial.print(13, BYTE);                    // return character

  delay(1000);
  
 vSerial.print("WRF ");               //write to file (file needs to have been opened to write first)
 vSerial.print(6);            //needs to then be told how many characters will be written
 vSerial.print(13, BYTE);             //return to say command is finished
 vSerial.print("123456");        //followed by the info to write
 vSerial.print(13, BYTE);             //write a return to the contents of the file (so each entry appears on a new line)
 delay(1000);
  vSerial.print("CLF LOG%");     // it closes the file
  vSerial.print(fileNumber);     // LOG%1.TXT
  vSerial.print(".TXT");
  vSerial.print(13, BYTE);       // return character

 fileNumber++;                                    //so we can create other files
  
  delay(10000);
 
  
}

 
void get_file_num(){ 
   vSerial.print("DIR");
   vSerial.print(13, BYTE);
   delay(1000);  //wait a second
   
   while (char i = vSerial.read()){ //umlauted Ø should be check character...ie hex 98 or dec 152
	Serial.print(i); //debug to serial monitor on IDE
	if (i == '%'){
          fileNumber = vSerial.read() + 1; //should work, but might have to convert to int and back
	}
        if (i == 'Ø'){
          return;
        }
   }
   
   delay(10000);
} 
