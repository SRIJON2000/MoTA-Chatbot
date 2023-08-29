import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'displaydata.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String _selectedDocumentId = '';
  String rating = '';
  int _selectedRatingFilter = 1;

  List<String> _documentIds = [];

  List<Map<String, dynamic>> _dataList = [];

  Future<void> _loadDocumentIds(String rating) async {
    final response = await http.get(
        Uri.parse('http://localhost:80/loadfilterconversations/' + rating));
    final data = json.decode(response.body);
    setState(() {
      _documentIds = List<String>.from(data);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10.0),
            Text('Select a rating filter:'),
            DropdownButtonFormField<int>(
              value: _selectedRatingFilter,
              onChanged: (value) {
                setState(() {
                  _selectedRatingFilter = value!;
                  _loadDocumentIds(_selectedRatingFilter.toString());
                });
              },
              items: [
                DropdownMenuItem<int>(
                  value: 0, // Assuming 'All' corresponds to a value of 0
                  child: Text('All'),
                ),
                ...List.generate(5, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  );
                }),
              ],
            ),
            if (_documentIds.isEmpty) ...[
              const SizedBox(height: 10.0),
              Text(
                "No records selected",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ] else ...[
              Divider(height: 6.0),
              Divider(height: 1.0),
              SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _documentIds.length,
                      itemBuilder: (_, index) {
                        return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.all(8),
                            child: ElevatedButton(
                                onPressed: (() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DisplayPage(
                                            id: _documentIds[index].toString(),
                                            number: '${index + 1}')),
                                  );
                                }),
                                child: Text('Conversation ${index + 1}')));
                      },
                    ),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
