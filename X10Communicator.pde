// X10 communication system
// codes can be typed on the serial line
// and will be sent
// codes received will be printed back
//
// X10 recieve code from an example by Brohogan
//
// (c) 2012 strawdog3@gmail.com
//
// License:  An ye harm none, do as ye will
//
// Defines and constants for PSC05 receiving

#define OFFSET_DELAY     500 	// uS from zero cross to center of bit (sugg 500-700 us)
#define HALF_CYCLE_DELAY 8334 	// Calculated 8334 uS between bit repeats in a half-cycle

#ifndef ON                      // use same defines from x10constants.h for rcvd cmnds
#define ON   B00101             // these are examples
#endif
#ifndef OFF
#define OFF  B00111
#endif

byte House[16] = {              // Lookup table for House Code
  B0110,  // A
  B1110,  // B
  B0010,  // C
  B1010,  // D
  B0001,  // E
  B1001,  // F
  B0101,  // G
  B1101,  // H
  B0111,  // I
  B1111,  // J
  B0011,  // K
  B1011,  // L
  B0000,  // M
  B1000,  // N
  B0100,  // O
  B1100,  // P
};

byte Unit[16] = {               // Lookup table for Unit Code
  B01100,  // 1
  B11100,  // 2
  B00100,  // 3
  B10100,  // 4
  B00010,  // 5
  B10010,  // 6
  B01010,  // 7
  B11010,  // 8
  B01110,  // 9
  B11110,  // 10
  B00110,  // 11
  B10110,  // 12
  B00000,  // 13
  B10000,  // 14
  B01000,  // 15
  B11000,  // 16
};

#include "WProgram.h"                  // this is needed to compile with Rel. 0013
#include <x10.h>                       // X10 lib is used for transmitting X10
#include <x10constants.h>              // X10 Lib constants
#define RPT_SEND 2                     // how many times transmit repeats if noisy set higher

//#include "PSC05.h"                     // constants for PSC05 X10 Receiver
#define OUT0      8               // YEL pin 4 of PSC05
#define OUT1      9               // YEL pin 4 of PSC05
#define TRANS_PIN      5               // YEL pin 4 of PSC05
#define RCVE_PIN       4               // GRN pin 3 of PSC05
#define ZCROSS_PIN     2               // BLK pin 1 of PSC05
#define LED_PIN        13              // for testing 

volatile unsigned long mask;           // MSB first - bit 12 - bit 0
volatile unsigned int X10BitCnt = 0;   // counts bit sequence in frame
volatile unsigned int ZCrossCnt = 0;   // counts Z crossings in frame
volatile unsigned long rcveBuff;       // holds the 13 bits received in a frame
volatile boolean X10rcvd = false;      // true if a new frame has been received
boolean newX10 = false;                // both the unit frame and the command frame received
byte houseCode, unitCode, cmndCode;    // current house, unit, and command code
byte startCode;                        // only needed for testing - sb B1110 (14)

x10 SendX10= x10(ZCROSS_PIN,TRANS_PIN);// set up a x10 library instance:
int countZC=0;
void Check_Rcvr(){    // ISR - called when zero crossing (on CHANGE)
  if (X10BitCnt == 0) {                // looking for new frame
    delayMicroseconds(OFFSET_DELAY);   // wait for bit
    if(digitalRead(RCVE_PIN)) return;  // still high - no start bit - get out
    digitalWrite(LED_PIN, HIGH);       // indicate you got something
    rcveBuff = 0;
    mask = 0x1000;                     // bitmask with bit 12 set
    rcveBuff = rcveBuff | mask;        // sets bit 12 (highest)
    mask = mask >> 1;                  // move bit down in bit mask
    X10BitCnt = 1;                     // inc the bit count
    ZCrossCnt = 1;                     // need to count zero crossings too
    return;
  }
  // Begins here if NOT the first bit . . .
  ZCrossCnt++;                         // inc the zero crossing count
  // after SC (first 4 bits) ignore the pariety bits - so only read odd crossings
  if (X10BitCnt < 5 || (ZCrossCnt & 0x01)){ // if it's an odd # zero crossing
    delayMicroseconds(OFFSET_DELAY);   // wait for bit
    if(!digitalRead(RCVE_PIN)) rcveBuff = rcveBuff | mask;  // got a 1 set the bit, else skip and leave it 0
    mask = mask >> 1;                  // move bit down in bit mask
    X10BitCnt++;

    if(X10BitCnt == 13){               // done with frame after 13 bits
      for (byte i=0;i<5;i++)delayMicroseconds(HALF_CYCLE_DELAY); // need this
      X10rcvd = true;                  // a new frame has been received
      digitalWrite(LED_PIN, LOW);
      X10BitCnt = 0;
      Parse_Frame();                   // parse out the house & unit code and command
    }
  }
//  if(countZC%120==0)
//  {
//    Serial.println("checking "+countZC);
//  }
  countZC++;
}

