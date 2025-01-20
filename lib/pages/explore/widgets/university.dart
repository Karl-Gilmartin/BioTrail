import 'package:flutter/material.dart';
import 'package:bio_trail/pages/explore/widgets/route.dart';
import 'package:pocketbase/pocketbase.dart';

class UniversityWidget extends StatefulWidget {
  final String universityName;
  final String imageUrl;
  final String universityId;
  final bool isExpanded;
  final VoidCallback onTap;

  const UniversityWidget({
    Key? key,
    required this.universityName,
    required this.imageUrl,
    required this.universityId,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  _UniversityWidgetState createState() => _UniversityWidgetState();
}

class _UniversityWidgetState extends State<UniversityWidget> {
  final pb = PocketBase('https://gilmartin-karl.ie');
  List<Map<String, dynamic>> routes = [];
  bool isLoadingRoutes = false;

  @override
  void didUpdateWidget(covariant UniversityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded && routes.isEmpty) {
      _fetchRoutes();
    }
  }

  Future<void> _fetchRoutes() async {
    setState(() {
      isLoadingRoutes = true;
    });
    try {
      final records = await pb.collection('routes').getList(
        filter: 'university="${widget.universityId}"',
      );
      setState(() {
        routes = records.items.map((record) {
          return {
            'id': record.id,
            'name': record.data['name'],
            'spots': record.data['spots'],
          };
        }).toList();
        isLoadingRoutes = false;
      });
    } catch (e) {
      print('Error fetching routes: $e');
      setState(() {
        isLoadingRoutes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University Image with rounded corners
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                widget.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 160,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    Center(child: Icon(Icons.error, color: Colors.red, size: 50)),
              ),
            ),

            // University Name
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.universityName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(10, 86, 86, 1),
                      ),
                    ),
                  ),
                  Icon(
                    widget.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Color.fromRGBO(10, 86, 86, 1),
                    size: 28,
                  ),
                ],
              ),
            ),

            // Loading indicator for routes
            if (widget.isExpanded)
              isLoadingRoutes
                  ? Center(child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ))
                  : Column(
                      children: routes.map((route) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(16),
                              backgroundColor: Color.fromRGBO(10, 86, 86, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoutePage(
                                    routeId: route['id'],
                                    routeName: route['name'],
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  route['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${route['spots']} Spots",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
