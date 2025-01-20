import 'package:flutter/material.dart';

class RoutePage extends StatelessWidget {
  final String routeId;
  final String routeName;

  const RoutePage({Key? key, required this.routeId, required this.routeName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routeName),
        backgroundColor: Color.fromRGBO(10, 86, 86, 1),
      ),
      body: Center(
        child: Text(
          "Details for $routeName",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
