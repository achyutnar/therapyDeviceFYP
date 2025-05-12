import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:numberpicker/numberpicker.dart';

class SetupPage extends StatefulWidget {
  const SetupPage(
      {super.key,
      required this.title,
      required this.vibrationStatus,
      required this.heatStatus,
      required this.tensStatus});
  final String title;
  final bool vibrationStatus;
  final bool heatStatus;
  final bool tensStatus;

  @override
  State<SetupPage> createState() => _SetupPage();
}

class _SetupPage extends State<SetupPage> {
  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();

  final Uuid serviceUuid = Uuid.parse(
      "12345678-1234-5678-1234-56789abcdef0"); // Replace with actual service UUID
  final Uuid characteristicUuid = Uuid.parse(
      "abcdef01-1234-5678-1234-56789abcdef0"); // Replace with actual characteristic UUID
  String deviceId =
      "C6:47:CC:69:B1:E1"; // Replace with the connected device's ID
  late QualifiedCharacteristic characteristic;
  int vibration = 0;
  int heat = 0;
  int tens = 0;

  int _currentVibrationIntensityValue = 50;
  int _currentVibrationDurationValue = 15;
  int _currentTemperatureValue = 40;
  int _currentHeatDurationValue = 15;
  int _currentTensDurationValue = 15;
  int _currentTensMode = -1;
  int _currentTensFrequency = 100;
  int _currentTensDIntensityValue = 50;

  String data = "";

  @override
  void initState() {
    super.initState();
    characteristic = QualifiedCharacteristic(
      characteristicId: characteristicUuid,
      serviceId: serviceUuid,
      deviceId: deviceId,
    );
  }

  void makeString() {
    data = "";
    if (widget.vibrationStatus) {
      data = "true";
      data = "$data/$_currentVibrationDurationValue";
      data = "$data/$_currentVibrationIntensityValue";
    } else {
      data = "false/0/0";
    }

    if (widget.heatStatus) {
      data = "$data/true";
      data = "$data/$_currentHeatDurationValue";
      data = "$data/$_currentTemperatureValue";
    } else {
      data = "$data/false/0/0";
    }

    if (widget.tensStatus) {
      data = "$data/true";
      data = "$data/$_currentTensDurationValue";
      data = "$data/$_currentTensMode";
      data = "$data/$_currentTensFrequency";
      data = "$data/$_currentTensDIntensityValue";
    } else {
      data = "$data/false/0/0/0/0";
    }

    sendData(data);
    print(data);
  }

  Future<void> sendData(String data) async {
    final bytes = data.codeUnits;
    final chunkSize = 50; // Max BLE packet size
    for (int i = 0; i < bytes.length; i += chunkSize) {
      final chunk = bytes.sublist(i, (i + chunkSize).clamp(0, bytes.length));
      await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
          value: chunk);
      await Future.delayed(
          Duration(milliseconds: 50)); // Short delay between chunks
    }
    print("Sent: $data");
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  if (widget.vibrationStatus)
                    Container(
                      padding: EdgeInsets.all(8),
                      height: 225,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color.fromRGBO(217, 217, 217, 0.6),
                      ),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.deepPurple[100],
                            ),
                            child: Text(
                              'VIBRATION THERAPY',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Duration of therapy:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          NumberPicker(
                            value: _currentVibrationDurationValue,
                            axis: Axis.horizontal,
                            minValue: 5,
                            maxValue: 30,
                            step: 5,
                            haptics: true,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black26),
                            ),
                            onChanged: (value) => setState(
                                () => _currentVibrationDurationValue = value),
                          ),
                          // SizedBox(height: 16),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Intensity of vibration:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          NumberPicker(
                            value: _currentVibrationIntensityValue,
                            axis: Axis.horizontal,
                            minValue: 0,
                            maxValue: 100,
                            haptics: true,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black26),
                            ),
                            onChanged: (value) => setState(
                                () => _currentVibrationIntensityValue = value),
                          ),
                        ],
                      ),
                    ),
                  if (widget.vibrationStatus) SizedBox(height: 8),
                  if (widget.heatStatus)
                    Container(
                      padding: EdgeInsets.all(8),
                      height: 225,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color.fromRGBO(217, 217, 217, 0.6),
                      ),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.deepPurple[100],
                            ),
                            child: Text(
                              'HEAT THERAPY',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Duration of therapy:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          NumberPicker(
                            value: _currentHeatDurationValue,
                            axis: Axis.horizontal,
                            minValue: 5,
                            maxValue: 30,
                            step: 5,
                            haptics: true,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black26),
                            ),
                            onChanged: (value) => setState(
                                () => _currentHeatDurationValue = value),
                          ),
                          // SizedBox(height: 16),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Temperature:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          NumberPicker(
                            value: _currentTemperatureValue,
                            axis: Axis.horizontal,
                            minValue: 30,
                            maxValue: 50,
                            haptics: true,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black26),
                            ),
                            onChanged: (value) => setState(
                                () => _currentTemperatureValue = value),
                          ),
                        ],
                      ),
                    ),
                  if (widget.heatStatus) SizedBox(height: 8),
                  if (widget.tensStatus)
                    Container(
                      padding: EdgeInsets.all(8),
                      height: 450,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color.fromRGBO(217, 217, 217, 0.6),
                      ),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.deepPurple[100],
                            ),
                            child: Text(
                              'TENS THERAPY',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Duration of therapy:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          NumberPicker(
                            value: _currentTensDurationValue,
                            axis: Axis.horizontal,
                            minValue: 5,
                            maxValue: 30,
                            step: 5,
                            haptics: true,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black26),
                            ),
                            onChanged: (value) => setState(
                                () => _currentTensDurationValue = value),
                          ),
                          // SizedBox(height: 16),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Operation Mode:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _currentTensMode,
                                style: TextStyle(
                                  // Match font style
                                  fontSize: 22,
                                  color: Colors.black54,
                                ),
                                items: [
                                  DropdownMenuItem(
                                      value: -1, child: Text("Normal Mode")),
                                  DropdownMenuItem(
                                      value: -2, child: Text("Busrt Mode")),
                                ],
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _currentTensMode = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Intensity of therapy:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          NumberPicker(
                            value: _currentTensDIntensityValue,
                            axis: Axis.horizontal,
                            minValue: 50,
                            maxValue: 100,
                            step: 5,
                            haptics: true,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black26),
                            ),
                            onChanged: (value) => setState(
                                () => _currentTensDIntensityValue = value),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Frequency of therapy:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          NumberPicker(
                            value: _currentTensFrequency,
                            axis: Axis.horizontal,
                            minValue: 80,
                            maxValue: 130,
                            step: 5,
                            haptics: true,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black26),
                            ),
                            onChanged: (value) =>
                                setState(() => _currentTensFrequency = value),
                          ),
                        ],
                      ),
                    ),
                  if (widget.tensStatus) SizedBox(height: 8),
                ],
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => makeString(),
                child: Text(
                  "START DEVICE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
