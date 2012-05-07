#include <x10.h>
#include <x10constants.h>
// Prints all the X10 codes, (in binary too)
//
// (c) 2012 strawdog3@gmail.com
//
// License:  An ye harm none, do as ye will
//

void setup() {
Serial.begin(9600);
Serial.println("\n\nHouse Codes:");
Serial.print(" A: ");Serial.print(A,DEC);Serial.print(" B");Serial.println(A,BIN);
Serial.print(" B: ");Serial.print(B,DEC);Serial.print(" B");Serial.println(B,BIN);
Serial.print(" C: ");Serial.print(C,DEC);Serial.print(" B");Serial.println(C,BIN);
Serial.print(" D: ");Serial.print(D,DEC);Serial.print(" B");Serial.println(D,BIN);
Serial.print(" E: ");Serial.print(E,DEC);Serial.print(" B");Serial.println(E,BIN);
Serial.print(" F: ");Serial.print(F,DEC);Serial.print(" B");Serial.println(F,BIN);
Serial.print(" G: ");Serial.print(G,DEC);Serial.print(" B");Serial.println(G,BIN);
Serial.print(" H: ");Serial.print(H,DEC);Serial.print(" B");Serial.println(H,BIN);
Serial.print(" I: ");Serial.print(I,DEC);Serial.print(" B");Serial.println(I,BIN);
Serial.print(" J: ");Serial.print(J,DEC);Serial.print(" B");Serial.println(J,BIN);
Serial.print(" K: ");Serial.print(K,DEC);Serial.print(" B");Serial.println(K,BIN);
Serial.print(" L: ");Serial.print(L,DEC);Serial.print(" B");Serial.println(L,BIN);
Serial.print(" M: ");Serial.print(M,DEC);Serial.print(" B");Serial.println(M,BIN);
Serial.print(" N: ");Serial.print(N,DEC);Serial.print(" B");Serial.println(N,BIN);
Serial.print(" O: ");Serial.print(O,DEC);Serial.print(" B");Serial.println(O,BIN);
Serial.print(" P: ");Serial.print(P,DEC);Serial.print(" B");Serial.println(P,BIN);
Serial.println("\n\nUnit Codes:");
Serial.print(" 01: ");Serial.print(UNIT_1,DEC);Serial.print(" B");Serial.println(UNIT_1,BIN);
Serial.print(" 02: ");Serial.print(UNIT_2,DEC);Serial.print(" B");Serial.println(UNIT_2,BIN);
Serial.print(" 03: ");Serial.print(UNIT_3,DEC);Serial.print(" B");Serial.println(UNIT_3,BIN);
Serial.print(" 04: ");Serial.print(UNIT_4,DEC);Serial.print(" B");Serial.println(UNIT_4,BIN);
Serial.print(" 05: ");Serial.print(UNIT_5,DEC);Serial.print(" B");Serial.println(UNIT_5,BIN);
Serial.print(" 06: ");Serial.print(UNIT_6,DEC);Serial.print(" B");Serial.println(UNIT_6,BIN);
Serial.print(" 07: ");Serial.print(UNIT_7,DEC);Serial.print(" B");Serial.println(UNIT_7,BIN);
Serial.print(" 08: ");Serial.print(UNIT_8,DEC);Serial.print(" B");Serial.println(UNIT_8,BIN);
Serial.print(" 09: ");Serial.print(UNIT_9,DEC);Serial.print(" B");Serial.println(UNIT_9,BIN);
Serial.print(" 10: ");Serial.print(UNIT_10,DEC);Serial.print(" B");Serial.println(UNIT_10,BIN);
Serial.print(" 11: ");Serial.print(UNIT_11,DEC);Serial.print(" B");Serial.println(UNIT_11,BIN);
Serial.print(" 12: ");Serial.print(UNIT_12,DEC);Serial.print(" B");Serial.println(UNIT_12,BIN);
Serial.print(" 13: ");Serial.print(UNIT_13,DEC);Serial.print(" B");Serial.println(UNIT_13,BIN);
Serial.print(" 14: ");Serial.print(UNIT_14,DEC);Serial.print(" B");Serial.println(UNIT_14,BIN);
Serial.print(" 15: ");Serial.print(UNIT_15,DEC);Serial.print(" B");Serial.println(UNIT_15,BIN);
Serial.print(" 16: ");Serial.print(UNIT_16,DEC);Serial.print(" B");Serial.println(UNIT_16,BIN);
Serial.println("\n\nCommand Codes:");
Serial.print(" ALL_UNITS_OFF   : ");Serial.print(ALL_UNITS_OFF   ,DEC);Serial.print(" B");Serial.println(ALL_UNITS_OFF   ,BIN);
Serial.print(" ALL_LIGHTS_ON   : ");Serial.print(ALL_LIGHTS_ON   ,DEC);Serial.print(" B");Serial.println(ALL_LIGHTS_ON   ,BIN);
Serial.print(" ON              : ");Serial.print(ON              ,DEC);Serial.print(" B");Serial.println(ON              ,BIN);
Serial.print(" OFF             : ");Serial.print(OFF             ,DEC);Serial.print(" B");Serial.println(OFF             ,BIN);
Serial.print(" DIM             : ");Serial.print(DIM             ,DEC);Serial.print(" B");Serial.println(DIM             ,BIN);
Serial.print(" BRIGHT          : ");Serial.print(BRIGHT          ,DEC);Serial.print(" B");Serial.println(BRIGHT          ,BIN);
Serial.print(" ALL_LIGHTS_OFF  : ");Serial.print(ALL_LIGHTS_OFF  ,DEC);Serial.print(" B");Serial.println(ALL_LIGHTS_OFF  ,BIN);
Serial.print(" EXTENDED_CODE   : ");Serial.print(EXTENDED_CODE   ,DEC);Serial.print(" B");Serial.println(EXTENDED_CODE   ,BIN);
Serial.print(" HAIL_REQUEST    : ");Serial.print(HAIL_REQUEST    ,DEC);Serial.print(" B");Serial.println(HAIL_REQUEST    ,BIN);
Serial.print(" HAIL_ACKNOWLEDGE: ");Serial.print(HAIL_ACKNOWLEDGE,DEC);Serial.print(" B");Serial.println(HAIL_ACKNOWLEDGE,BIN);
Serial.print(" PRE_SET_DIM     : ");Serial.print(PRE_SET_DIM     ,DEC);Serial.print(" B");Serial.println(PRE_SET_DIM     ,BIN);
Serial.print(" EXTENDED_DATA   : ");Serial.print(EXTENDED_DATA   ,DEC);Serial.print(" B");Serial.println(EXTENDED_DATA   ,BIN);
Serial.print(" STATUS_ON       : ");Serial.print(STATUS_ON       ,DEC);Serial.print(" B");Serial.println(STATUS_ON       ,BIN);
Serial.print(" STATUS_OFF      : ");Serial.print(STATUS_OFF      ,DEC);Serial.print(" B");Serial.println(STATUS_OFF      ,BIN);
Serial.print(" STATUS_REQUEST  : ");Serial.print(31      ,DEC);Serial.print(" B");Serial.println(31      ,BIN);
}

void loop() {}

