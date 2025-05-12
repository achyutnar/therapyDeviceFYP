#include <ArduinoBLE.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_SSD1306.h>
#include <NRF52_MBED_TimerInterrupt.h>


#define VIBRATIONGPIO       2
#define HEATGPIO            3
#define HEATSENSORGPIO      4
#define TENSENABLEGPIO      5
#define TENSINPUT1GPIO      6
#define TENSINPUT2GPIO      7
#define STARTBUTTONGPIO     8
#define RESETBUTTONGPIO     9
#define VIBRATIONBUTTONGPIO 10
#define HEATBUTTONGPIO      11
#define TENSBUTTONGPIO      12

#define DHTTYPE             DHT11
#define SCREEN_WIDTH        128
#define SCREEN_HEIGHT       32
#define OLED_RESET          -1
#define SCREEN_ADDRESS      0x3C

DHT_Unified dht(HEATSENSORGPIO, DHTTYPE);
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
NRF52_MBED_TimerInterrupt interruptTimer(NRF_TIMER_3);

bool vibration = false;
int vibrationMode = 0;
int vibrationIntensity = 0;
int vibrationDuration = 0;
int vibrationTimerStartCount;

bool heat = false;
int heatMode = 0;
int heatTemperature = 0;
int heatDuration = 0;
int currentTemp = 0;
int heatTimerStartCount;

bool tens = false;
int tensMode = 0;
int tensIntensity = 0;
int tensFrequency = 0;
int tensDuration = 0;
int tensBurstCount = 0;
int tensTimerStartCount;

bool deviceRunningStatus = false;
bool bluetoothDataStatus = false;
int deviceStatus = 0;

const int debounceDelay = 200;
unsigned long prevInterruptTime = 0;
int timerInterruptCount = 0;

bool bleConnected = false;
int indexCount = 0;
String deviceData = "";
String decodedConfigData[11];
BLEService customServiceUuid("12345678-1234-5678-1234-56789abcdef0"); 
BLEStringCharacteristic deviceCharacteristic(
            "abcdef01-1234-5678-1234-56789abcdef0", 
            BLEWrite, 
            50
      );
BLEDevice central;

void setup()
{
  Serial.begin(9600);
  dht.begin();
  display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS);
  display.display();
  delay(2000);
  pinMode(VIBRATIONGPIO, OUTPUT);
  pinMode(HEATGPIO, OUTPUT);
  pinMode(HEATSENSORGPIO, INPUT);
  pinMode(TENSENABLEGPIO, OUTPUT);
  pinMode(TENSINPUT1GPIO, OUTPUT);
  pinMode(TENSINPUT2GPIO, OUTPUT);
  pinMode(STARTBUTTONGPIO, INPUT_PULLDOWN);
  pinMode(RESETBUTTONGPIO, INPUT_PULLDOWN);
  pinMode(VIBRATIONBUTTONGPIO, INPUT_PULLDOWN);
  pinMode(HEATBUTTONGPIO, INPUT_PULLDOWN);
  pinMode(TENSBUTTONGPIO, INPUT_PULLDOWN);

  analogWrite(VIBRATIONGPIO, 0);
  digitalWrite(HEATGPIO, LOW);
  analogWrite(TENSENABLEGPIO, 0);

  attachInterrupt(digitalPinToInterrupt(STARTBUTTONGPIO), startTherapy, FALLING);
  attachInterrupt(digitalPinToInterrupt(RESETBUTTONGPIO), resetDevice, FALLING);
  attachInterrupt(digitalPinToInterrupt(VIBRATIONBUTTONGPIO), vibrationModeChange, FALLING);
  attachInterrupt(digitalPinToInterrupt(HEATBUTTONGPIO), heatModeChange, FALLING);
  attachInterrupt(digitalPinToInterrupt(TENSBUTTONGPIO), tensModeChange, FALLING);
  interruptTimer.setInterval(1000000, timerInterruptHandler);

  if (!BLE.begin()) {
    Serial.println("Failed to initialize BLE!");
    while (1);
  }

  BLE.setLocalName("Therapy Device");
  BLE.setAdvertisedService(customServiceUuid);
  customServiceUuid.addCharacteristic(deviceCharacteristic);
  BLE.addService(customServiceUuid);
  BLE.setConnectionInterval(40, 80);
  BLE.advertise();
  Serial.println("BLE device is now advertising as 'therapy device'");
}

void loop()
{
  BLE.poll();
  if (BLE.connected() && !bluetoothDataStatus) 
  {
    Serial.print("Check ");
    getBluetoothData();
  }
  checkTensPulse();
  checkTemperature();
  deviceStatusCheck();
}

void getBluetoothData()
{
  central = BLE.central();
  if (central.connected())
  {
    if (deviceCharacteristic.written())
    {
    Serial.println(" ");
      deviceData = deviceCharacteristic.value();
      Serial.print("Received: ");
      Serial.println(deviceData);
      decodeData();
    }
  }
}

