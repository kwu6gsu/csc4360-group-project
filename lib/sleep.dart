import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SleepScreen extends StatefulWidget {
  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  late String startText;
  late String endText;
  late String descText;
  TextEditingController _startController = TextEditingController();
  TextEditingController _endController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final CollectionReference sleepCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('sleeping schedule');

  Future<void> saveSleep() {
    return sleepCollection.add({
      'start_time': startText,
      'end_time': endText,
      'description': descText,
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
                TextFormField(
                  controller: _startController,
                  decoration: InputDecoration(
                    hintText: "Start Time",
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    TimeOfDay start_time = (await showTimePicker(
                        context: context, initialTime: TimeOfDay.now()))!;
                    _startController.text = start_time.format(context);
                    startText = _startController.text;
                  },
                ),
                TextFormField(
                  controller: _endController,
                  decoration: InputDecoration(
                    hintText: "End Time",
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    TimeOfDay end_time = (await showTimePicker(
                        context: context, initialTime: TimeOfDay.now()))!;
                    _endController.text = end_time.format(context);
                    endText = _endController.text;
                  },
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Description"),
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: null,
                  onChanged: (value) {
                    setState(() {
                      descText = value;
                    });
                  },
                  controller: _descController,
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
                  saveSleep();
                  _startController.clear();
                  _endController.clear();
                  _descController.clear();
                  _dateController.clear();
                },
              ),
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                    _startController.clear();
                    _endController.clear();
                    _descController.clear();
                    _dateController.clear();
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _displaySleepDialog(BuildContext context, String date,
      String start_time, String end_time, String desc) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: Text(date),
            content: Column(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(start_time + " to " + end_time)),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Align(
                        alignment: Alignment.centerLeft, child: Text(desc))),
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
        title: Text("Sleeping Schedule"),
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
                  .collection('sleeping schedule')
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
                          subtitle: Text(snapshot.requireData.docs[index]
                                  ['start_time'] +
                              " to " +
                              snapshot.requireData.docs[index]['end_time']),
                          onTap: () {
                            _displaySleepDialog(
                                context,
                                snapshot.requireData.docs[index]['date'],
                                snapshot.requireData.docs[index]['start_time'],
                                snapshot.requireData.docs[index]['end_time'],
                                snapshot.requireData.docs[index]
                                    ['description']);
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
