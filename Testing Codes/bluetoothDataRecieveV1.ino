#include <ArduinoBLE.h>

BLEService therapyDeviceService("fff0");
BLECharacteristic therapyDeviceCharacteristics("fff1", BLERead | BLEBroadcast, 40);
BLEDevice central;

const uint8_t manufactData[4] = {0x01, 0x02, 0x03, 0x04};
const uint8_t serviceData[3] = {0x00, 0x01, 0x02};

String deviceData = "";

void setup() 
{
  Serial.begin(9600);
  while (!Serial);
  bluetoothInit();
}

void loop() 
{
  BLE.poll();
  getDataFromApp();
}

void bluetoothInit()
{
  if (!BLE.begin()) 
  {
    Serial.println("failed to initialize BLE!");
    while (1);
  }
  therapyDeviceService.addCharacteristic(therapyDeviceCharacteristics);
  BLE.addService(therapyDeviceService);

  BLEAdvertisingData scanData;
  scanData.setLocalName("Therapy Device");
  BLE.setScanResponseData(scanData);

  BLEAdvertisingData advData;
  advData.setManufacturerData(0x004C, manufactData, sizeof(manufactData));
  advData.setAdvertisedService(therapyDeviceService);
  advData.setAdvertisedServiceData(0xfff0, serviceData, sizeof(serviceData));
  BLE.setAdvertisingData(advData);

  BLE.advertise();
  Serial.println("advertising ...");
}

void getDataFromApp()
{
  central = BLE.central();
  if (central.connected())
  {
    Serial.println("Connected");
    if (therapyDeviceCharacteristics.written())
    {
      deviceData = String((char*)therapyDeviceCharacteristics.value());
      Serial.print("Received: ");
      Serial.println(deviceData);
    }
  }
}