void decodeData()
{
  String receivedData = deviceData;
  int start = 0;
  int index = 0;

  while ((index = receivedData.indexOf('/', start)) != -1) {
    String temp = receivedData.substring(start, index);
    decodedConfigData[indexCount] = temp;
    start = index + 1;
    indexCount++;
  }
  decodedConfigData[indexCount] = receivedData.substring(start);

  if(decodedConfigData[0] == "true")
  {
    vibration = true;
    vibrationMode = -1;
    vibrationDuration = decodedConfigData[1].toInt();
    vibrationDuration = vibrationDuration*3;
    vibrationIntensity = decodedConfigData[2].toInt();
  }
  else
  {
    vibration = false;
  }
  if(decodedConfigData[3] == "true")
  {
    heat = true;
    heatMode = -1;
    heatDuration = decodedConfigData[4].toInt();
    heatDuration = heatDuration*3;
    heatTemperature = decodedConfigData[5].toInt();
  }
  else
  {
    heat = false;
  }
  if(decodedConfigData[6] == "true")
  {
    tens = true;
    tensMode = -1;
    tensDuration = decodedConfigData[7].toInt();
    tensDuration = tensDuration*3;
    Serial.println(tensDuration);
    tensMode = decodedConfigData[8].toInt();
    tensFrequency = decodedConfigData[9].toInt();
    tensIntensity = decodedConfigData[10].toInt();
  }
  else
  {
    tens = false;
  }
  bluetoothDataStatus = true;
}

void startTherapy()
{
  unsigned long buttonPressTime = millis();
  if(buttonPressTime - prevInterruptTime > debounceDelay)
  {
    startVibration();
    startHeat();
    startTens();
    deviceRunningStatus = true;
    prevInterruptTime = buttonPressTime;
  }
}

//Vibration Therapy Functions
void vibrationModeChange()
{
  unsigned long buttonPressTime = millis();
  if(buttonPressTime - prevInterruptTime > debounceDelay)
  {
    vibrationMode++;
    prevInterruptTime = buttonPressTime;
  }
  if(vibrationMode == 4)
  {
    vibrationMode = vibrationMode%4;
  }
  if(vibrationMode != 0)
  {
    vibration = true;
  }
  else
  {
    vibration = false;
  }
}
void startVibration()
{
  if(vibration)
  {
    setupVibration();
    vibrationTimerStartCount = timerInterruptCount;
    vibrationIntensity = map(vibrationIntensity, 0, 100, 100, 255);
    deviceStatus++;
    analogWrite(VIBRATIONGPIO, vibrationIntensity);
  }
}
void setupVibration()
{
  if(vibrationMode == 0)
  {
    return;
  }
  else if(vibrationMode == 1)
  {
    vibrationIntensity = 50;
    vibrationDuration = 15;
  }
  else if(vibrationMode == 2)
  {
    vibrationIntensity = 75;
    vibrationDuration = 10;
  }
  else if(vibrationMode == 3)
  {
    vibrationIntensity = 100;
     vibrationDuration = 10;
  }
}
void stopVibration()
{
  analogWrite(VIBRATIONGPIO, 0);
  deviceStatus--;
  vibration = false;
}

//Heat therapy functions
void heatModeChange()
{
  unsigned long buttonPressTime = millis();
  if(buttonPressTime - prevInterruptTime > debounceDelay)
  {
    heatMode++;
    prevInterruptTime = buttonPressTime;
  }
  if(heatMode == 4)
  {
    heatMode = heatMode%4;
  }
  if(heatMode != 0)
  {
    heat = true;
  }
  else
  {
    heat = false;
  }
}
void startHeat()
{
  if(heat)
  {
    setupHeat();
    heatTimerStartCount = timerInterruptCount;
    deviceStatus++;
    digitalWrite(HEATGPIO, HIGH);
  }
}
void setupHeat()
{
  if(heatMode == 0)
  {
    return;
  }
  else if(heatMode == 1)
  {
    heatTemperature = 35;
    heatDuration = 10;
  }
  else if(heatMode == 2)
  {
    heatTemperature = 40;
    heatDuration = 15;
  }
  else if(heatMode == 3)
  {
    heatTemperature = 45;
    heatDuration = 15;
  }
}
void checkTemperature()
{
  if(heat)
  {
  sensors_event_t event;
    dht.temperature().getEvent(&event);
    if (isnan(event.temperature)) {
      Serial.println(F("Error reading temperature!"));
    }
    else {
      Serial.print(F("Temperature: "));
      Serial.print(event.temperature);
      Serial.println(F("°C"));
    }
  }
}
void stopHeat()
{
  digitalWrite(HEATGPIO, LOW);
  deviceStatus--;
  heat = false;
}

