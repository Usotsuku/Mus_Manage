/*import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initializeDatabase() async {
  final firestore = FirebaseFirestore.instance;

  // Example Project Document
  await firestore.collection('projects').doc('project1').set({
    'name': 'Project Alpha',
    'responsiblePerson': 'Alice',
    'location' :'casablanca',
    'craftsmen': [],  // Initialize with empty array
    'laborers': [],   // Initialize with empty array
    'materialUsed': [],  // Initialize with empty array
  });

  // Example Craftsman Document
  await firestore.collection('craftsmen').doc('craftsman1').set({
    'salary': 150,
    'name': 'John',
    'surname': 'Doe',
    'CIN': '123456789',
    'laborers': [],  // Initialize with empty array or reference IDs
  });

  // Example Laborer Document
  await firestore.collection('laborers').doc('laborer1').set({
    'salary': 100,
    'name': 'Jane',
    'surname': 'Smith',
    'CIN': '987654321',
  });

  // Example Material Document
  await firestore.collection('materials').doc('material1').set({
  'name': 'Concrete',
  'price': 200,
  'imageURL': 'assets/images/b_logo.png', // Add image URL
});

  print('Firestore database initialized with example data.');
}
*/