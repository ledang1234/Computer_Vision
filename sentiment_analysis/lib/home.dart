import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:http/http.dart';
import 'package:http/http.dart' as http;

// https://rapidapi.com/twinword/api/emotion-analysis/
class APIService {
  static const _api_key = 'fdc0ad8e97msh2b35850a821ebf8p119776jsn1602b5edf6eb';
  static const String _baseUrl =
      'https://twinword-emotion-analysis-v1.p.rapidapi.com/?rapidapi-key=fdc0ad8e97msh2b35850a821ebf8p119776jsn1602b5edf6eb';
      
  static const Map<String, String> _header = {
    'content-type': 'application/x-www-form-urlencoded',
    'x-rapidapi-host': 'twinword-emotion-analysis-v1.p.rapidapi.com',
    'x-rapidapi-key': _api_key,
    'useQueryString': 'true',
  };

  Future<SentAna> post({ required Map<String, String> query}) async {
        final response = await http.post(Uri.parse(_baseUrl), headers: _header, body: query);
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('success' + response.body);
      return SentAna.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load json data');
    }
  }
}

class SentAna {
  final String emotions;

  SentAna({required this.emotions});

  factory SentAna.fromJson(Map<String, dynamic> json) {
    return SentAna(emotions: json['emotions_detected'][0]);
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  // API
  bool _loading = true;
  final myController = TextEditingController();
  
  APIService apiService = APIService();
  Future<SentAna>? analysis;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.004, 1],
            colors: [
              Color(0xFFe100ff),
              Color(0xFF8E2DE2),
            ],
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 98,
              ),
              // Text(
              //   'Sentiment Analysis',
              //   style: TextStyle(
              //       color: Colors.white,
              //       fontWeight: FontWeight.w800,
              //       fontSize: 28),
              // ),
              // SizedBox(
              //   height: 40,
              // ),
              Container(
                padding: EdgeInsets.all(
                  30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Sentiment Analysis',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 28),
                    ),
                    SizedBox(height: 30),
                    Container(
                      height: 150,
                      child: Image.asset('assets/theater.png'),
                    ),
                    SizedBox(height: 40),
                    Container(
                      child: Center(
                        child: _loading
                            ? Container(
                                width: 300,
                                child: Column(
                                  children: <Widget>[
                                    TextField(
                                      controller: myController,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: InputDecoration(
                                          labelStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize: 21,
                                          ),
                                          labelText: 'Enter a search term: '),
                                    ),
                                    SizedBox(height: 30),
                                  ],
                                ))
                            : Container(),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                // _loading = false;
                                print(myController.text);

                                // API
                                analysis = apiService
                                    .post(query: {'text':myController.text});
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width - 180,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 17),
                              decoration: BoxDecoration(
                                  color: Color(0xFF56ab2f),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                'Find Emotions',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),


                          // API
                          FutureBuilder<SentAna>(
                              future: analysis,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    'Prediction is: ' + snapshot.data!.emotions,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 29,
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('${snapshot.error}');
                                }
                                // return CircularProgressIndicator();
                                return Text( 'Prediction is: ',
                                style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 29,
                                    ), );
                              })
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
