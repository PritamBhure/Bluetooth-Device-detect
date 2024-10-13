import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';  // Import permission_handler

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BluetoothScannerPage(),
    );
  }
}



class BluetoothScannerPage extends StatefulWidget {
  const BluetoothScannerPage({Key? key}) : super(key: key);

  @override
  _BluetoothScannerPageState createState() => _BluetoothScannerPageState();
}

class _BluetoothScannerPageState extends State<BluetoothScannerPage> {
 // This line is now used to keep an instance
  List<BluetoothDevice> scannedDevices = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();  // Request permissions on initialization
  }

  // Request Bluetooth and Location permissions
  void requestPermissions() async {
    if (await Permission.bluetooth.isDenied) {
      await Permission.bluetooth.request();
    }
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
    startScan(); // Start scanning after requesting permissions
  }

  void startScan() async {
    setState(() {
      isScanning = true;
    });

    // Start scanning
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    // Listen for scan results
    FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
      for (ScanResult scanResult in results) {
        if (!scannedDevices.any((device) => device.id == scanResult.device.id)) {
          setState(() {
            scannedDevices.add(scanResult.device);
          });
        }
      }
    });

    // Stop scan after the timeout
    Future.delayed(const Duration(seconds: 10), () {
      stopScan();
    });
  }

  void stopScan() {
    setState(() {
      isScanning = false;
    });
    FlutterBluePlus.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Scanner'),
        actions: [
          IconButton(
            icon: Icon(isScanning ? Icons.stop : Icons.refresh),
            onPressed: () {
              if (isScanning) {
                stopScan();
              } else {
                scannedDevices.clear();
                startScan();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          isScanning
              ? const LinearProgressIndicator()
              : const SizedBox.shrink(),
          Expanded(
            child: ListView.builder(
              itemCount: scannedDevices.length,
              itemBuilder: (context, index) {
                BluetoothDevice device = scannedDevices[index];
                return ListTile(
                  title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
                  subtitle: Text(device.id.toString()),
                  onTap: () async {
                    // Handle device tap: connect, show services, etc.
                    try {
                      await device.connect();
                    } catch (e) {
                      print('Error connecting: $e');
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
