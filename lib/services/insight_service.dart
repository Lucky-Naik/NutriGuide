class InsightService {
  static String generateInsight({
    required int calories,
    required int protein,
    required int targetCalories,
  }) {
    if (calories >= targetCalories) {
      return "Great job! You reached your calorie goal today.";
    }

    if (protein >= 80) {
      return "Nice! Your protein intake is excellent today.";
    }

    if (calories < targetCalories * 0.7) {
      return "You are under your calorie target. Consider adding a healthy meal.";
    }

    return "Keep tracking your meals to maintain a balanced diet.";
  }
}
