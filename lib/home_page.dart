import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _branchController = TextEditingController();
  final _cgpaController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  List<Map<String, dynamic>> _studentEntries = [];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  Future<void> _createEntry() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a new document in the students collection
        await _firestore.collection('students').add({
          'name': _nameController.text,
          'rollNumber': _rollController.text,
          'branch': _branchController.text,
          'cgpa': double.parse(_cgpaController.text),
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': _currentUser?.uid,
        });

        _clearForm();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student entry created successfully!')),
        );

        // Show the entries in a popup
        _showEntriesPopup();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating entry: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updateEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String rollNumberIdentifier = _rollController.text.trim();
    final String nameNew = _nameController.text.trim();
    final String branchNew = _branchController.text.trim();
    final String cgpaNewStr = _cgpaController.text.trim();

    if (rollNumberIdentifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Roll Number cannot be empty')),
      );
      return;
    }

    double? cgpaNew;
    if (cgpaNewStr.isNotEmpty) {
      cgpaNew = double.tryParse(cgpaNewStr);
      if (cgpaNew == null || cgpaNew < 0 || cgpaNew > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid CGPA between 0 to 10 or leave it empty')),
        );
        return;
      }
    }
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('students')
          .where('rollNumber', isEqualTo: rollNumberIdentifier)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs.first.id;
        Map<String, dynamic> upDateddata = {};
        if (nameNew.isNotEmpty) {
          upDateddata['name'] = nameNew;
        }
        if (branchNew.isNotEmpty) {
          upDateddata['branch'] = branchNew;
        }
        if (cgpaNew != null) {
          upDateddata['cgpa'] = cgpaNew;
        }
        if (upDateddata.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No changes to update')),
          );
          return;
        }
        await _firestore.collection('students').doc(documentId).update(upDateddata);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student entry with roll no.: $rollNumberIdentifier updated successfully!')),
        );
        _clearForm();
        _showEntriesPopup();
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No student found with roll no.: $rollNumberIdentifier')),
        );
      }
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating entry: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final String rollNumberIdentifier = _rollController.text.trim();
    if (rollNumberIdentifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Roll Number cannot be empty')),
      );
      return;
    }

    try {
      // First check if the student exists
      QuerySnapshot querySnapshot = await _firestore
          .collection('students')
          .where('rollNumber', isEqualTo: rollNumberIdentifier)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No student found with roll no.: $rollNumberIdentifier')),
        );
        return;
      }

      // If student exists, show confirmation dialog
      final bool confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text(
                'Are you sure you want to delete the student with Roll No: $rollNumberIdentifier? This action cannot be undone.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete'),
              ),
            ],
          );
        }
      ) ?? false;

      if (!confirmDelete) {
        return;
      }

      // If confirmed, proceed with deletion
      String documentId = querySnapshot.docs.first.id;
      await _firestore.collection('students').doc(documentId).delete();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student entry with roll no.: $rollNumberIdentifier deleted successfully!')),
      );

      // Clear form and show updated table
      _clearForm();
      _showEntriesPopup();

    } catch (e) {
      print('Error during deletion: $e'); // For debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting entry: ${e.toString()}')),
      );
    }
  }

  Future<void> _showEntriesPopup() async {
    // Fetch all entries
    QuerySnapshot querySnapshot = await _firestore.collection('students').get();
    _studentEntries = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();

    // Show popup with entries
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Student Entries',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
                        dataRowColor: MaterialStateProperty.all(Colors.white),
                        columns: [
                          DataColumn(
                            label: Container(
                              width: 150,
                              child: Text(
                                'Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: 120,
                              child: Text(
                                'Roll No',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: 150,
                              child: Text(
                                'Branch',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: 100,
                              child: Text(
                                'CGPA',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                        rows: _studentEntries.map((entry) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  width: 150,
                                  child: Text(entry['name'] ?? ''),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 120,
                                  child: Text(entry['rollNumber'] ?? ''),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 150,
                                  child: Text(entry['branch'] ?? ''),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 100,
                                  child: Text(entry['cgpa']?.toString() ?? ''),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        centerTitle: true,
        title: Text('Student App', style: TextStyle(fontSize: 25)),
        actions: [
          if (_currentUser != null)
            PopupMenuButton<String>(
              icon: Icon(Icons.account_circle),
              onSelected: (String result) {
                if (result == 'logout') {
                  _signOut(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  enabled: false,
                  child: Text(
                    'Logged in as:\n${_currentUser!.email}',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                  ),
                ),
              ],
            )
          else
            IconButton(
              icon: Icon(Icons.login),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 60),
              CircleAvatar(
                radius: 110,
                backgroundImage: AssetImage('assets/images/profileimg.jpg'),
                backgroundColor: Colors.grey,
              ),
              SizedBox(height: 40),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _rollController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.numbers, color: Colors.blue),
                  labelText: 'Roll Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter roll number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _branchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.school, color: Colors.blue),
                  labelText: 'Branch',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter branch';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _cgpaController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.grade, color: Colors.blue),
                  labelText: 'CGPA',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CGPA';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  double cgpa = double.parse(value);
                  if (cgpa < 0 || cgpa > 10) {
                    return 'CGPA must be between 0 and 10';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _createEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    ),
                    child: Text('Create', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: _showEntriesPopup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    ),
                    child: Text('Read', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateEntry();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    ),
                    child: Text('Update', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _deleteEntry();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    ),
                    child: Text('Delete', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        )
      )
    );
  }

  void _clearForm() {
    _nameController.clear();
    _rollController.clear();
    _branchController.clear();
    _cgpaController.clear();
    _formKey.currentState?.reset(); // Resets validation state
  }
  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _branchController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }
}