void Parse_Frame() {   // parses the receive buffer to get House, Unit, and Cmnd
  if(rcveBuff & 0x1){                  // last bit set so it's a command
    cmndCode = rcveBuff & 0x1F;        // mask 5 bits 0 - 4 to get the command
    newX10 = true;                     // now have complete pair of frames
  }
  else {                               // last bit not set so it's a unit
    unitCode = rcveBuff & 0x1F;        // mask 5 bits 0 - 4 to get the unit
    newX10 = false;                    // now wait for the command
    for (byte i=0; i<16; i++){         // use lookup table to get the actual unit #
      if (Unit[i] == unitCode){
        unitCode = i+1;                // this gives Unit 1-16
        break;                         // stop search when found!
      }
    }
  }
  rcveBuff = rcveBuff >> 5;            // shift the house code down to LSB
  houseCode = rcveBuff & 0x0F;         // mask the last 4 bits to get the house code
  for (byte i=0; i<16; i++){           // use lookup table to get the actual command #
    if (House[i] == houseCode){ 
      houseCode = i+65;                // this gives House 'A' - 'P'
      break;                           // stop search when found!
    }
  }
  rcveBuff = rcveBuff >> 4;            // shift the start code down to LSB
  startCode = rcveBuff & 0x0F;         // mask the last 4 bits to get the start code
  X10rcvd = false;                     // reset status
}

void X10_Debug(){
  Serial.print("SC-");
  Serial.print(startCode,BIN);
  Serial.print(" HOUSE-");
  Serial.print(houseCode);
  Serial.print(" UNIT-");
  Serial.print(unitCode,DEC);
  Serial.print(" CMND");
  Serial.print(cmndCode,DEC);
  if(cmndCode == ALL_UNITS_OFF)    Serial.print(" (ALL_UNITS_OFF)");
  if(cmndCode == ALL_LIGHTS_ON)    Serial.print(" (ALL_LIGHTS_ON)");
  if(cmndCode == ON)               Serial.print(" (ON)");
  if(cmndCode == OFF)              Serial.print(" (OFF)");
  if(cmndCode == DIM)              Serial.print(" (DIM)");
  if(cmndCode == BRIGHT)           Serial.print(" (BRIGHT)");
  if(cmndCode == ALL_LIGHTS_OFF)   Serial.print(" (ALL_LIGHTS_OFF)");
  if(cmndCode == EXTENDED_CODE)    Serial.print(" (EXTENDED_CODE)");
  if(cmndCode == HAIL_REQUEST)     Serial.print(" (HAIL_REQUEST)");
  if(cmndCode == HAIL_ACKNOWLEDGE) Serial.print(" (HAIL_ACKNOWLEDGE)");
  if(cmndCode == PRE_SET_DIM)      Serial.print(" (PRE_SET_DIM)");
  if(cmndCode == EXTENDED_DATA)    Serial.print(" (EXTENDED_DATA)");
  if(cmndCode == STATUS_ON)        Serial.print(" (STATUS_ON)");
  if(cmndCode == STATUS_OFF)       Serial.print(" (STATUS_OFF)");
  if(cmndCode == STATUS_REQUEST)   Serial.print(" (STATUS_REQUEST)");
  Serial.println("");
}
long now,now2;
byte state=0,state2=0;
void setup() {
  Serial.begin(9600);
  pinMode(OUT0,OUTPUT);             // onboard LED
  pinMode(OUT1,OUTPUT);             // onboard LED
  pinMode(LED_PIN,OUTPUT);             // onboard LED
  pinMode(RCVE_PIN,INPUT);             // receive X10 commands - low = 1
  pinMode(ZCROSS_PIN,INPUT);           // zero crossing - 60 Hz square wave
  digitalWrite(RCVE_PIN, HIGH);        // set 20K pullup (low active signal)
  digitalWrite(ZCROSS_PIN, HIGH);      // set 20K pullup (low active signal)
  now = millis();
  now2 = millis();
  Serial.println ("All your base are belong to us");
  attachInterrupt(0,Check_Rcvr,CHANGE);// (pin 2) trigger zero cross
}

