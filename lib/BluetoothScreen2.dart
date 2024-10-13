import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';

class Bluetooth_Screen extends StatefulWidget {
  const Bluetooth_Screen({super.key});

  @override
  State<Bluetooth_Screen> createState() => _Bluetooth_ScreenState();
}

class _Bluetooth_ScreenState extends State<Bluetooth_Screen> {

  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  List<BluetoothDevice> _devices = [];
  String _devicesMsg = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => {initScan()});
  }


  Future<void> initScan() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 2));

    if (!mounted) return;
    bluetoothPrint.scanResults.listen(
          (val) {
        if (!mounted) return;
        setState(() => {_devices = val});
        if (_devices.isEmpty)
          setState(() {
            _devicesMsg = "No Devices";
          });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Devices'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(onPressed: (){
            initScan();
          }, icon: Icon(Icons.refresh))
        ],
      ),
      body: _devices.isEmpty
          ? Center(
        child: Text(_devicesMsg ?? ''),
      )
          : ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (c, i) {
          return ListTile(
            leading: Icon(Icons.bluetooth),
            title: Text(_devices[i].name!),
            subtitle: Text(_devices[i].address!),
            onTap: () {},
          );
        },
      ),

    );
  }
}