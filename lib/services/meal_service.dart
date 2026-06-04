import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addMeal({
    required String foodName,
    required int calories,
    required int protein,
    required int carbs,
    required int fats,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userRef = _firestore.collection('users').doc(uid);
    final mealsRef = userRef.collection('meals');

    // 🔥 Add Meal First
    await mealsRef.add({
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 🔥 FAST COUNTERS (PERFORMANCE IMPROVEMENT)
    await userRef.set({
      'mealCount': FieldValue.increment(1),
      'weeklyMealCount': FieldValue.increment(1),
      'weeklyProtein': FieldValue.increment(protein),
      'xp': 0,
      'dailyXp': 0,
      'weeklyChallengeCompleted': false,
      'lastWeeklyReset': Timestamp.now(),
    }, SetOptions(merge: true));

    // 🔥 Fetch user
    final userSnapshot = await userRef.get();
    final userData = userSnapshot.data()!;

    // 🔥 WEEKLY RESET CHECK
    DateTime now = DateTime.now();

    DateTime startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    DateTime lastWeeklyReset =
        (userData['lastWeeklyReset'] as Timestamp?)?.toDate() ?? startOfWeek;

    DateTime lastResetWeek = DateTime(
            lastWeeklyReset.year, lastWeeklyReset.month, lastWeeklyReset.day)
        .subtract(Duration(days: lastWeeklyReset.weekday - 1));

    if (startOfWeek.isAfter(lastResetWeek)) {
      await userRef.update({
        'weeklyMealCount': 0,
        'weeklyProtein': 0,
        'weeklyChallengeCompleted': false,
        'lastWeeklyReset': Timestamp.fromDate(startOfWeek),
      });
    }

    int currentXp = userData['xp'] ?? 0;
    int dailyXp = userData['dailyXp'] ?? 0;
    int dailyTarget = userData['dailyCalorieTarget'] ?? 2000;

    // 🔥 DAILY RESET CHECK
    DateTime today = DateTime(now.year, now.month, now.day);

    DateTime lastOpen =
        (userData['lastOpenDate'] as Timestamp?)?.toDate() ?? today;

    DateTime lastOpenDate =
        DateTime(lastOpen.year, lastOpen.month, lastOpen.day);

    if (today.isAfter(lastOpenDate)) {
      await userRef.update({
        'dailyXp': 0,
        'lastOpenDate': Timestamp.fromDate(today),
      });

      dailyXp = 0;
    }

    // 🔥 Base XP
    int earnedXp = 10;

    // 🔥 Check today's meals
    final todayStart = DateTime(now.year, now.month, now.day);

    final todayMeals = await mealsRef
        .where('createdAt', isGreaterThanOrEqualTo: todayStart)
        .get();

    int totalCalories = 0;
    int totalProtein = 0;

    for (var doc in todayMeals.docs) {
      totalCalories += (doc['calories'] ?? 0) as int;
      totalProtein += (doc['protein'] ?? 0) as int;
    }

    // 🔥 Bonus XP Conditions
    if (totalCalories >= dailyTarget) {
      earnedXp += 20;
    }

    if (totalProtein >= 80) {
      earnedXp += 5;
    }

    // 🔥 WEEKLY CHALLENGE BONUS
    DateTime startOfWeekCheck = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final weeklyMealsSnapshot = await mealsRef
        .where('createdAt', isGreaterThanOrEqualTo: startOfWeekCheck)
        .get();

    int weeklyMealCount = weeklyMealsSnapshot.docs.length;
    int weeklyProtein = 0;

    for (var doc in weeklyMealsSnapshot.docs) {
      weeklyProtein += (doc['protein'] ?? 0) as int;
    }

    bool weeklyCompleted = weeklyMealCount >= 5 && weeklyProtein >= 500;

    bool alreadyCompleted = userData['weeklyChallengeCompleted'] ?? false;

    if (weeklyCompleted && !alreadyCompleted) {
      earnedXp += 50;

      await userRef.update({
        'weeklyChallengeCompleted': true,
      });
    }

    // 🔥 DAILY XP CAP SYSTEM
    const int dailyLimit = 100;

    if (dailyXp >= dailyLimit) {
      return;
    }

    int availableXp = dailyLimit - dailyXp;

    if (earnedXp > availableXp) {
      earnedXp = availableXp;
    }

    // 🔥 Update XP
    await userRef.update({
      'xp': currentXp + earnedXp,
      'dailyXp': dailyXp + earnedXp,
      'lastOpenDate': Timestamp.fromDate(today),
    });
  }

  Future<void> deleteMeal(String mealId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('meals')
        .doc(mealId)
        .delete();
  }
}