char inputWord[2];
int parsestate=0;
byte hcSend;
byte ucSend;
byte opCode;
int ctr=0;


void loop(){

  if (newX10){                         // received a new command
    X10_Debug();                       // print out the received command
    newX10 = false;
  }
  Serial.println("Listening...");
  // read a string
  char inData[80];
  int index=0;
  inData[index]=0;
  boolean eol=false;
  while(!eol)
   {
     while(Serial.available()>0) {
	char aChar = Serial.read();
	if(aChar == '\n' || aChar == '\r')
	{
	   // End of record detected. Time to parse
           eol=true;
           break;
	}
	else
	{
	   inData[index] = aChar;
	   index++;
	   inData[index] = '\0'; // Keep the string NULL terminated
           if(index==79) {eol=true; break;}
	}
     }
   }
  
  //parse
   switch(inData[0]) {
       case 'A': hcSend=A; Serial.println("parsed A"); break;
       case 'B': hcSend=B; Serial.println("parsed B"); break;
       case 'C': hcSend=C; Serial.println("parsed C"); break;
       case 'D': hcSend=D; Serial.println("parsed D"); break;
       case 'E': hcSend=E; Serial.println("parsed E"); break;
       case 'F': hcSend=F; Serial.println("parsed F"); break;
       case 'G': hcSend=G; Serial.println("parsed G"); break;
       case 'H': hcSend=H; Serial.println("parsed H"); break;
       case 'I': hcSend=I; Serial.println("parsed I"); break;
       case 'J': hcSend=J; Serial.println("parsed J"); break;
       case 'K': hcSend=K; Serial.println("parsed K"); break;
       case 'L': hcSend=L; Serial.println("parsed L"); break;
       case 'M': hcSend=M; Serial.println("parsed M"); break;
       case 'N': hcSend=N; Serial.println("parsed N"); break;
       case 'O': hcSend=O; Serial.println("parsed O"); break;
       case 'P': hcSend=P; Serial.println("parsed P"); break;
       default:
       Serial.print("Unknown house code: ");
       Serial.println(inData);
       return;
   }
   char codeString[3];
   codeString[0]=inData[1];
   codeString[1]=inData[2];
   codeString[2]=0;
   int unitCode=atoi(codeString);
   codeString[0]=inData[3];
   codeString[1]=inData[4];
   codeString[2]=0;
   if(unitCode<1 || unitCode>16) {
      Serial.print("Illegal unit code: ");
      Serial.println(unitCode);
      Serial.println(inData);
      return;
   }
   byte unSend=Unit[unitCode-1];
   int cmdCode=atoi(codeString);
   if(cmdCode<0 || cmdCode>31) {
      Serial.print("Illegal unit code: ");
      Serial.println(unitCode);
      Serial.println(inData);
      return;
   }
   Serial.print("Parsed unit: ");
   Serial.print(unitCode);
   Serial.print(" ");
   Serial.print(unSend,BIN);
   Serial.print(" command: ");
   Serial.print(cmdCode);
   Serial.print(" ");
   Serial.println(cmdCode,BIN);
   
   detachInterrupt(0);                  // must detach interrupt before sending
   SendX10.write(hcSend,unSend,RPT_SEND);               
   SendX10.write(hcSend,cmdCode,RPT_SEND); 
   attachInterrupt(0,Check_Rcvr,CHANGE);// re-attach interrupt
 

  
} 


