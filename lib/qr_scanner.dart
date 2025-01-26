import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanner {
  static Future<void> scanQRCode(BuildContext context) async {
    try {
      print('Opening QR scanner...');
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerScreen(),
        ),
      );

      if (result != null && result.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("QR Code Scanned: $result")),
        );
      }
    } catch (e) {
      print('QR Scan Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error scanning QR code: ${e.toString()}")),
      );
    }
  }
}

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final TextEditingController _manualInputController = TextEditingController();
  String? _scanResult;

  void _handleQRScan(String value) {
    if (!mounted) return; // Ensure widget is mounted before setting state

    setState(() {
      _scanResult = value;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context, value);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Green banner for title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.all(20.0),
                    color: Color.fromRGBO(10, 86, 86, 1), // Dark green background
                    child: Text(
                      'Scan QR !!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // QR Scanner Preview (Square Size)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1, // Ensures the scanner is square
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: MobileScanner(
                            controller: _controller,
                            onDetect: (capture) {
                              if (capture.barcodes.isNotEmpty) {
                                _handleQRScan(capture.barcodes.first.rawValue ?? "Unknown");
                              }
                            },
          
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Manual input field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _manualInputController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Enter Code Manually",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.input),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons for actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_manualInputController.text.trim().isNotEmpty) {
                          _handleQRScan(_manualInputController.text.trim());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please enter a valid code.")),
                          );
                        }
                      },
                      icon: Icon(Icons.check),
                      label: Text("Submit"),
                    ),
                  ],
                ),

                if (_scanResult != null) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Scanned Result: $_scanResult",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
