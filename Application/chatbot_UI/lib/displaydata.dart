import 'package:chatbot/filter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';

class DisplayPage extends StatefulWidget {
  const DisplayPage({super.key, required this.id, required this.number});
  final String id;
  final String number;
  //const DisplayPage({Key? key, required this.id}) : super(key: key);
  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  List<Map<String, dynamic>> _dataList = [];

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
    fetchData(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation ${widget.number}'),
      ),
      body: ListView.builder(
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
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                answer,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 22,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
