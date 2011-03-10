int incomingByte=0;
int fileNumber=1;
int noOfChars;
long int valToWrite;
char activityToLog;
long int x;
long int startLogTime = 0;
void setup() {
	Serial.begin(9600);	              // opens serial port, sets data rate to 9600 bps
        Serial.print("IPA");                  // sets the vdip to use ascii numbers (so I can read them in the code easily!)
        Serial.print(13, BYTE);               // return character to tell vdip its end of message
        delay(10000);  //60 seconds to init the disk before writing

}

void loop() {


  Serial.print("OPW LOG");                  // open to write creates a file - named
  Serial.print(fileNumber);                  // LOG%1.TXT first time round - .TXT is for the computer
  Serial.print(".TXT");                      // I have used the % sign in the name so I can search the disk for log files that it has created so as not to overwrite any that may be on already
  Serial.print(13, BYTE);                    // return character

  delay(1000);
  
 Serial.print("WRF ");               //write to file (file needs to have been opened to write first)
 Serial.print(6);            //needs to then be told how many characters will be written
 Serial.print(13, BYTE);             //return to say command is finished
 Serial.print("123456");        //followed by the info to write
 Serial.print(13, BYTE);             //write a return to the contents of the file (so each entry appears on a new line)
 delay(1000);
  Serial.print("CLF LOG");     // it closes the file
  Serial.print(fileNumber);     // LOG%1.TXT
  Serial.print(".TXT");
  Serial.print(13, BYTE);       // return character

  fileNumber++;                                    //so we can create other files
  
  delay(10000);

}
