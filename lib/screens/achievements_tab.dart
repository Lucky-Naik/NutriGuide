import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:confetti/confetti.dart';

class AchievementsTab extends StatefulWidget {
  const AchievementsTab({super.key});

  @override
  State<AchievementsTab> createState() => _AchievementsTabState();
}

class _AchievementsTabState extends State<AchievementsTab> {
  UserModel? _user;
  bool _loading = true;
  int _previousLevel = 0;
  bool _firstLoad = true;
  bool _firstBadgeLoad = true;
  int _previousXp = 0;
  bool _firstXpLoad = true;
  bool _showXpAnimation = false;
  int _earnedXp = 0;
  late ConfettiController _confettiController;
  bool get isPremium => _user?.isPremium ?? false;
  late StreamSubscription<DocumentSnapshot> _userSubscription;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  void _loadUser() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final user = UserModel.fromMap(uid, data);

      // FIXED HERE
      if (user.weeklyChallengeCompleted) {
        _showWeeklyPopup();
      }

      if (!_firstXpLoad && user.xp > _previousXp) {
        _earnedXp = user.xp - _previousXp;
        _triggerXpAnimation();
      }

      _previousXp = user.xp;
      _firstXpLoad = false;

      final currentLevel = (user.xp ~/ 100) + 1;

      _checkBadgeUnlock(user.streakCount);

      if (!_firstLoad && currentLevel > _previousLevel) {
        _showLevelUpDialog(currentLevel);
      }

      _previousLevel = currentLevel;
      _firstLoad = false;

      setState(() {
        _user = user;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final int xp = _user!.xp;
    final int level = (xp ~/ 100) + 1;
    final double progress = (xp % 100) / 100;
    final int streak = _user!.streakCount;

    return Scaffold(
      appBar: AppBar(title: const Text("Achievements")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🔥 PREMIUM CARD GOES HERE
                if (!_user!.isPremium) _buildPremiumCard(),

                _buildXpCard(level, xp, progress),
                const SizedBox(height: 30),

                _buildWeeklyChallenge(),

                _buildBadgeSection(streak),

                isPremium ? _buildPremiumFeature() : _buildPremiumLockedCard(),
              ],
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.purple,
                Colors.orange,
                Colors.amber,
              ],
            ),
          ),

