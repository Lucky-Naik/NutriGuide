class RecipeModel {
  final String id;
  final String name;
  final String category;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final List<String> ingredients;
  final List<String> steps;
  final String icon;
  final int color;
  final bool isPremium;

  RecipeModel({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.ingredients,
    required this.steps,
    required this.icon,
    required this.color,
    required this.isPremium,
  });

  factory RecipeModel.fromMap(String id, Map<String, dynamic> map) {
    return RecipeModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      calories: map['calories'] ?? 0,
      protein: map['protein'] ?? 0,
      carbs: map['carbs'] ?? 0,
      fats: map['fats'] ?? 0,
      ingredients: map['ingredients'] != null
          ? List<String>.from(map['ingredients'])
          : [],
      steps: map['steps'] != null ? List<String>.from(map['steps']) : [],
      icon: map['icon'] ?? 'restaurant',
      color: map['color'] ?? 0xFF4CAF50,
      isPremium: map['isPremium'] ?? false,
    );
  }
}
