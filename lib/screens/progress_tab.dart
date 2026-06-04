import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/empty_state.dart';
import '../services/user_service.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  int totalCalories = 0;
  int totalProtein = 0;
  int totalCarbs = 0;
  int totalFats = 0;
  int _lastLevel = 1;
  int userXp = 0;
  int userStreak = 0;

  String weeklyInsight = "";
  int dailyCalorieTarget = 2000;
  String selectedFilter = "Today";

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('meals');

    if (selectedFilter == "Today") {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      query = query
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('createdAt', isLessThanOrEqualTo: endOfDay);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Progress")),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyState(
              title: "No Data Available",
              subtitle: "Start tracking your meals to see progress here.",
              icon: Icons.bar_chart,
            );
          }

          final meals = snapshot.data!.docs;

          totalCalories = 0;
          totalProtein = 0;
          totalCarbs = 0;
          totalFats = 0;

          for (var doc in meals) {
            totalCalories += (doc['calories'] ?? 0) as int;
            totalProtein += (doc['protein'] ?? 0) as int;
            totalCarbs += (doc['carbs'] ?? 0) as int;
            totalFats += (doc['fats'] ?? 0) as int;
          }
          _checkDailyBonus(uid);

          _checkLevelUp(uid);

          _generateWeeklyInsight();

          return FutureBuilder(
            future: UserService().getUser(uid),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final user = userSnapshot.data;
              userXp = user?.xp ?? 0;
              final currentLevel = (userXp ~/ 100) + 1;

              if (currentLevel > _lastLevel) {
                _lastLevel = currentLevel;
                Future.delayed(const Duration(milliseconds: 300), () {
                  _showLevelUpDialog(currentLevel);
                });
              }
              userStreak = user?.streakCount ?? 0;
              dailyCalorieTarget = user?.dailyCalorieTarget ?? 2000;

              return _buildProgressUI(meals.length);
            },
          );
        },
      ),
    );
  }

  Widget _buildProgressUI(int mealCount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _filterSelector(),
          const SizedBox(height: 20),

          _buildLevelCard(userXp),

          const SizedBox(height: 20),
          _totalCaloriesCard(),
          const SizedBox(height: 20),
          _macroCard(),
          const SizedBox(height: 20),
          _pieChartCard(),
          const SizedBox(height: 20),
          _insightCard(),
          const SizedBox(height: 25),

          const SizedBox(height: 25),
          _buildBadgeSection(),

          // ✅ ACHIEVEMENTS PROPERLY PLACED
          _buildAchievementSection(userXp, userStreak, mealCount),
        ],
      ),
    );
  }

  Widget _filterSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _filterButton("Today"),
          _filterButton("All Time"),
        ],
      ),
    );
  }

  Widget _totalCaloriesCard() {
    return _cardWrapper(
      child: Column(
        children: [
          const Text("Total Calories",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            "$totalCalories kcal",
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _macroCard() {
    return _cardWrapper(
      child: Column(
        children: [
          const Text("Macronutrient Breakdown",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _macroRow("Protein", totalProtein, Colors.blue),
          _macroRow("Carbs", totalCarbs, Colors.orange),
          _macroRow("Fats", totalFats, Colors.green),
        ],
      ),
    );
  }

  Widget _pieChartCard() {
    return _cardWrapper(
      child: SizedBox(
        height: 250,
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                  value: totalProtein.toDouble(),
                  title: "Protein",
                  color: Colors.blue),
              PieChartSectionData(
                  value: totalCarbs.toDouble(),
                  title: "Carbs",
                  color: Colors.orange),
              PieChartSectionData(
                  value: totalFats.toDouble(),
                  title: "Fats",
                  color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _insightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.insights, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              weeklyInsight,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardWrapper({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _macroRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            "$value g",
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _generateWeeklyInsight() {
    if (totalCalories == 0) {
      weeklyInsight = "No data available.";
      return;
    }

    if (totalCalories < dailyCalorieTarget * 5) {
      weeklyInsight = "Excellent control! You're maintaining healthy intake 👏";
    } else if (totalCalories < dailyCalorieTarget * 7) {
      weeklyInsight =
          "Good consistency! Try balancing macros slightly better 💪";
    } else {
      weeklyInsight =
          "You're exceeding your calorie goal. Adjust portion sizes ⚠️";
    }
  }

  Widget _filterButton(String label) {
    final bool isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementSection(int xp, int streak, int mealCount) {
    List<String> badges = [];

    if (mealCount >= 10) badges.add("Starter");
    if (streak >= 7) badges.add("Consistent");
    if ((xp ~/ 100) + 1 >= 5) badges.add("Dedicated");
    if (mealCount >= 50) badges.add("Macro Master");

    if (badges.isEmpty) return const SizedBox();

    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Achievements 🏆",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: badges.map((badge) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(int xp) {
    final int level = (xp ~/ 100) + 1;
    final double progress = (xp % 100) / 100;
    final int xpToNext = 100 - (xp % 100);

    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Level $level",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey.shade300,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          Text(
            "$xpToNext XP to next level",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelUpDialog(int level) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0.7, end: 1),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    size: 80,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Level $level Unlocked!",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "You're leveling up your consistency 🚀",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Awesome!"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkDailyBonus(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final data = userDoc.data();
    if (data == null) return;

    final int xp = data['xp'] ?? 0;
    final int target = data['dailyCalorieTarget'] ?? 2000;
    final Timestamp? lastBonusTimestamp = data['lastBonusDate'];

    final DateTime today = DateTime.now();
    DateTime? lastBonusDate =
        lastBonusTimestamp != null ? lastBonusTimestamp.toDate() : null;

    bool alreadyGivenToday = lastBonusDate != null &&
        lastBonusDate.year == today.year &&
        lastBonusDate.month == today.month &&
        lastBonusDate.day == today.day;

    if (totalCalories >= target && !alreadyGivenToday) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'xp': xp + 50,
        'lastBonusDate': FieldValue.serverTimestamp(),
      });

      _showBonusPopup();
    }
  }

  void _showBonusPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Bonus XP Earned!"),
        content: const Text(
            "Congratulations! You completed your daily calorie goal.\n\n+50 XP awarded!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Awesome!"),
          )
        ],
      ),
    );
  }

  Future<void> _checkLevelUp(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final data = userDoc.data();
    if (data == null) return;

    int xp = data['xp'] ?? 0;
    int lastLevel = data['lastLevel'] ?? 1;

    int currentLevel = (xp ~/ 100) + 1;

    if (currentLevel > lastLevel) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'lastLevel': currentLevel,
      });

      _showLevelUpPopup(currentLevel);
    }
  }

  void _showLevelUpPopup(int level) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.7, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events,
                        color: Colors.white, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      "LEVEL UP!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "You reached Level $level 🎉",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Continue"),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBadgeSection() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final int xp = data['xp'] ?? 0;
        final int streak = data['streakCount'] ?? 0;
        final int level = (xp ~/ 100) + 1;

        List<Widget> badges = [];

        if (level >= 2) {
          badges.add(_badgeCard("Rising Star", Icons.star, Colors.blue));
        }

        if (streak >= 7) {
          badges.add(_badgeCard(
              "7-Day Streak", Icons.local_fire_department, Colors.orange));
        }

        if (xp >= 300) {
          badges.add(
              _badgeCard("Dedicated", Icons.workspace_premium, Colors.purple));
        }

        if (xp >= 500) {
          badges.add(
              _badgeCard("Macro Master", Icons.emoji_events, Colors.amber));
        }

        if (badges.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Achievements 🏆",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: badges,
            ),
          ],
        );
      },
    );
  }

  Widget _badgeCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
