import 'package:device_controller/device_setup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool heatSwitch = false;
  bool vibrationSwitch = false;
  bool tensSwitch = false;

  final flutterReactiveBle = FlutterReactiveBle();
  late DiscoveredDevice targetDevice;

  void toggleHeatSwitch(bool value) {
    setState(() {
      heatSwitch = value;
      print(heatSwitch);
    });
  }

  void toggleVibrationSwitch(bool value) {
    setState(() {
      vibrationSwitch = value;
      print(vibrationSwitch);
    });
  }

  void toggleTensSwitch(bool value) {
    setState(() {
      tensSwitch = value;
      print(tensSwitch);
    });
  }

  @override
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
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5),
              ),
              Container(
                padding: EdgeInsets.all(10),
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(217, 217, 217, 0.6),
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Vibration Therapy",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      value: vibrationSwitch,
                      onChanged: toggleVibrationSwitch,
                      activeColor: Colors.deepPurple,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[300],
                    )
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(10),
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(217, 217, 217, 0.6),
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Heat Therapy",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      value: heatSwitch,
                      onChanged: toggleHeatSwitch,
                      activeColor: Colors.deepPurple,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[300],
                    )
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(10),
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(217, 217, 217, 0.6),
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "TENS Pulse Therapy",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      value: tensSwitch,
                      onChanged: toggleTensSwitch,
                      activeColor: Colors.deepPurple,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[300],
                    )
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetupPage(
                        title: 'DEVICE MODE SETUP',
                        vibrationStatus: vibrationSwitch,
                        heatStatus: heatSwitch,
                        tensStatus: tensSwitch,
                      ),
                    ),
                  );
                },
                child: Text("Set-Up Device"),
              ),
              SizedBox(height: 16),
              // ElevatedButton(
              //   onPressed: scanAndConnect,
              //   child: Text("Connect Device"),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
