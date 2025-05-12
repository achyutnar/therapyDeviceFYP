import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key, required String title});

  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();

  final Uuid serviceUuid = Uuid.parse(
      "12345678-1234-5678-1234-56789abcdef0"); // Replace with actual service UUID
  final Uuid characteristicUuid = Uuid.parse(
      "abcdef01-1234-5678-1234-56789abcdef0"); // Replace with actual characteristic UUID
  String deviceId =
      "C6:47:CC:69:B1:E1"; // Replace with the connected device's ID
  late QualifiedCharacteristic characteristic;

  @override
  void initState() {
    super.initState();
    characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: characteristicUuid,
      deviceId: deviceId,
    );
  }

  void _sendNumber(int number) async {
    try {
      final bytes = [number]; // Convert number to byte array
      await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
          value: bytes);
      print("Sent: $number");
    } catch (e) {
      print("Error sending number: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Send Number via BLE")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _sendNumber(42), // Send 42 as an example
              child: Text("Send Number 42"),
            ),
          ],
        ),
      ),
    );
  }
}
