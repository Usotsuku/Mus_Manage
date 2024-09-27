import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'materials_page.dart';
import 'project_details_page.dart'; // Import your project details page

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0; // Track the selected page index

  List<Widget> _pages = [
    ProjectsPage(), // Default main page
    MaterialsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        toolbarHeight: 80.0,
        automaticallyImplyLeading: false, // Removes the back button
        title: Row(
          children: [
            Image.asset(
              'assets/images/b_logo.png', // Your logo asset
              height: 40,
            ),
            Spacer(),
            Text(
              'Welcome, ${capitalizeFirstLetter(FirebaseAuth.instance.currentUser?.email?.split('@')[0].split('.')[0]) ?? 'User'}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.logout, color: const Color.fromARGB(255, 8, 3, 3)),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/sign_in');
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Projects',
            backgroundColor: _selectedIndex == 0 ? Colors.blueGrey[700] : Colors.blueGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Materials',
            backgroundColor: _selectedIndex == 1 ? Colors.blueGrey[700] : Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}

class ProjectsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> _getProjects() async {
    QuerySnapshot snapshot = await _firestore.collection('projects').get();
    return snapshot.docs;
  }

  void _showAddOrUpdateDialog(BuildContext context, {DocumentSnapshot? project}) {
    final TextEditingController nameController = TextEditingController(text: project?['name'] ?? '');
    final TextEditingController locationController = TextEditingController(text: project?['location'] ?? '');
    final bool isUpdate = project != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isUpdate ? 'Update Project' : 'Add Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Project Name'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (isUpdate) {
                  await _firestore.collection('projects').doc(project!.id).update({
                    'name': nameController.text,
                    'location': locationController.text,
                  });
                } else {
                  await _firestore.collection('projects').add({
                    'name': nameController.text,
                    'location': locationController.text,
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text(isUpdate ? 'Update' : 'Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
        backgroundColor: Colors.blueGrey,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showAddOrUpdateDialog(context, project: project),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await _firestore.collection('projects').doc(project.id).delete();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.info),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDetailsPage(projectId: project.id),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrUpdateDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }
}

String? capitalizeFirstLetter(String? name) {
  if (name == null || name.isEmpty) {
    return null;
  }
  return name[0].toUpperCase() + name.substring(1);
}
