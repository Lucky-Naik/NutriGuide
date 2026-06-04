import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserIfNotExists(String uid, String email) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'name': '',
        'age': 0,
        'height': 0,
        'weight': 0,
        'bmi': 0,
        'profileCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'streakCount': 0,
        'lastOpenDate': FieldValue.serverTimestamp(),
        'isPremium': false,
      });
    }
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return UserModel.fromMap(uid, doc.data()!);
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(
          data,
          SetOptions(merge: true),
        );
  }

  // ✅ MOVED INSIDE CLASS
  Future<int> updateStreak(String uid) async {
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) return 0;

    final data = doc.data()!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? lastOpen;
    if (data['lastOpenDate'] != null) {
      lastOpen = (data['lastOpenDate'] as Timestamp).toDate();
      lastOpen = DateTime(lastOpen.year, lastOpen.month, lastOpen.day);
    }

    int streak = data['streakCount'] ?? 0;

    if (lastOpen == null) {
      streak = 1;
    } else {
      final difference = today.difference(lastOpen).inDays;

      if (difference == 1) {
        streak += 1;
      } else if (difference > 1) {
        streak = 1;
      }
    }

    await docRef.update({
      'streakCount': streak,
      'lastOpenDate': FieldValue.serverTimestamp(),
    });

    return streak;
  }

  Stream<UserModel?> userStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(uid, doc.data()!);
    });
  }
}
