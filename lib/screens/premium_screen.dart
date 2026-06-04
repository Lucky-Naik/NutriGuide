import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  Future<void> upgradeToPremium() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isPremium': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NutriGuide Premium")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.workspace_premium, size: 90, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              "Upgrade to Premium",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text("✔ Unlock premium recipes"),
            const Text("✔ Advanced nutrition insights"),
            const Text("✔ Export nutrition reports"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await upgradeToPremium();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Premium Activated!")),
                );

                Navigator.pop(context);
              },
              child: const Text("Upgrade Now"),
            ),
          ],
        ),
      ),
    );
  }
}
