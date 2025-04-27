import 'package:flutter/material.dart';
import 'database_helper.dart'; // Make sure your database_helper.dart is correct

class TodayWorkPage extends StatefulWidget {
  @override
  _TodayWorkPageState createState() => _TodayWorkPageState();
}

class _TodayWorkPageState extends State<TodayWorkPage> {
  final TextEditingController _workController = TextEditingController();
  List<Map<String, dynamic>> works = [];

  @override
  void initState() {
    super.initState();
    fetchWorks();
  }

  Future<void> fetchWorks() async {
    final data = await DatabaseHelper().getWorks();
    setState(() {
      works = data;
    });
  }

  Future<void> addWork(String task) async {
    if (task.isNotEmpty) {
      await DatabaseHelper().insertWork(task);
      fetchWorks();
    }
  }

  Future<void> updateWork(int id, String newTask) async {
    if (newTask.isNotEmpty) {
      await DatabaseHelper().updateWork(id, newTask);
      fetchWorks();
    }
  }

  void showAddWorkDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Today\'s Work'),
          content: TextField(
            controller: _workController,
            decoration: InputDecoration(hintText: 'Enter your work'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String task = _workController.text.trim();
                if (task.isNotEmpty) {
                  addWork(task);
                  _workController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showEditWorkDialog(int id, String currentTask) {
    TextEditingController _editController =
        TextEditingController(text: currentTask);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Work'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(hintText: 'Edit your work'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String updatedTask = _editController.text.trim();
                if (updatedTask.isNotEmpty) {
                  await updateWork(id, updatedTask);
                  Navigator.pop(context);
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> showDeleteConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirm Delete'),
              content: Text('Are you sure you want to delete this work?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Cancel
                  },
                  child: Text('No'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Confirm
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('using SQLite'),
        backgroundColor: const Color.fromARGB(255, 203, 219, 247),
      ),
      body: works.isEmpty
          ? Center(child: Text('No work added yet!'))
          : ListView.builder(
              itemCount: works.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(works[index]['id'].toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.horizontal,
                  confirmDismiss: (direction) async {
                    return await showDeleteConfirmationDialog();
                  },
                  onDismissed: (direction) async {
                    await DatabaseHelper().deleteWork(works[index]['id']);
                    setState(() {
                      works.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Work deleted')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0),
                    child: Card(
                      color: Colors.blue[50],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(Icons.work_outline, color: Colors.blue),
                        title: Text(
                          works[index]['task'],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          showEditWorkDialog(
                              works[index]['id'], works[index]['task']);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddWorkDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Work',
      ),
    );
  }
}
