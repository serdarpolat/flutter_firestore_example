import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Band Name Session',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(
        title: 'Posiible Band Names',
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              document['name'],
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFDDDDFF),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              document['votes'].toString(),
              style: Theme.of(context).textTheme.display1,
            ),
          ),
        ],
      ),
      onTap: () {
        Firestore.instance.runTransaction((transaction) async {
          DocumentSnapshot freshSnap =
              await transaction.get(document.reference);
          await transaction
              .update(freshSnap.reference, {'votes': freshSnap['votes'] + 1});
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Possible Band Names'),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('bandnames').snapshots(),
          builder: (context, snapchost) {
            if (!snapchost.hasData) return const Text('Loading...');
            return ListView.builder(
              itemExtent: 80.0,
              itemCount: snapchost.data.documents.length,
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapchost.data.documents[index]),
            );
          }),
    );
  }
}
