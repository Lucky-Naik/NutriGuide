import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final int age;
  final double height;
  final double weight;
  final double bmi;
  final bool profileCompleted;
  final int streakCount;
  final DateTime? lastOpenDate;
  final int dailyCalorieTarget;
  final double macroProteinPercent;
  final double macroCarbPercent;
  final double macroFatPercent;
  final int xp;
  final DateTime? lastBonusDate;
  final int lastLevel;
  final List<String>? badges;
  final bool isPremium;
  final int dailyXp;
  final int weeklyChallengeXp;
  final bool weeklyChallengeCompleted;
  double get calculatedBmi {
    if (height <= 0 || weight <= 0) return 0;

    final heightMeter = height / 100;
    return weight / (heightMeter * heightMeter);
  }

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.profileCompleted,
    required this.streakCount,
    required this.lastOpenDate,
    required this.dailyCalorieTarget,
    required this.macroProteinPercent,
    required this.macroCarbPercent,
    required this.macroFatPercent,
    required this.xp,
    required this.lastBonusDate,
    required this.lastLevel,
    required this.badges,
    required this.isPremium,
    required this.dailyXp,
    required this.weeklyChallengeXp,
    required this.weeklyChallengeCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'profileCompleted': profileCompleted,
      'streakCount': streakCount,
      'lastOpenDate': lastOpenDate,
      'xp': xp,
      'lastBonusDate': lastBonusDate,
      'lastLevel': lastLevel,
      'badges': badges ?? [],
      'isPremium': isPremium,
      'dailyXp': dailyXp,
      'weeklyChallengeXp': weeklyChallengeXp,
      'weeklyChallengeCompleted': weeklyChallengeCompleted,
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      height: (map['height'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      bmi: (map['bmi'] ?? 0).toDouble(),
      profileCompleted: map['profileCompleted'] ?? false,
      streakCount: map['streakCount'] ?? 0,
      lastOpenDate: map['lastOpenDate'] != null
          ? (map['lastOpenDate'] as Timestamp).toDate()
          : null,
      dailyCalorieTarget: map['dailyCalorieTarget'] ?? 2000,
      macroProteinPercent: (map['macroProteinPercent'] ?? 0.30).toDouble(),
      macroCarbPercent: (map['macroCarbPercent'] ?? 0.40).toDouble(),
      macroFatPercent: (map['macroFatPercent'] ?? 0.30).toDouble(),
      xp: map['xp'] ?? 0,
      lastBonusDate: map['lastBonusDate'] != null
          ? (map['lastBonusDate'] as Timestamp).toDate()
          : null,
      lastLevel: map['lastLevel'] ?? 1,
      badges: map['badges'] != null ? List<String>.from(map['badges']) : [],
      isPremium: map['isPremium'] ?? false,
      dailyXp: map['dailyXp'] ?? 0,
      weeklyChallengeXp: map['weeklyChallengeXp'] ?? 0,
      weeklyChallengeCompleted: map['weeklyChallengeCompleted'] ?? false,
    );
  }
}
