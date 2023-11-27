// Chart for data
// Bluetooth connection
// figure out how to use bluetooth from the following two sources:
// 1. Example for listing available devices: https://github.com/hendrixgg/Flutter-Basics/tree/main/bluetooth (my previous work)
// 2. Example for maintaining a conneciton to a device: https://github.com/sonnny/picow_ble_nordic_spp/blob/main/flutter/blecontroller.dart
// 3. Ask for permissions using: https://pub.dev/packages/permission_handler

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Monolith'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _ble = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connectSub;
  late StreamController<int> _updatesController;
  late List<DiscoveredDevice> _devices;
  String _connectedDeviceId = '';
  String _connectedDeviceName = '';

  @override
  void initState() {
    super.initState();
    _updatesController = StreamController<int>.broadcast();
    _devices = [];
    _scanDevices();
  }

  @override
  void dispose() {
    _scanSub.cancel();
    _connectSub?.cancel();
    _updatesController.close();
    _disconnect();
    super.dispose();
  }

  void _disconnect() {
    if (_connectedDeviceId.isNotEmpty) {
      _connectSub?.cancel();
      _connectedDeviceId = '';
      _connectedDeviceName = '';
    }
  }

  void _scanDevices() {
    _scanSub = _ble.scanForDevices(withServices: []).listen(_onScanUpdate);
  }

  Future<void> _onRefresh() async {
    _disconnect();
    _scanSub.cancel(); // Cancel the ongoing scan
    _devices.clear();
    await Future.delayed(Duration(seconds: 1)); // Simulate a delay
    _scanDevices(); // Start scanning again
  }

  void _onScanUpdate(DiscoveredDevice device) {
    if (device.name.isNotEmpty &&
        !_devices.any((d) => d.name == device.name && d.id == device.id)) {
      setState(() {
        _devices.add(device);
      });
    }
  }

  void _onDeviceSelected(String deviceId) {
    _disconnect();
    _connectSub = _ble.connectToDevice(id: deviceId).listen((update) {
      if (update.connectionState == DeviceConnectionState.connected) {
        _connectedDeviceId = deviceId;
        _connectedDeviceName =
            _devices.firstWhere((d) => d.id == deviceId).name;
        _onConnected(deviceId);
      }
    });
  }

  void _onConnected(String deviceId) {
    _ble.discoverServices(deviceId).then((services) {
      services.forEach((service) {
        service.characteristics.forEach((characteristic) {
          _ble
              .subscribeToCharacteristic(QualifiedCharacteristic(
            deviceId: deviceId,
            serviceId: service.serviceId,
            characteristicId: characteristic.characteristicId,
          ))
              .listen((bytes) {
            try {
              if (bytes.length >= 2) {
                ByteData byteData =
                    ByteData.sublistView(Uint8List.fromList(bytes));
                int receivedValue = byteData.getInt16(0, Endian.little);
                _updatesController.add(receivedValue);
              } else {
                print("Error: Insufficient bytes to read a 16-bit integer");
              }
            } catch (e) {
              print("Error: $e");
            }
          });
        });
      });
    });

    if (!_isServiceUpdatesPageOpen()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ServiceUpdatesPage(
            updatesStream: _updatesController.stream,
            onDispose: () {
              _disconnect();
            },
            connectedDeviceName: _connectedDeviceName,
          ),
        ),
      );
    }
  }

  bool _isServiceUpdatesPageOpen() {
    return Navigator.of(context).canPop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("${widget.title} - Connect a Device"),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Center(
          child: _devices.isEmpty
              ? CircularProgressIndicator()
              : ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return ListTile(
                      title: Text(device.name),
                      subtitle: Text(device.id),
                      onTap: () => _onDeviceSelected(device.id),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class ServiceUpdatesPage extends StatefulWidget {
  final Stream<int> updatesStream;
  final VoidCallback onDispose;
  final String connectedDeviceName;

  const ServiceUpdatesPage({
    Key? key,
    required this.updatesStream,
    required this.onDispose,
    required this.connectedDeviceName,
  }) : super(key: key);

  @override
  _ServiceUpdatesPageState createState() => _ServiceUpdatesPageState();
}

class _ServiceUpdatesPageState extends State<ServiceUpdatesPage> {
  late int _value;
  late StreamSubscription<int> _updatesSubscription;

  @override
  void initState() {
    super.initState();
    _value = 0;
    _updatesSubscription = widget.updatesStream.listen((value) {
      if (mounted) {
        setState(() {
          _value = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _updatesSubscription.cancel();
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.connectedDeviceName),
      ),
      body: Center(
        child: Text(
          'CO level: $_value',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
