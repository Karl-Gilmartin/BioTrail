import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:pocketbase/pocketbase.dart';

class RoutePage extends StatefulWidget {
  final String routeId;
  final String routeName;

  const RoutePage({Key? key, required this.routeId, required this.routeName}) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  final pb = PocketBase('https://gilmartin-karl.ie');
  Map<String, dynamic>? routeDetails;
  bool isLoading = true;
  bool isScanning = false;
  String _nfcData = "Scan an NFC tag";
  LatLng? startingLocation;
  List<LatLng> routeCoordinates = [];
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    _fetchRouteDetails();
  }

  Future<void> _fetchRouteDetails() async {
    try {
      print("Fetching route details...");
      final routeRecord = await pb.collection('routes').getOne(widget.routeId);
      routeDetails = routeRecord.data;
      print("Route details fetched successfully");

      final universityRecord = await pb.collection('universities').getOne(routeDetails!['university']);
      final universityLocation = universityRecord.data?['location'];

      setState(() {
        if (universityLocation != null &&
            universityLocation['features'] != null &&
            universityLocation['features'].isNotEmpty) {
          final feature = universityLocation['features'][0];
          final coordinates = feature['geometry']['coordinates'];
          startingLocation = LatLng(coordinates[1], coordinates[0]);
          print("Starting location set: $startingLocation");
        }

        if (routeDetails != null && routeDetails!['location'] != null) {
          final routeLocationData = routeDetails!['location'];
          if (routeLocationData['features'] != null &&
              routeLocationData['features'].isNotEmpty) {
            final feature = routeLocationData['features'][0];

            if (feature['geometry'] != null && feature['geometry']['type'] == 'LineString') {
              final coordinates = feature['geometry']['coordinates'];
              routeCoordinates = coordinates
                  .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                  .toList();
              print("Route coordinates parsed successfully");
            }
          }
        }

        isLoading = false;
      });
    } catch (e) {
      print('Error fetching route/university details: $e');
      setState(() => isLoading = false);
    }
  }

  void _startNfcScan() async {
    print("NFC scan initiated...");
    setState(() => isScanning = true);

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          print("NFC tag discovered: ${tag.data}");
          
          final ndef = Ndef.from(tag);
          if (ndef != null) {
            final message = await ndef.read();
            print("NDEF message read successfully.");
            setState(() {
              _nfcData = message.records
                  .map((record) => String.fromCharCodes(record.payload))
                  .join();
              print("Parsed NFC data: $_nfcData");
              isScanning = false;
            });
          } else {
            print("NDEF not supported by this tag.");
            setState(() {
              _nfcData = "NDEF not supported";
              isScanning = false;
            });
          }
          await NfcManager.instance.stopSession();
          print("NFC scan session stopped.");
        },
      );
    } catch (e) {
      print("NFC scan failed: $e");
      setState(() {
        _nfcData = "NFC scan failed: $e";
        isScanning = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (startingLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(startingLocation!, 14.0),
      );
      print("Map camera moved to starting location.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routeName),
        backgroundColor: const Color.fromRGBO(10, 86, 86, 1),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : routeDetails == null
              ? const Center(
                  child: Text(
                    "Route details not found",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: startingLocation == null
                          ? const Center(child: Text("No map location available"))
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: startingLocation!,
                                zoom: 14.0,
                              ),
                              onMapCreated: _onMapCreated,
                              markers: {
                                Marker(
                                  markerId: MarkerId(widget.routeId),
                                  position: startingLocation!,
                                  infoWindow: InfoWindow(
                                    title: widget.routeName,
                                    snippet: "Starting location",
                                  ),
                                ),
                              },
                              polylines: {
                                if (routeCoordinates.isNotEmpty)
                                  Polyline(
                                    polylineId: const PolylineId('route'),
                                    points: routeCoordinates,
                                    color: Colors.blue,
                                    width: 4,
                                  ),
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            _nfcData,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _actionButton(
                                Icons.nfc,
                                isScanning ? "Scanning..." : "Scan NFC",
                                () {
                                  if (!isScanning) _startNfcScan();
                                },
                              ),
                              _actionButton(
                                Icons.camera_alt,
                                "Record Sighting",
                                () {
                                  print("Record Sighting pressed");
                                  // Add functionality here
                                },
                              ),
                              _actionButton(
                                Icons.report_problem,
                                "Report Issue",
                                () {
                                  print("Report Issue pressed");
                                  // Add functionality here
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color.fromRGBO(10, 86, 86, 1),
          ),
          onPressed: onPressed,
          child: Icon(icon, size: 30, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
