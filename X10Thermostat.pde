// X10 thermostat control code
// unit code is stored in eeprom memory
//
// X10 receive code is from an example by Brohogan
//
// (c) 2012 strawdog3@gmail.com
//
// License:  An ye harm none, do as ye will
//

#include <EEPROM.h>

#include <x10constants.h>
#include <x10.h>


#include <OneWire.h>

/* Arduino Interface to the PSC05 X10 Receiver.                       BroHogan 3/24/09
 * SETUP: X10 PSC05/TW523 RJ11 to Arduino (timing for 60Hz)
 * - RJ11 pin 1 (BLK) -> Pin 2 (Interrupt 0) = Zero Crossing
 * - RJ11 pin 2 (RED) -> GND
 * - RJ11 pin 3 (GRN) -> Pin 4 = Arduino receive
 * - RJ11 pin 4 (YEL) -> Pin 5 = Arduino transmit (via X10 Lib)
 * NOTES:
 * - Must detach interrup when transmitting with X10 Lib 
 */
// \\\\\\\\\\\\\\\\ TAB NAMED PSC05.H ///////////////////
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
  if(cmndCode == ON)Serial.print(" (ON)");
  if(cmndCode == OFF)Serial.print(" (OFF)");
  Serial.println("");
}
long now,now2;
byte state=0,state2=0;

OneWire ds(10);  // on pin 10

const int timestep=15000;
// temps represented internally
// as signed bytes *2, so +/-64
const byte lowTemp=40; //20
const byte highTemp=44; //22

byte MY_UNIT;
void setup() {
  attachInterrupt(0,Check_Rcvr,CHANGE);// (pin 2) trigger zero cross
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
  Serial.println("Starting");
  MY_UNIT=EEPROM.read(0);
  Serial.print("Unit code read from memory: ");
  Serial.println(MY_UNIT,BIN);
  randomSeed(analogRead(0));
}


byte tempHouseCode=A;
byte tempCode=0;

void loop(){
  int HighByte, LowByte, TReading, SignBit, Tc_100, Whole, Fract;

  byte i;
  byte present = 0;
  byte data[12];
  byte addr[8];

  if (newX10){                         // received a new command
    X10_Debug();                       // print out the received command
    newX10 = false;
  }
  
  // Every timestep
  if (millis() - now > timestep){
      now=millis();
      
  // read the temp
  if ( !ds.search(addr)) {
      Serial.print("No more addresses.\n");
      ds.reset_search();
      return;
  }

  //Serial.print("R=");
  //for( i = 0; i < 8; i++) {
  //  Serial.print(addr[i], HEX);
  //  Serial.print(" ");
 // }

  if ( OneWire::crc8( addr, 7) != addr[7]) {
      Serial.print("CRC is not valid!\n");
      return;
  }

  if ( addr[0] != 0x10) {
      Serial.print("Device is not a DS18S20 family device.\n");
      return;
  }

  ds.reset();
  ds.select(addr);
  ds.write(0x44,1);         // start conversion, with parasite power on at the end

  delay(1000);     // maybe 750ms is enough, maybe not
  // we might do a ds.depower() here, but the reset will take care of it.

  present = ds.reset();
  ds.select(addr);    
  ds.write(0xBE);         // Read Scratchpad

  //Serial.print("P=");
  //Serial.print(present,HEX);
  //Serial.print(" ");
  for ( i = 0; i < 9; i++) {           // we need 9 bytes
    data[i] = ds.read();
  //  Serial.print(data[i], HEX);
  //  Serial.print(" ");
  }
  //Serial.print(" CRC=");
  //Serial.print( OneWire::crc8( data, 8), HEX);
  //Serial.println();
  
  LowByte = data[0];
  HighByte = data[1];
  TReading = (HighByte << 8) + LowByte;
  SignBit = TReading & 0x8000;  // test most sig bit
  if (SignBit) // negative
  {
    TReading = (TReading ^ 0xffff) + 1; // 2's comp
  }
  Tc_100 = (6 * TReading) + TReading / 4;    // multiply by (100 * 0.0625) or 6.25

  Whole = TReading / 2;  // separate off the whole and fractional portions
  Fract = TReading % 2;
  
  // from 12 degrees to 28 degrees in half degree steps - 32 values
  // can only send 4 bits - switch high and low based on house code
  
  tempHouseCode=(TReading-24 & B10000) ? B : A;
  tempCode=((TReading -24) & B1111)*2+1;
  
  byte currentTemp=TReading;// * (SignBit)?-1:1;

  Serial.print("<TEMP> ");
  if (SignBit) // If its negative
  {
     Serial.print("-");
  }
  Serial.print(Whole);
  Serial.print(".");
  if (Fract < 1)
  {
     Serial.print("0");
  }
  else
  {
     Serial.print("5");
  }  
  Serial.print(" ");
  Serial.print(currentTemp,DEC);
  Serial.print(" ");
  Serial.print(currentTemp,BIN);
  Serial.println("");
  
  
      state2++;
    digitalWrite(OUT0,state2&1);
    digitalWrite(OUT1,state2&2);

  // must detach interrupt before sending
      detachInterrupt(0);  
      // transmit the current temperature
     
      Serial.print("I would send ");
      Serial.print(tempHouseCode,BIN);
      Serial.print(" ");
      Serial.print(tempCode,BIN);
      Serial.println("");
      SendX10.write(tempHouseCode,MY_UNIT,RPT_SEND);               
      SendX10.write(tempHouseCode,tempCode,RPT_SEND);  
      delay(1000);
      
  // if too high, send the off message
  if (currentTemp>highTemp)
  {
    Serial.println("I would turn off");
      SendX10.write(E,MY_UNIT,RPT_SEND);               
      SendX10.write(E,OFF,RPT_SEND);  
  }
  else if(currentTemp<lowTemp)
  {
  // if too low, send the on message
    Serial.println("I would turn on");
      SendX10.write(E,MY_UNIT,RPT_SEND);               
      SendX10.write(E,ON,RPT_SEND);  
  }
        attachInterrupt(0,Check_Rcvr,CHANGE);// re-attach interrupt
  delay(random(10000,15000));
}
}


