import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/calorie_ring.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  UserModel? _user;
  bool _loading = true;
  int _dailyCalories = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final user = UserModel.fromMap(uid, data);
      _updateStreak(user);

      setState(() {
        _user = user;
        _streak = user.streakCount;
        _dailyCalories = user.dailyCalorieTarget;
        _loading = false;
      });
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('meals')
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              ),
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final meals = snapshot.data!.docs;

          int totalCalories = 0;
          int totalProtein = 0;
          int totalCarbs = 0;
          int totalFats = 0;

          for (var meal in meals) {
            totalCalories += (meal['calories'] ?? 0) as int;
            totalProtein += (meal['protein'] ?? 0) as int;
            totalCarbs += (meal['carbs'] ?? 0) as int;
            totalFats += (meal['fats'] ?? 0) as int;
          }

          int proteinTarget =
              ((_dailyCalories * (_user?.macroProteinPercent ?? 0.30)) / 4)
                  .round();

          int carbsTarget =
              ((_dailyCalories * (_user?.macroCarbPercent ?? 0.40)) / 4)
                  .round();

          int fatsTarget =
              ((_dailyCalories * (_user?.macroFatPercent ?? 0.30)) / 9).round();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 GREETING
                Text(
                  "${_getGreeting()},",
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  _user?.name ?? "",
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                // 🔥 CALORIE RING
                Center(
                  child: CalorieRing(
                    consumed: totalCalories.toDouble(),
                    target: _dailyCalories.toDouble(),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Remaining Today",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${(_dailyCalories - totalCalories).clamp(0, _dailyCalories)} kcal",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 🔥 MACROS
                _macroProgress(
                    "Protein", totalProtein, proteinTarget, Colors.blue),
                _macroProgress("Carbs", totalCarbs, carbsTarget, Colors.orange),
                _macroProgress("Fats", totalFats, fatsTarget, Colors.green),

                _buildSmartInsight(
                  totalCalories,
                  totalProtein,
                  totalCarbs,
                  totalFats,
                  _dailyCalories,
                ),

                _buildWeeklyComparisonCard(),

                const SizedBox(height: 20),

                _buildAchievementCard(),

                const SizedBox(height: 20),

                _buildBmiCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- KEEP ALL YOUR EXISTING HELPER METHODS BELOW ----------

  Widget _buildAchievementCard() {
    String? title;
    String? subtitle;
    IconData? icon;
    Color? color;

    if (_streak >= 30) {
      title = "Elite Commitment!";
      subtitle = "30 Day Streak Champion 🏆";
      icon = Icons.workspace_premium;
      color = Colors.purple;
    } else if (_streak >= 14) {
      title = "Gold Discipline!";
      subtitle = "14 Day Consistency 🥇";
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else if (_streak >= 7) {
      title = "Silver Consistency!";
      subtitle = "7 Day Streak 🥈";
      icon = Icons.emoji_events;
      color = Colors.grey;
    } else if (_streak >= 3) {
      title = "Bronze Starter!";
      subtitle = "3 Day Streak 🥉";
      icon = Icons.star;
      color = Colors.brown;
    }

    if (title == null) return const SizedBox();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(subtitle ?? ""),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroProgress(
    String title,
    int value,
    int goal,
    Color color,
  ) {
    final percent = goal == 0 ? 0.0 : value / goal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(
                "${goal == 0 ? 0 : ((value / goal) * 100).toInt()}%",
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percent > 1 ? 1 : percent,
            color: color,
            backgroundColor: Colors.grey.shade300,
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildBmiCard() {
    final bmi = _user?.calculatedBmi ?? 0;

    String bmiStatus = "";
    Color bmiColor = Colors.green;

    if (bmi < 18.5) {
      bmiStatus = "Underweight";
      bmiColor = Colors.blue;
    } else if (bmi < 25) {
      bmiStatus = "Normal";
      bmiColor = Colors.green;
    } else if (bmi < 30) {
      bmiStatus = "Overweight";
      bmiColor = Colors.orange;
    } else {
      bmiStatus = "Obese";
      bmiColor = Colors.red;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bmiColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_weight, color: bmiColor),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your BMI",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    bmiStatus,
                    style: TextStyle(
                      color: bmiColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            bmi.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: bmiColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsight(
    int calories,
    int protein,
    int carbs,
    int fats,
    int calorieTarget,
  ) {
    String message = "";
    IconData icon = Icons.insights;
    Color color = Colors.green;

    if (calories == 0) {
      message = "Start your day strong 💪 Add your first meal!";
      color = Colors.grey;
    } else if (calories < calorieTarget * 0.4) {
      message =
          "You're under your calorie goal. Make sure you're eating enough 🍽️";
      color = Colors.orange;
    } else if (calories > calorieTarget) {
      message = "You've exceeded your calorie goal ⚠️ Consider lighter meals.";
      color = Colors.red;
    } else if (protein < 50) {
      message = "Increase protein intake for better muscle support 🥩";
      color = Colors.blue;
    } else {
      message = "Great job! You're on track today 👏";
      color = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(top: 25),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyComparisonCard() {
    return FutureBuilder<Map<String, double>>(
      future: _getWeeklyComparison(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final thisWeek = snapshot.data!["thisWeek"]!;
        final lastWeek = snapshot.data!["lastWeek"]!;

        if (lastWeek == 0) return const SizedBox();

        final percentChange = ((thisWeek - lastWeek) / lastWeek * 100);

        final improved = percentChange < 0;

        return Container(
          margin: const EdgeInsets.only(top: 25),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: improved
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                improved ? Icons.trending_down : Icons.trending_up,
                color: improved ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  improved
                      ? "You consumed ${percentChange.abs().toStringAsFixed(1)}% fewer calories than last week 👏"
                      : "You consumed ${percentChange.toStringAsFixed(1)}% more calories than last week ⚠️",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, double>> _getWeeklyComparison() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    DateTime now = DateTime.now();

    DateTime startThisWeek = DateTime(now.year, now.month, now.day).subtract(
      Duration(days: now.weekday - 1),
    );

    DateTime startLastWeek = startThisWeek.subtract(const Duration(days: 7));
    DateTime endLastWeek = startThisWeek.subtract(const Duration(seconds: 1));

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('meals');

    final thisWeekSnapshot = await collection
        .where('createdAt', isGreaterThanOrEqualTo: startThisWeek)
        .get();

    final lastWeekSnapshot = await collection
        .where('createdAt',
            isGreaterThanOrEqualTo: startLastWeek,
            isLessThanOrEqualTo: endLastWeek)
        .get();

    double thisWeek = 0;
    double lastWeek = 0;

    for (var doc in thisWeekSnapshot.docs) {
      thisWeek += (doc['calories'] ?? 0) as int;
    }

    for (var doc in lastWeekSnapshot.docs) {
      lastWeek += (doc['calories'] ?? 0) as int;
    }

    return {
      "thisWeek": thisWeek,
      "lastWeek": lastWeek,
    };
  }

  Future<void> _updateStreak(UserModel user) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    DateTime? lastOpen = user.lastOpenDate != null
        ? DateTime(
            user.lastOpenDate!.year,
            user.lastOpenDate!.month,
            user.lastOpenDate!.day,
          )
        : null;

    int newStreak = user.streakCount;

    if (lastOpen == null) {
      newStreak = 1;
    } else {
      final difference = todayDate.difference(lastOpen).inDays;

      if (difference == 1) {
        newStreak += 1;
      } else if (difference > 1) {
        newStreak = 1;
      }
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'streakCount': newStreak,
      'lastOpenDate': todayDate,
    });
  }
}
