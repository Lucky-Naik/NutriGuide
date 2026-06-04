import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class ReportService {
  Future<void> exportNutritionReport() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final mealsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('meals')
        .get();

    int calories = 0;
    int protein = 0;
    int carbs = 0;
    int fats = 0;

    String mealsList = "";

    for (var doc in mealsSnapshot.docs) {
      final data = doc.data();

      calories += (data['calories'] ?? 0) as int;
      protein += (data['protein'] ?? 0) as int;
      carbs += (data['carbs'] ?? 0) as int;
      fats += (data['fats'] ?? 0) as int;

      mealsList += "• ${data['foodName']} (${data['calories']} kcal)\n";
    }

    final now = DateTime.now();

    String report = """
🥗 NutriGuide Nutrition Report

📅 Date: ${now.day}/${now.month}/${now.year}

━━━━━━━━━━━━━━━━━━

🔥 Daily Nutrition Summary

Calories Consumed: $calories kcal

💪 Protein : $protein g
🍞 Carbs   : $carbs g
🥑 Fats    : $fats g

━━━━━━━━━━━━━━━━━━

🍽 Meals Logged Today

$mealsList

━━━━━━━━━━━━━━━━━━

📱 Generated from NutriGuide App
Track your meals. Improve your health 💚
""";

    await Share.share(report);
  }
}
