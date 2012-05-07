#include <x10.h>
#include <x10constants.h>

#include <EEPROM.h>
// Write the unit number into the eeprom memory
//
// (c) 2012 strawdog3@gmail.com
//
// License:  An ye harm none, do as ye will
//

void setup() {
  EEPROM.write(0,UNIT_4);
  
}
void loop() {
}
