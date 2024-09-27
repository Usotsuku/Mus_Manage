import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LaborersPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> _getLaborers() async {
    QuerySnapshot snapshot = await _firestore.collection('laborers').get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getLaborers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No laborers found.'));
          }

          List<DocumentSnapshot> laborers = snapshot.data!;

          return ListView.builder(
            itemCount: laborers.length,
            itemBuilder: (context, index) {
              var laborer = laborers[index];
              String name = laborer['name'] ?? 'No name';
              String surname = laborer['surname'] ?? 'No surname';
              
              // Handle salary type
              double salary = (laborer['salary'] is int)
                  ? (laborer['salary'] as int).toDouble()
                  : (laborer['salary'] ?? 100.0); // Default salary if not present

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('$name $surname'),
                  subtitle: Text('Salary: ${salary.toStringAsFixed(2)} dh'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
