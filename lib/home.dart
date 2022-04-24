import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'signup.dart';
import 'ailments.dart';
import 'medical_history.dart';
import 'growth.dart';

class Home extends StatefulWidget {
  final String? uid;

  Home({this.uid});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Overview"),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              FirebaseAuth auth = FirebaseAuth.instance;
              auth.signOut().then((res) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp()),
                    (Route<dynamic> route) => false);
              });
            },
          )
        ],
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              title: Text('Growth'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => GrowthScreen()));
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Ailments'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AilmentsScreen()));
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Medical History'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MedicalHistoryScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