//Tens Therapy Functions
void tensModeChange()
{
  unsigned long buttonPressTime = millis();
  if(buttonPressTime - prevInterruptTime > debounceDelay)
  {
    tensMode++;
    prevInterruptTime = buttonPressTime;
  }
  if(tensMode == 3)
  {
    tensMode = tensMode%3;
  }
  if(tensMode != 0)
  {
    tens = true;
  }
  else
  {
    tens = false;
  }  
}
void startTens()
{
  if(tens)
  {
    setupTens();
    tensTimerStartCount = timerInterruptCount;
    tensIntensity = map(tensIntensity, 0, 100, 100, 255);
    deviceStatus++;
    digitalWrite(TENSENABLEGPIO, HIGH);
  }
}
void setupTens()
{
  if(tensMode == 0)
  {
    return;
  }
  else if(tensMode == 1)
  {
    tensIntensity = 70;
    tensFrequency = 100;
    tensDuration = 45;
  }
  else if(tensMode == 2)
  {
    tensIntensity = 70;
    tensFrequency = 100;
    tensDuration = 60;
  }
}
void checkTensPulse()
{
  if(tens && tensFrequency != 0)
  {
    digitalWrite(TENSINPUT1GPIO, HIGH);
    digitalWrite(TENSINPUT2GPIO, LOW);
    delay(50);
    digitalWrite(TENSINPUT1GPIO, LOW);
    digitalWrite(TENSINPUT2GPIO, LOW);
    delay(2);
    digitalWrite(TENSINPUT1GPIO, LOW);
    digitalWrite(TENSINPUT2GPIO, HIGH);
    delay(50);
    digitalWrite(TENSINPUT1GPIO, LOW);
    digitalWrite(TENSINPUT2GPIO, LOW);
    if(tensMode == 2 || tensMode == -2)
    {
      tensBurstCount++;
      if(tensBurstCount == 5)
      {
        delay(300);
        
      }
    }
  }
}
void stopTens()
{
  analogWrite(TENSENABLEGPIO, 0);
  digitalWrite(TENSINPUT1GPIO, LOW);
  digitalWrite(TENSINPUT2GPIO, LOW);
  deviceStatus--;
  tens = false;
}

void timerInterruptHandler()
{
  if(deviceRunningStatus)
  {
    timerInterruptCount++;
    if(vibration)
    {
      if(timerInterruptCount - vibrationTimerStartCount >= vibrationDuration)
      {
        stopVibration();
      }
    }
    if(heat)
    {
      if(timerInterruptCount - heatTimerStartCount >= heatDuration)
      {
        stopHeat();
      }
    }
    if(tens)
    {
      if(timerInterruptCount - tensTimerStartCount >= tensDuration)
      {
        stopTens();
      }
    }
  }
}

void deviceStatusCheck()
{
  displayDeviceStatus();
  if(deviceRunningStatus)
  {
    if(deviceStatus == 0)
    {
      resetDevice();
    }
  }
}

void displayDeviceStatus()
{
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(WHITE);
  
  if(!vibration && !heat && !tens)
  {
    display.setCursor(0, 0);
    display.print("Therapy Device");
    display.setCursor(0, 10);
    display.print("Select Therapy");
  }
  if(BLE.connected())
  {
    display.setCursor(95, 0);
    display.print("Con");
  }
  else
  {
    display.setCursor(90, 0);
    display.print("Dis");
  }
  if(vibration)
  {
    display.setCursor(0, 10);
    display.print("Vib");
    display.setCursor(0, 20);
    display.print("Mode: ");
    display.setCursor(25, 20);
    if(vibrationMode == -1)
    {
      display.print("B");
    }
    else
    {
      display.print(vibrationMode);
    }
  }
  if(heat)
  {
    display.setCursor(40, 10);
    display.print("Heat");
    display.setCursor(40, 20);
    display.print("Mode: ");
    display.setCursor(65, 20);
    if(heatMode == -1)
    {
      display.print("B");
    }
    else
    {
      display.print(heatMode);
    }
  } 
  if(tens)
  {
    display.setCursor(80, 10);
    display.print("TENS");
    display.setCursor(80, 20);
    display.print("Mode: ");
    display.setCursor(105, 20);
    if(tensMode < 0)
    {
      display.print("B");
    }
    else
    {
      display.print(tensMode);
    }
  }
  display.display();
}

void resetDevice()
{
  stopVibration();
  stopHeat();
  stopTens();
  deviceRunningStatus = false;
  bluetoothDataStatus = false;
  deviceStatus = 0;
  vibration = false;
  vibrationMode = 0;
  vibrationIntensity = 0;
  vibrationDuration = 0;
  vibrationTimerStartCount = 0;
  heat = false;
  heatMode = 0;
  heatTemperature = 0;
  heatDuration = 0;
  currentTemp = 0;
  heatTimerStartCount = 0;
  tens = false;
  tensMode = 0;
  tensIntensity = 0;
  tensFrequency = 0;
  tensDuration = 0;
  tensBurstCount = 0;
  tensTimerStartCount = 0;
}