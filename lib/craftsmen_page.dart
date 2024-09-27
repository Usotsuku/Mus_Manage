import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CraftsmenPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> _getCraftsmen() async {
    QuerySnapshot snapshot = await _firestore.collection('craftsmen').get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getCraftsmen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No craftsmen found.'));
          }

          List<DocumentSnapshot> craftsmen = snapshot.data!;

          return ListView.builder(
            itemCount: craftsmen.length,
            itemBuilder: (context, index) {
              var craftsman = craftsmen[index];
              String name = craftsman['name'] ?? 'No name';
              String surname = craftsman['surname'] ?? 'No surname';
              
              // Handle salary type
              double salary = (craftsman['salary'] is int)
                  ? (craftsman['salary'] as int).toDouble()
                  : (craftsman['salary'] ?? 150.0); // Default salary if not present

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
