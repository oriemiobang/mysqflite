// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mysqflite/components/helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sql',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _journals = [];

  bool _isloading = true;
  void _refereshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isloading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refereshJournals();
    print('..number of items: ${_journals.length}');
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _showform(int? id) async {
    if (id != null) {
      final existingJournals =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournals['title'];
      _descriptionController.text = existingJournals['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              child: Padding(
                padding: EdgeInsets.only(
                    top: 15,
                    right: 15,
                    left: 15,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (id == null) {
                            await _addItem();
                          }

                          if (id != null) {
                            await _updateItem(id);
                          }
                          _titleController.text = '';
                          _descriptionController.text = '';
                          Navigator.of(context).pop();
                        },
                        child: Text(id == null ? 'Create New' : 'Update'))
                  ],
                ),
              ),
            ));
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refereshJournals();
    print('item length: ${_journals.length}');
  }

  Future<void> _updateItem(
    int id,
  ) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refereshJournals();
    // print('item length: ${_journals.length}');
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item successfully deleted')));
    _refereshJournals();
    // print('item length: ${_journals.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('SQL'),
      ),
      body: ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.all(15),
              child: ListTile(
                title: Text(_journals[index]['title']),
                subtitle: Text(_journals[index]['description']),
                trailing: SizedBox(
                  width: 100,
                  child: Row(children: [
                    IconButton(
                      onPressed: () => _showform(_journals[index]['id']),
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () => _deleteItem(_journals[index]['id']),
                      icon: Icon(Icons.delete),
                    ),
                  ]),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showform(null);
        },
        tooltip: 'Add to database',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
