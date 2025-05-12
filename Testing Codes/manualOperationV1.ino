#include <ArduinoBLE.h>

#define RESETBUTTON 8
#define TENSMODEBUTTON 9
#define THERMOMODEBUTTON 10
#define VIBRATIONMODEBUTTON 11
#define STARTBUTTON 12

int vibrationMode = 0;
int thermoMode = 0;
int tensMode = 0;

//flag variables
bool therapyStartFlag = false;

unsigned long lastInterruptTime = 0;
const unsigned long debounceDelay = 100;

void startTherapy()
{
  therapyStartFlag = true;
}

void vibrationTherapyModeSet() 
{
  if(!debounceCheck)
  {
    return;
  }
  if(vibrationMode == 3)
  {
    vibrationMode = 0;
  }
  vibrationMode++;
}

void thermoTherapyModeSet() 
{
  if(!debounceCheck)
  {
    return;
  }
  if(thermoMode == 3)
  {
    thermoMode = 0;
  }
  thermoMode++;
}

void tensTherapyModeSet() 
{
  if(!debounceCheck)
  {
    return;
  }
  if(tensMode == 3)
  {
    tensMode = 0;
  }
  tensMode++;
}

void resetDevice()
{
  //reset all flags and variables
  vibrationMode = 0;
  thermoMode = 0;
  tensMode = 0;
  therapyStartFlag = false;
  
}

bool debounceCheck() 
{
  Serial.println("Check");
  unsigned long currentTime = millis();
  if (currentTime - lastInterruptTime > debounceDelay) {
    lastInterruptTime = currentTime;
    return true;
  }
  return false;
}

void setup() 
{
    Serial.begin(115200);

    //Pin mode declaration
    pinMode(STARTBUTTON, INPUT_PULLDOWN);
    pinMode(VIBRATIONMODEBUTTON, INPUT_PULLDOWN);
    pinMode(THERMOMODEBUTTON, INPUT_PULLDOWN);
    pinMode(TENSMODEBUTTON, INPUT_PULLDOWN);
    pinMode(RESETBUTTON, INPUT_PULLDOWN);

    //Interrupt Declaration
    attachInterrupt(digitalPinToInterrupt(STARTBUTTON), startTherapy, FALLING);
    attachInterrupt(digitalPinToInterrupt(VIBRATIONMODEBUTTON), vibrationTherapyModeSet, FALLING);
    attachInterrupt(digitalPinToInterrupt(THERMOMODEBUTTON), thermoTherapyModeSet, FALLING);
    attachInterrupt(digitalPinToInterrupt(TENSMODEBUTTON), tensTherapyModeSet, FALLING);
    attachInterrupt(digitalPinToInterrupt(RESETBUTTON), resetDevice, FALLING);
}

void loop() 
{
  Serial.print("Vibration : ");
  Serial.println(vibrationMode);
  Serial.print("Heat : ");
  Serial.println(thermoMode);
  Serial.print("TENS : ");
  Serial.println(tensMode);
  Serial.print("Status : ");
  Serial.println(therapyStartFlag);

  while(therapyStartFlag)
  {
    Serial.println("Success");
  }  
  delay(1000);
}