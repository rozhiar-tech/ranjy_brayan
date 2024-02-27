import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Screen'),
      ),
      body: UsersList(),
    );
  }
}

class UsersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        List<DocumentSnapshot> users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            String userName = users[index]['firstName'] ?? 'N/A';
            String userEmail = users[index]['email'] ?? 'N/A';

            return ListTile(
              title: Text(userName),
              subtitle: Text(userEmail),
              // Add a button or UI element to add credits to this user
              trailing: ElevatedButton(
                onPressed: () {
                  // Implement your logic to add credits to the selected user
                  // You can use showDialog or navigate to another screen for this
                  _showAddCreditsDialog(context, users[index].id);
                },
                child: const Text('Add Credits'),
              ),
            );
          },
        );
      },
    );
  }

  // Function to show a dialog for adding credits
  void _showAddCreditsDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController creditsController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Credits'),
          content: Column(
            children: [
              TextField(
                controller: creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter Credits'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Implement logic to add credits to the user in Firestore
                _addCreditsToUser(userId, creditsController.text);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Function to add credits to a user in Firestore
  void _addCreditsToUser(String userId, String credits) {
    // Implement your logic to update the user's credits in Firestore
    // You can use the userId to identify the user and update the 'credits' field
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'credit': FieldValue.increment(int.tryParse(credits) ?? 0),
    });
  }
}
