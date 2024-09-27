import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'project_details_page.dart';

class ProjectsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> _getProjects() async {
    QuerySnapshot snapshot = await _firestore.collection('projects').get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _getProjects(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No projects found.'));
        }

        List<DocumentSnapshot> projects = snapshot.data!;

        return ListView.builder(
          itemCount: projects.length,
          itemBuilder: (context, index) {
            var project = projects[index];
            String name = project['name'] ?? 'No name';
            String location = project['location'] ?? 'No location';

            return Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(name),
                subtitle: Text(
                  location,
                  style: TextStyle(fontSize: 14.0),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailsPage(projectId: project.id),
                      ),
                    );
                  },
                  child: Text('Details'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
