#define VIBRATIONMOTORCONTROLLER 2

void setup()
{
  Serial.begin(9600);
  pinMode(VIBRATIONMOTORCONTROLLER, OUTPUT);
}

void loop()

{
  Serial.println("Low Intensity");
  analogWrite(VIBRATIONMOTORCONTROLLER, 100);
  delay(5000);

  Serial.println();
  Serial.println("Medium Intensity");
  analogWrite(VIBRATIONMOTORCONTROLLER, 175);
  delay(5000);

  Serial.println();
  Serial.println("High Intensity");
  analogWrite(VIBRATIONMOTORCONTROLLER, 255);
  delay(5000);
}