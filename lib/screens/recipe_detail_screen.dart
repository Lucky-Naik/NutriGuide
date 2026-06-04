import 'package:flutter/material.dart';
import '../models/dish_model.dart';
import '../services/meal_service.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Dish dish;

  const RecipeDetailScreen({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    final mealService = MealService();

    return Scaffold(
      appBar: AppBar(title: Text(dish.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Calories: ${dish.calories} kcal"),
              Text("Protein: ${dish.protein} g"),
              Text("Carbs: ${dish.carbs} g"),
              Text("Fats: ${dish.fats} g"),
              const SizedBox(height: 20),
              const Text("Ingredients",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...dish.ingredients.map((ing) => Text("• $ing")).toList(),
              const SizedBox(height: 20),
              const Text("Steps",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...dish.steps.map((step) => Text("• $step")).toList(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  await mealService.addMeal(
                    foodName: dish.name,
                    calories: dish.calories,
                    protein: dish.protein,
                    carbs: dish.carbs,
                    fats: dish.fats,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Added to Meal Plan Successfully")),
                  );

                  Navigator.pop(context);
                },
                child: const Text("Add to Meal Plan"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
