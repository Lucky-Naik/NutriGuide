class Dish {
  final String name;
  final String category;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final List<String> ingredients;
  final List<String> steps;

  Dish({
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.ingredients,
    required this.steps,
  });
}
