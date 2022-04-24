import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GrowthScreen extends StatefulWidget {
  @override
  _GrowthScreenState createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  late String heightText;
  late String weightText;
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final CollectionReference growthCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('growth');

  Future<void> saveGrowth() {
    return growthCollection.add({
      'height': heightText,
      'weight': weightText,
      'date': _dateController.text,
      'submitted': DateTime.now()
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: Text("Enter Information"),
            content: Column(
              children: [
                TextField(
                  decoration: InputDecoration(hintText: "Height"),
                  onChanged: (value) {
                    setState(() {
                      heightText = value;
                    });
                  },
                  controller: _heightController,
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Weight"),
                  onChanged: (value) {
                    setState(() {
                      weightText = value;
                    });
                  },
                  controller: _weightController,
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    hintText: "Date",
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    DateTime date = (await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year - 20),
                        lastDate: DateTime(DateTime.now().year + 20)))!;
                    _dateController.text = date.toString().substring(0, 10);
                  },
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('SAVE'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                  saveGrowth();
                  _heightController.clear();
                  _weightController.clear();
                  _dateController.clear();
                },
              ),
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                    _heightController.clear();
                    _weightController.clear();
                    _dateController.clear();
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _displayGrowthDialog(
      BuildContext context, String date, String height, String weight) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: Text(date),
            content: Column(
              children: [
                Align(alignment: Alignment.centerLeft, child: Text(height)),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Align(
                        alignment: Alignment.centerLeft, child: Text(weight))),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CLOSE'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _displayDeleteDialog(DocumentReference reference) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to delete this item?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .runTransaction((Transaction myTransaction) async {
                  myTransaction.delete(reference);
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        title: Text("Growth"),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(firebaseAuth.currentUser!.uid)
                  .collection('growth')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.requireData.size,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Card(
                            child: ListTile(
                          title: Text(snapshot.requireData.docs[index]['date']),
                          onTap: () {
                            _displayGrowthDialog(
                                context,
                                snapshot.requireData.docs[index]['date'],
                                snapshot.requireData.docs[index]['height'],
                                snapshot.requireData.docs[index]['weight']);
                          },
                          trailing: IconButton(
                              onPressed: () {
                                _displayDeleteDialog(
                                    snapshot.requireData.docs[index].reference);
                              },
                              icon: Icon(Icons.delete)),
                        ));
                      });
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _displayTextInputDialog(context);
        },
      ),
    );
  }
}
