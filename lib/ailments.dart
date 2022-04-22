import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AilmentsScreen extends StatefulWidget {
  @override
  _AilmentsScreenState createState() => _AilmentsScreenState();
}

class _AilmentsScreenState extends State<AilmentsScreen> {
  late String titleText;
  late String descText;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final CollectionReference ailmentsCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('ailments');

  Future<void> saveAilment() {
    return ailmentsCollection.add({
      'title': _titleController.text,
      'description': _descController.text,
      'submitted': DateTime.now()
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter Information"),
            content: Column(
              children: [
                TextField(
                  decoration: InputDecoration(hintText: "Title"),
                  onChanged: (value) {
                    setState(() {
                      titleText = value;
                    });
                  },
                  controller: _titleController,
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
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('SAVE'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                  saveAilment();
                  _titleController.clear();
                  _descController.clear();
                },
              ),
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                    _titleController.clear();
                    _descController.clear();
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _displayAilmentDialog(
      BuildContext context, String title, String desc) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(desc),
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
      barrierDismissible: false, // user must tap button!
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
        title: Text("Ailments"),
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
                  .collection('ailments')
                  .orderBy('submitted')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.requireData.size,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Card(
                            child: ListTile(
                          title:
                              Text(snapshot.requireData.docs[index]['title']),
                          subtitle: Text(
                              snapshot.requireData.docs[index]['description'],
                              maxLines: 1),
                          onTap: () {
                            _displayAilmentDialog(
                                context,
                                snapshot.requireData.docs[index]['title'],
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