          // 🔥 Floating XP Animation
          if (_showXpAnimation)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: 1 - value,
                    child: Transform.translate(
                      offset: Offset(0, -50 * value),
                      child: Center(
                        child: Text(
                          "+$_earnedXp XP",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildXpCard(int level, int xp, double progress) {
    final int xpToNext = 100 - (xp % 100);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6A11CB),
            Color(0xFF2575FC),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Text(
            "Level $level",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // 🔥 Circular XP Ring
          SizedBox(
            height: 140,
            width: 140,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 900),
              builder: (context, value, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10,
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$xp XP",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$xpToNext XP left",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeSection(int streak) {
    final badges = _user!.badges ?? [];
    final int xp = _user!.xp;

    if (badges.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Achievements 🏆",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ...badges.map((badge) {
          double progress = 0;
          String subtitle = "";

          if (badge == "Starter") {
            progress = (streak / 3).clamp(0, 1);
            subtitle = "$streak / 3 Days";
          } else if (badge == "Consistent") {
            progress = (streak / 7).clamp(0, 1);
            subtitle = "$streak / 7 Days";
          } else if (badge == "Dedicated") {
            progress = (xp / 500).clamp(0, 1);
            subtitle = "$xp / 500 XP";
          } else if (badge == "Macro Master") {
            progress = (xp / 1000).clamp(0, 1);
            subtitle = "$xp / 1000 XP";
          }

          bool completed = progress >= 1;

          return Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: completed
                  ? Colors.green.withOpacity(0.1)
                  : Colors.amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      badge,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      completed ? Icons.check_circle : Icons.lock_outline,
                      color: completed ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                  color: completed ? Colors.green : Colors.amber,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showLevelUpDialog(int level) {
    _confettiController.play();
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.7, end: 1),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFFA000),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "LEVEL UP!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You reached Level $level 🎉",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Awesome!",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _checkBadgeUnlock(int streak) async {
    if (_user == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    List<String> savedBadges = List<String>.from(_user!.badges ?? []);

    Map<String, bool> achievementChecks = {
      // 🔹 Free Achievements
      "3 Day Streak": streak >= 3,
      "7 Day Streak": streak >= 7,
      "30 Day Streak": streak >= 30,
      "XP 100 Club": _user!.xp >= 100,
      "XP 500 Club": _user!.xp >= 500,

      // 🔥 Premium Achievements
      if (_user!.isPremium) "Elite 60 Day Streak": streak >= 60,
      if (_user!.isPremium) "XP 1000 Master": _user!.xp >= 1000,
      if (_user!.isPremium)
        "Macro Legend": _user!.macroProteinPercent == 0.30 &&
            _user!.macroCarbPercent == 0.40 &&
            _user!.macroFatPercent == 0.30,
    };

    for (var entry in achievementChecks.entries) {
      if (entry.value && !savedBadges.contains(entry.key)) {
        await userRef.update({
          "badges": FieldValue.arrayUnion([entry.key])
        });

        if (!_firstBadgeLoad) {
          _showBadgeUnlockDialog(entry.key);
        }
      }
    }

    _firstBadgeLoad = false;
  }

  void _showBadgeUnlockDialog(String badgeTitle) {
    _confettiController.play();
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.7, end: 1),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "BADGE UNLOCKED!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badgeTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Nice!",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _triggerXpAnimation() {
    setState(() {
      _showXpAnimation = true;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _showXpAnimation = false;
        });
      }
    });
  }

  Widget _buildPremiumCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white, size: 35),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              "Upgrade to Premium 🚀\nUnlock exclusive achievements",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            onPressed: _activatePremium,
            child: const Text(
              "Activate",
              style: TextStyle(color: Colors.black),
            ),
          ),
          if (_user!.isPremium)
            ElevatedButton(
              onPressed: _togglePremiumTheme,
              child: const Text("Toggle Premium Theme"),
            ),
        ],
      ),
    );
  }

  void _togglePremiumTheme() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'premiumTheme': true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Premium Theme Activated 💎")),
    );
  }

  void _activatePremium() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'isPremium': true});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Premium Activated (Mock) 🎉")),
    );
  }

  Widget _buildWeeklyChallenge() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('meals')
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final meals = snapshot.data!.docs;

        int mealCount = meals.length;
        int proteinTotal = 0;

        for (var meal in meals) {
          proteinTotal += (meal['protein'] ?? 0) as int;
        }

        bool mealDone = mealCount >= 5;
        bool proteinDone = proteinTotal >= 500;

        return Container(
          margin: const EdgeInsets.only(top: 30),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Weekly Challenge 🔥",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text("5 Meals: ${mealDone ? "Completed ✅" : "$mealCount / 5"}"),
              Text(
                  "500g Protein: ${proteinDone ? "Completed ✅" : "$proteinTotal / 500"}"),
            ],
          ),
        );
      },
    );
  }

  void _showWeeklyPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Weekly Challenge Completed 🎉"),
          content: const Text(
            "You completed this week's challenge!\n+50 XP earned 🚀",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Awesome!"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPremiumFeature() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: const [
          Icon(Icons.workspace_premium, size: 40, color: Colors.amber),
          SizedBox(height: 10),
          Text(
            "Premium Activated 💎",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text("You have access to all premium features."),
        ],
      ),
    );
  }

  Widget _buildPremiumLockedCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: const [
          Icon(Icons.lock, size: 40),
          SizedBox(height: 10),
          Text(
            "Premium Feature 🔒",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text("Upgrade to unlock this feature."),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _userSubscription.cancel();
    super.dispose();
  }
}
