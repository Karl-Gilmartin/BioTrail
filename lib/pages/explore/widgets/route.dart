import 'package:bio_trail/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

class RoutePage extends StatefulWidget {
  final String routeId;
  final String routeName;

  const RoutePage({Key? key, required this.routeId, required this.routeName})
      : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  final pb = PocketBase('https://gilmartin-karl.ie');
  Map<String, dynamic>? routeDetails;
  bool isLoading = true;
  LatLng? startingLocation; 
  List<LatLng> routeCoordinates = []; 
  late GoogleMapController mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchRouteDetails();
  }


  void _showSignDetails(RecordModel sign) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(sign.data['name']),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sign.data['description']),
          SizedBox(height: 10),
          Image.network(
            '${pb.baseUrl}/api/files/signs/${sign.id}/${sign.data['image']}',
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
      ],
    ),
  );
}


  Future<void> _fetchRouteDetails() async {
  try {
    print("Fetching route details...");

    // Fetch route details
    final routeRecord = await pb.collection('routes').getOne(widget.routeId);
    if (routeRecord.data == null) {
      throw Exception("Route data not found for ID: ${widget.routeId}");
    }
    routeDetails = routeRecord.data;
    print("Route details fetched successfully.");

    // Fetch university details
    final universityId = routeDetails!['university'];
    if (universityId == null) {
      throw Exception("University ID not found in route data.");
    }

    final universityRecord = await pb.collection('universities').getOne(universityId);
    final universityLocation = universityRecord.data?['location'];

    if (universityLocation != null &&
        universityLocation['features'] != null &&
        universityLocation['features'].isNotEmpty) {
      final feature = universityLocation['features'][0];
      final coordinates = feature['geometry']['coordinates'];

      if (coordinates != null && coordinates.length == 2) {
        startingLocation = LatLng(coordinates[1], coordinates[0]);
        print("Starting location set: $startingLocation");
      } else {
        throw Exception("Invalid university coordinates data.");
      }
    } else {
      print('University location data is missing or invalid');
    }

    // Fetch route coordinates and create polyline
    if (routeDetails != null && routeDetails!['location'] != null) {
      final routeLocationData = routeDetails!['location'];
      if (routeLocationData['features'] != null &&
          routeLocationData['features'].isNotEmpty) {
        final feature = routeLocationData['features'][0];
        if (feature['geometry'] != null && feature['geometry']['type'] == 'LineString') {
          final coordinates = feature['geometry']['coordinates'];

          if (coordinates is List) {
            routeCoordinates = coordinates
                .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                .toList();
            print("Route coordinates added: ${routeCoordinates.length} points");
          } else {
            print("Invalid route coordinates format.");
          }
        } else {
          print("Route geometry type is not 'LineString'.");
        }
      } else {
        print("No route features found.");
      }
    }

    // Fetch sign data related to the route
    print("Fetching signs for routeId: ${widget.routeId}");
    final signRecords = await pb.collection('signs').getList(
      filter: 'route.id="${widget.routeId}"',
    );

    if (signRecords.items.isNotEmpty) {
      for (var sign in signRecords.items) {
        final signLocation = sign.data['location']['geometry']['coordinates'];

        if (signLocation != null && signLocation.length == 2) {
          final signLatLng = LatLng(signLocation[1], signLocation[0]);
          print("Sign location: $signLatLng");

          _markers.add(
            Marker(
              markerId: MarkerId(sign.id),
              position: signLatLng,
              infoWindow: InfoWindow(
                title: sign.data['name'] ?? 'Unknown Sign',
                snippet: "Tap to view details",
                onTap: () {
                  _showSignDetails(sign);
                },
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          );
        } else {
          print("Invalid coordinates for sign ID: ${sign.id}");
        }
      }
    } else {
      print("No signs found for this route.");
    }

    setState(() {
      isLoading = false;
    });
  } catch (e) {
    print('Error fetching route/university details: $e');
    setState(() {
      isLoading = false;
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
      backgroundColor: Colors.white,
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
                          ? const Center(
                              child: Text("No map location available"),
                            )
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: startingLocation!,
                                zoom: 14.0,
                              ),
                              onMapCreated: _onMapCreated,
                              markers: _markers,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _actionButton(
                            Icons.qr_code_scanner,
                            "Scan QR",
                            () {
                              QRScanner.scanQRCode(context);
                            },
                          ),
                          _actionButton(
                            Icons.camera_alt,
                            "Record Sighting",
                            () {
                              // Record sighting functionality
                            },
                          ),
                          _actionButton(
                            Icons.report_problem,
                            "Report Issue",
                            () {
                              // Report issue functionality
                            },
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
