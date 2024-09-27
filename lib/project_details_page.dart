import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectDetailsPage extends StatelessWidget {
  final String projectId;

  ProjectDetailsPage({required this.projectId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, List<Map<String, dynamic>>>> _getMaterialUsage() async {
    DocumentSnapshot projectDoc = await _firestore.collection('projects').doc(projectId).get();
    List<dynamic> materialUsages = projectDoc['materialUsed'] ?? [];

    Map<String, List<Map<String, dynamic>>> groupedByDate = {};

    for (var usage in materialUsages) {
      DateTime date = (usage['date'] as Timestamp).toDate();
      String materialId = usage['materialId'];
      int quantity = usage['quantity'];
      String id = usage['id'];

      // Format the date to just the day
      String formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Fetch material details
      DocumentSnapshot materialDoc = await _firestore.collection('materials').doc(materialId).get();
      double price = (materialDoc['price'] as num).toDouble();
      String name = materialDoc['name'] ?? 'Unknown';

      Map<String, dynamic> materialUsage = {
        'name': name,
        'price': price,
        'quantity': quantity,
        'total': price * quantity,
        'id': id,
        'imageUrl': materialDoc['imageUrl'] ?? 'b_logo.png',
      };

      if (!groupedByDate.containsKey(formattedDate)) {
        groupedByDate[formattedDate] = [];
      }
      groupedByDate[formattedDate]!.add(materialUsage);
    }

    return groupedByDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details'),
        backgroundColor: Colors.blueGrey,
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _getMaterialUsage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No material usage found.'));
          }

          Map<String, List<Map<String, dynamic>>> materialUsageByDate = snapshot.data!;
          double totalProjectCost = 0.0;

          // Calculate total project cost
          materialUsageByDate.forEach((dateKey, materials) {
            double dailyTotalCost = materials.fold(0.0, (sum, usage) => sum + (usage['total'] as double));
            totalProjectCost += dailyTotalCost;
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: materialUsageByDate.keys.length,
                  itemBuilder: (context, index) {
                    String dateKey = materialUsageByDate.keys.elementAt(index);
                    List<Map<String, dynamic>> materials = materialUsageByDate[dateKey]!;

                    double dailyTotalCost = materials.fold(0.0, (sum, usage) => sum + (usage['total'] as double));

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateKey,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          DataTable(
                            columns: [
                              DataColumn(label: Text('Material')),
                              DataColumn(label: Text('Price')),
                              DataColumn(label: Text('Quantity')),
                              DataColumn(label: Text('Total')),
                            ],
                            rows: materials.map((material) {
                              return DataRow(
                                cells: [
                                  DataCell(Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/${material['imageUrl']}',
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(width: 8),
                                      Text(material['name']),
                                    ],
                                  )),
                                  DataCell(Text('${material['price'].toStringAsFixed(2)} dh')),
                                  DataCell(Text('${material['quantity']}')),
                                  DataCell(Text('${material['total'].toStringAsFixed(2)} dh')),
                                ],
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Total : ${dailyTotalCost.toStringAsFixed(2)} dh',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.blueGrey[50],
                child: Text(
                  'Total Project Cost: ${totalProjectCost.toStringAsFixed(2)} dh',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
