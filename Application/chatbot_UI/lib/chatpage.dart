import 'dart:convert';
import 'package:chatbot/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  bool firstchat = true;
  String conversation_id = '';
  List<String> _messages = [];
  List<String> ids = [];
  Future<void> _getResponse(String message) async {
    if (firstchat == true) {
      final response = await http.get(Uri.parse(
          // ignore: prefer_interpolation_to_compose_strings
          'http://localhost:80/get/' + message));
      if (response.statusCode == 200) {
        final r2 = await http.put(Uri.parse(
            // ignore: prefer_interpolation_to_compose_strings
            'http://localhost:80/addconversation/'));
        final conid = json.decode(r2.body);

        final responseData = json.decode(response.body);
        final r1 = await http.put(Uri.parse(
            // ignore: prefer_interpolation_to_compose_strings
            'http://localhost:80/add/' +
                message +
                '/' +
                responseData.toString() +
                '/' +
                conid.toString()));
        final id = json.decode(r1.body);
        setState(() {
          // _messages.add(message);
          _messages.add(responseData);
          print(_messages);
          ids.add('null');
          ids.add(id.toString());
          conversation_id = conid.toString();
          firstchat = false;
          //print(_messages);
        });
      } else {
        setState(() {
          _messages.add('User: $message');
          _messages.add('Bot: Error - ${response.statusCode}');
          //conversation_id = conid.toString();
        });
      }
    } else {
      final response = await http.get(Uri.parse(
          // ignore: prefer_interpolation_to_compose_strings
          'http://localhost:80/get/' + message));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final r1 = await http.put(Uri.parse(
            // ignore: prefer_interpolation_to_compose_strings
            'http://localhost:80/add/' +
                message +
                '/' +
                responseData.toString() +
                '/' +
                conversation_id.toString()));
        final id = json.decode(r1.body);
        setState(() {
          // _messages.add(message);
          _messages.add(responseData);
          ids.add('null');
          ids.add(id.toString());
          //print(_messages);
        });
      } else {
        setState(() {
          _messages.add('User: $message');
          _messages.add('Bot: Error - ${response.statusCode}');
          //conversation_id = conid.toString();
        });
      }
    }
  }

  void rate(String id) {
    double _rating = 0.0;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            content: Container(
                height: 200,
                child: Column(children: [
                  const Text(
                    "Rate The Conversation",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 16, 16, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SafeArea(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        side: const BorderSide(
                            width: 2, color: Colors.deepPurple),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.all(18),
                      ),
                      onPressed: () async {
                        final response3 = await http.post(
                          Uri.parse('http://localhost:80/update/' +
                              id +
                              '/' +
                              _rating.toString()),
                        );

                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => HomePage()),
                        // );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => HomePage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text('Submit'),
                    ),
                  )
                ])));
      },
    );
  }

  void _handleSubmitted(String message) {
    _textController.clear();
    setState(() {
      _messages.add(message);
    });

    _getResponse(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatBot For MoTA'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 5),
          Text(
            'Note: Once you exit from the page the conversation will be deleted',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: false,
              itemBuilder: (_, int index) {
                bool isMe = false;
                if (index % 2 == 0) {
                  isMe = true;
                }
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: isMe ? Colors.grey[300] : Colors.blue[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft:
                                isMe ? Radius.circular(15) : Radius.circular(0),
                            bottomRight:
                                isMe ? Radius.circular(0) : Radius.circular(15),
                          ),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Text(
                          _messages[index],
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      // if (index % 2 != 0) ...[
                      //   SizedBox(height: 5),
                      //   Container(
                      //       decoration: BoxDecoration(
                      //         color: Colors.blue[300],
                      //         borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(15),
                      //           topRight: Radius.circular(15),
                      //           bottomLeft: Radius.circular(0),
                      //           bottomRight: Radius.circular(15),
                      //         ),
                      //       ),
                      //       padding: EdgeInsets.all(10),
                      //       child: ElevatedButton(
                      //         onPressed: () {
                      //           rate(ids[index]);
                      //         },
                      //         child: Text('Rate'),
                      //         style: ElevatedButton.styleFrom(
                      //           primary: Color.fromARGB(255, 228, 15, 19),
                      //           textStyle: TextStyle(
                      //             color: Colors.white,
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //           padding: EdgeInsets.symmetric(
                      //               horizontal: 20, vertical: 10),
                      //         ),
                      //       )),
                      // ]
                      // SizedBox(height: 5),
                      // Text(
                      //   _messages[index]['time'],
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     color: Colors.grey[600],
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
              itemCount: _messages.length,
            ),
          ),
          if (firstchat == false) ...[
            Divider(height: 1.0),
            ElevatedButton(
              onPressed: () {
                rate(conversation_id);
              },
              child: Text('Complete the conversation'),
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 228, 15, 19),
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _handleSubmitted,
                    decoration: InputDecoration.collapsed(
                      hintText: ' Ask Me Question...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ],
            ),
          ),
          Divider(height: 10.0),
        ],
      ),
    );
  }
}
