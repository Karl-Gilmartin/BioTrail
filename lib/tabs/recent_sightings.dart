// lib/tabs/recent_sightings_tab.dart
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

// Initialize PocketBase client
final pb = PocketBase('https://gilmartin-karl.ie');

Future<List<dynamic>> fetchRecentSightings() async {
  try {
    final response = await pb.collection('sightings').getList(
          page: 1,
          perPage: 10,
          sort: '-created',
        );
    print('Fetched ${response.items}');
    return response.items;
  } catch (e) {
    print('Error fetching sightings: $e');
    return [];
  }
}

Future<String> fetchUniversityName(String universityId) async {
  try {
    final university = await pb.collection('universities').getOne(universityId);
    return university.toJson()['name'] ?? 'Unknown University';
  } catch (e) {
    print('Error fetching university name: $e');
    return 'Unknown University';
  }
}

Future<String> fetchUserName(String userId) async {
  try {
    final user = await pb.collection('users').getOne(userId);
    print('User: ${user.toJson()}');
    return user.toJson()['name'] ?? 'Anonymous';
  } catch (e) {
    print('Error fetching user name: $e');
    return 'Anonymous';
  }
}




class RecentSightingsTab extends StatefulWidget {
  @override
  _RecentSightingsTabState createState() => _RecentSightingsTabState();
}

class _RecentSightingsTabState extends State<RecentSightingsTab> {
  late Future<List<dynamic>> _recentSightings;

  @override
  void initState() {
    super.initState();
    _recentSightings = fetchRecentSightings();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _recentSightings,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading sightings: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No recent sightings found.'));
        } else {
          final sightings = snapshot.data!;
          return ListView.builder(
            itemCount: sightings.length,
            itemBuilder: (context, index) {
              final sighting = sightings[index];
              final sightingJson = sighting.toJson(); // Convert RecordModel to JSON

final species = sightingJson['species'] ?? 'Unknown Species';

return ListTile(
  title: Text(
    species,
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FutureBuilder<String>(
        future: fetchUniversityName(sightingJson['university']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading university...');
          } else if (snapshot.hasError) {
            return Text('Error loading university');
          } else {
            return Text('University: ${snapshot.data}');
          }
        },
      ),
      FutureBuilder<String>(
        future: fetchUserName(sightingJson['user']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading user...');
          } else if (snapshot.hasError) {
            return Text('Error loading user');
          } else {
            return Text('Spotted by: ${snapshot.data}');
          }
        },
      ),
    ],
  ),
);
            },
          );
        }
      },
    );
  }
}