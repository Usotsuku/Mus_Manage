import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageMaterialsPage extends StatefulWidget {
  @override
  _ManageMaterialsPageState createState() => _ManageMaterialsPageState();
}

class _ManageMaterialsPageState extends State<ManageMaterialsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> _getMaterials() async {
    QuerySnapshot snapshot = await _firestore.collection('materials').get();
    return snapshot.docs;
  }

  void _deleteMaterial(String materialId) async {
    try {
      await _firestore.collection('materials').doc(materialId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Material deleted successfully.')),
      );
    } catch (e) {
      print('Error deleting material: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete material.')),
      );
    }
  }

  void _showMaterialForm({DocumentSnapshot? material}) async {
    final isUpdate = material != null;
    final nameController = TextEditingController(text: isUpdate ? material!['name'] : '');
    final priceController = TextEditingController(text: isUpdate ? material!['price'].toString() : '');
    final imageUrlController = TextEditingController(text: isUpdate ? material!['imageUrl'] : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isUpdate ? 'Update Material' : 'Add New Material'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Material Name'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL (filename only, e.g., "cement.png")'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text;
                final price = double.tryParse(priceController.text) ?? 0.0;
                final imageUrl = imageUrlController.text;

                if (name.isNotEmpty && price > 0 && imageUrl.isNotEmpty) {
                  try {
                    if (isUpdate) {
                      await _firestore.collection('materials').doc(material!.id).update({
                        'name': name,
                        'price': price,
                        'imageUrl': imageUrl,
                      });
                    } else {
                      await _firestore.collection('materials').add({
                        'name': name,
                        'price': price,
                        'imageUrl': imageUrl,
                      });
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isUpdate ? 'Material updated successfully.' : 'Material added successfully.')),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Error saving material: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save material.')),
                    );
                  }
                }
              },
              child: Text(isUpdate ? 'Update' : 'Add'),
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
        title: Text('Manage Materials'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
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

          return ListView.builder(
            itemCount: materials.length,
            itemBuilder: (context, index) {
              var material = materials[index];
              String name = material['name'] ?? 'No name';
              double price = (material['price'] as num?)?.toDouble() ?? 0.0;
              String imageUrl = material['imageUrl'] ?? 'default_image.png';  // Fallback if no image provided
              String localImagePath = 'assets/images/$imageUrl';

              return Card(
                elevation: 4,
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: Image.asset(
                    localImagePath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(name),
                  subtitle: Text('Price: ${price.toStringAsFixed(2)} dh'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showMaterialForm(material: material),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteMaterial(material.id),
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
        onPressed: () => _showMaterialForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
