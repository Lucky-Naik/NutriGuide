import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<RecipeModel>> getRecipes() {
    return _firestore.collection('recipies').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return RecipeModel.fromMap(
            doc.id,
            doc.data(),
          );
        }).toList();
      },
    );
  }
}
