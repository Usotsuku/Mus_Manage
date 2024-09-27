import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_materials_page.dart'; // Import the new page for managing materials

class MaterialsPage extends StatefulWidget {
  @override
  _MaterialsPageState createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _quantityController = TextEditingController();

  Future<List<DocumentSnapshot>> _getMaterials() async {
    QuerySnapshot snapshot = await _firestore.collection('materials').get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> _getProjects() async {
    QuerySnapshot snapshot = await _firestore.collection('projects').get();
    return snapshot.docs;
  }

  void _addMaterialUsage(String materialId) async {
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity > 0) {
      try {
        List<DocumentSnapshot> projects = await _getProjects();
        String? selectedProjectId = await showDialog<String>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Select Project'),
              content: Container(
                width: double.maxFinite,
                child: ListView(
                  children: projects.map((project) {
                    return ListTile(
                      title: Text(project['name']),
                      onTap: () {
                        Navigator.of(context).pop(project.id);
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );

        if (selectedProjectId != null) {
          await _firestore.collection('projects').doc(selectedProjectId).update({
            'materialUsed': FieldValue.arrayUnion([
              {
                'materialId': materialId,
                'quantity': quantity,
                'date': Timestamp.now(),
                'id': DateTime.now().toIso8601String(), // Add a unique ID
              }
            ]),
          });
          _quantityController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Material usage added successfully.')),
          );
        }
      } catch (e) {
        print('Error adding material usage: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add material usage.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<DocumentSnapshot>>(
          future: _getMaterials(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No materials found.'));
            }

            List<DocumentSnapshot> materials = snapshot.data!;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                var material = materials[index];
                String name = material['name'] ?? 'No name';
                double price = (material['price'] as num?)?.toDouble() ?? 0.0;
                String imageUrl = material['imageUrl'] ?? 'b_logo.png'; // Dynamically load the image
                String localImagePath = 'assets/images/$imageUrl'; // Using local image path

                return Card(
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          localImagePath,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Price: \$${price.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter Quantity Used',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _addMaterialUsage(material.id),
                        child: Text('Add Usage'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageMaterialsPage()),
                );
              },
              child: Text('Manage Materials'),
            ),
          ),
        ),
      ],
    );
  }
}
