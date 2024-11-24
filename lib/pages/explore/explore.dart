import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  late GoogleMapController _mapController;

  final List<LatLng> _locations = [
    LatLng(52.6773917893225, -8.579997732019471), // Castle
    LatLng(52.6763598648145, -8.583682820192443), // Boat House
    LatLng(52.676566388054376, -8.57377483876544), // Dromroe
  ];

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setMarkers();
    _setPolyline();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location permission denied.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      _markers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: "You are here"),
        ),
      );
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  void _setMarkers() {
    for (int i = 0; i < _locations.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: _locations[i],
          infoWindow: InfoWindow(
            title: 'Location ${i + 1}',
            snippet: 'Lat: ${_locations[i].latitude}, Lng: ${_locations[i].longitude}',
          ),
        ),
      );
    }
  }

  void _setPolyline() {
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: _locations,
        color: Colors.blue,
        width: 5,
      ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _locations[0],
        zoom: 14,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: _currentLocation != null,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) => _mapController = controller,
    );
  }

  void _scanQRCode() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScannerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: _buildGoogleMap(),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Explore Nearby Routes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                    onPressed: _scanQRCode,
                    child: const Text(
                      "Scan QR Code",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code Scanner"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      print("QR Code Scanned: ${scanData.code}");
      // Show a dialog with scanned data
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("QR Code Scanned"),
            content: Text(scanData.code ?? "No Data"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
