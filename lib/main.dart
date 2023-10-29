import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? selectedDevice;
  String distance = 'No data received';
  List<FlSpot> chartData = [];

  @override
  void initState() {
    super.initState();
  }

  // This is really just to connect to a bluetooth device with name "UltrasonicSensor".
  Future<void> connectToUltrasonicSensor() async {
    await flutterBlue.startScan();
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name == 'UltrasonicSensor') {
          setState(() {
            selectedDevice = result.device;
          });
        }
      }
    });
  }

  Future<void> startListeningToSensor() async {
    if (selectedDevice == null) {
      return;
    }

    await selectedDevice!.connect();
    List<BluetoothService> services = await selectedDevice!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() ==
            '19B10001-E8F2-537E-4F6C-D104768A1214') {
          await characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            setState(() {
              int distanceValue = value[0];
              distance = 'Distance: $distanceValue cm';
              chartData.add(FlSpot(
                  chartData.length.toDouble(), distanceValue.toDouble()));
            });
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ultrasonic Sensor Data'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      distance,
                      style: const TextStyle(fontSize: 20),
                    ),
                    ElevatedButton(
                      onPressed: connectToUltrasonicSensor,
                      child: const Text('Connect to Device'),
                    ),
                    ElevatedButton(
                      onPressed: () => startListeningToSensor(),
                      child: const Text('Start Listening to Sensor'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: LineChart(
                LineChartData(
                    // Chart configuration...
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
