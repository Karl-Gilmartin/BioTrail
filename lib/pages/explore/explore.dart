import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:bio_trail/pages/explore/widgets/university.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final pb = PocketBase('https://gilmartin-karl.ie');
  List<Map<String, dynamic>> universities = [];
  bool isLoading = true;
  String? selectedUniversityId;

  @override
  void initState() {
    super.initState();
    _fetchUniversities();
  }

  // Fetch universities from PocketBase
  Future<void> _fetchUniversities() async {
    try {
      final records = await pb.collection('universities').getFullList();
      setState(() {
        universities = records.map((record) {
          final imageUrl =
              '${pb.baseUrl}/api/files/universities/${record.id}/${record.data['image']}';
          return {
            'id': record.id,
            'name': record.data['name'],
            'imageUrl': imageUrl,
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching universities: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onUniversitySelected(String universityId) {
    setState(() {
      selectedUniversityId =
          selectedUniversityId == universityId ? null : universityId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Explore your campus!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(10, 86, 86, 1),
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Please select your university and trail",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : universities.isEmpty
                        ? Center(child: Text("No universities found"))
                        : ListView.builder(
                            itemCount: universities.length,
                            itemBuilder: (context, index) {
                              final university = universities[index];
                              return UniversityWidget(
                                universityName: university['name'],
                                imageUrl: university['imageUrl'],
                                universityId: university['id'],
                                isExpanded:
                                    selectedUniversityId == university['id'],
                                onTap: () =>
                                    _onUniversitySelected(university['id']),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
