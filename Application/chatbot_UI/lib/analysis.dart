import 'package:chatbot/filter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String _selectedDocumentId = '';
  String rating = '';
  int _selectedRatingFilter = 1;

  List<String> _documentIds = [];

  List<Map<String, dynamic>> _dataList = [];

  Future<void> _loadDocumentIds() async {
    final response =
        await http.get(Uri.parse('http://localhost:80/loadconversations'));
    final data = json.decode(response.body);
    setState(() {
      _documentIds = List<String>.from(data);
    });
  }

  Future<void> fetchData(String id) async {
    final response =
        await http.get(Uri.parse('http://localhost:80/getall/' + id));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      setState(() {
        _dataList = List<Map<String, dynamic>>.from(jsonData);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDocumentIds();
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
            Text(
              'Select a conversation ID:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            DropdownButtonFormField2(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12.0),
                hintText: 'Select Conversation',
                fillColor: Colors.grey[200],
                filled: true,
              ),
              items: _documentIds
                  .map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                        ),
                      ))
                  .toList(),
              onChanged: (value) async {
                // Do Smoething here
                setState(() {
                  _selectedDocumentId = value.toString();
                });
                _selectedDocumentId = value.toString();
                final response = await http.get(Uri.parse(
                    'http://localhost:80/getall/' + value.toString()));
                final response1 = await http.get(Uri.parse(
                    'http://localhost:80/getrating/' + value.toString()));
                if (response.statusCode == 200) {
                  final jsonData = jsonDecode(response.body);
                  final jsonData1 = jsonDecode(response1.body);
                  setState(() {
                    _dataList = List<Map<String, dynamic>>.from(jsonData);
                    rating = jsonData1['rating'];
                  });
                }
                // setState(() {
                //   _selectedDocumentId = value.toString();
                //   fetchData(_selectedDocumentId);
                // });
              },
              onSaved: (value) {
                _selectedDocumentId = value.toString();
              },
              validator: (conversation) {
                if (conversation == null || conversation.isEmpty) {
                  return 'Please select';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            // Text('Select a rating filter:'),
            // DropdownButtonFormField<int>(
            //   value: _selectedRatingFilter,
            //   onChanged: (value) {
            //     setState(() {
            //       _selectedRatingFilter = value!;
            //     });
            //   },
            //   items: List.generate(5, (index) {
            //     return DropdownMenuItem<int>(
            //       value: index + 1,
            //       child: Text('${index + 1}'),
            //     );
            //   }),
            // ),
            if (_dataList.isEmpty) ...[
              Text(
                "No records selected",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Text(
                    "Conversation ID ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _selectedDocumentId,
                    style: TextStyle(
                      color: Color.fromARGB(255, 7, 0, 225),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Divider(height: 1.0),
              Row(
                children: [
                  Text(
                    "Rating ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    rating,
                    style: TextStyle(
                      color: Color.fromARGB(255, 7, 0, 225),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Divider(height: 6.0),
              Divider(height: 1.0),
              // SingleChildScrollView(
              //   child: Column(
              //     children: [
              //       ListView.builder(
              //         shrinkWrap: true,
              //         physics: NeverScrollableScrollPhysics(),
              //         itemCount: _dataList.length,
              //         itemBuilder: (_, index) {
              //           final data = _dataList[index];
              //           final question = data['question'];
              //           final answer = data['answer'];

              //           return Container(
              //             decoration: BoxDecoration(
              //               border: Border.all(color: Colors.grey[400]!),
              //               borderRadius: BorderRadius.circular(10),
              //             ),
              //             margin: EdgeInsets.all(8),
              //             child: ListTile(
              //               title: Text(
              //                 question,
              //                 style: TextStyle(
              //                   fontWeight: FontWeight.bold,
              //                   fontSize: 20,
              //                 ),
              //               ),
              //               subtitle: Text(
              //                 answer,
              //                 style: TextStyle(
              //                   color: Colors.grey[700],
              //                   fontSize: 22,
              //                 ),
              //               ),
              //             ),
              //           );
              //         },
              //       ),
              //     ],
              //   ),
              // )
              SafeArea(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _dataList.length,
                      itemBuilder: (_, index) {
                        final data = _dataList[index];
                        final question = data['question'];
                        final answer = data['answer'];

                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(
                              question,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            subtitle: Text(
                              answer,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
