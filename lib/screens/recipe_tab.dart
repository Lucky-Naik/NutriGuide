import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/meal_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'premium_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeTab extends StatefulWidget {
  const RecipeTab({super.key});

  @override
  State<RecipeTab> createState() => _RecipeTabState();
}

class _RecipeTabState extends State<RecipeTab> with TickerProviderStateMixin {
  String selectedCategory = "Breakfast";

  final List<String> categories = ["Breakfast", "Lunch", "Dinner", "Snacks"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recipes")),
      body: Column(
        children: [
          // Category Chips
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF4CAF50),
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Recipes Stream
          Expanded(
            child: StreamBuilder<List<RecipeModel>>(
              stream: FirebaseFirestore.instance
                  .collection('recipies')
                  .where('category', isEqualTo: selectedCategory)
                  .snapshots()
                  .map((snapshot) => snapshot.docs
                      .map((doc) => RecipeModel.fromMap(doc.id, doc.data()))
                      .toList()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text("No recipes found"));
                }

                final recipes = snapshot.data!;
                print("FILTERED LENGTH: ${recipes.length}");

                if (recipes.isEmpty) {
                  return const Center(child: Text("No recipes found"));
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: recipes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];

                      final iconData = _getIcon(recipe.icon);
                      final cardColor = Color(recipe.color);

                      return GestureDetector(
                        onTap: () => _handleRecipeTap(recipe),
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: cardColor.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      iconData,
                                      size: 34,
                                      color: cardColor,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    recipe.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${recipe.calories} kcal",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _macroChip(
                                          "P", recipe.protein, Colors.blue),
                                      _macroChip(
                                          "C", recipe.carbs, Colors.orange),
                                      _macroChip(
                                          "F", recipe.fats, Colors.green),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (recipe.isPremium)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.lock,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case "restaurant":
        return Icons.restaurant;
      case "breakfast_dining":
        return Icons.breakfast_dining;
      case "local_drink":
        return Icons.local_drink;
      case "egg":
        return Icons.egg;
      case "bakery_dining":
        return Icons.bakery_dining;
      case "icecream":
        return Icons.icecream;
      case "rice_bowl":
        return Icons.rice_bowl;
      case "dinner_dining":
        return Icons.dinner_dining;
      case "ramen_dining":
        return Icons.ramen_dining;
      case "lunch_dining":
        return Icons.lunch_dining;
      case "spa":
        return Icons.spa;
      case "eco":
        return Icons.eco;
      case "set_meal":
        return Icons.set_meal;
      default:
        return Icons.restaurant_menu;
    }
  }

  Widget _macroChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "$label ${value}g",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _handleRecipeTap(RecipeModel recipe) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    bool isPremiumUser = userDoc.data()?['isPremium'] ?? false;

    if (recipe.isPremium && !isPremiumUser) {
      _showPremiumDialog();
      return;
    }

    _showRecipeSheet(recipe);
  }

  void _showRecipeSheet(RecipeModel recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text("Calories: ${recipe.calories} kcal"),
                Text("Protein: ${recipe.protein} g"),
                Text("Carbs: ${recipe.carbs} g"),
                Text("Fats: ${recipe.fats} g"),
                const SizedBox(height: 20),
                const Text(
                  "Ingredients",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...recipe.ingredients.map(
                  (ing) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text("• $ing"),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Preparation Steps",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...recipe.steps.map(
                  (step) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text("• $step"),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await MealService().addMeal(
                        foodName: recipe.name,
                        calories: recipe.calories,
                        protein: recipe.protein,
                        carbs: recipe.carbs,
                        fats: recipe.fats,
                      );

                      Navigator.pop(context);

                      _showSuccessDialog(recipe.name);
                    },
                    child: const Text("Add to Meal Plan"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(String mealName) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween(begin: 0.8, end: 1),
            curve: Curves.easeOutBack,
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 70,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Meal Added!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$mealName added to your meal plan successfully 🎉",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Premium Recipe 🔒"),
          content: const Text(
            "This recipe is available for Premium users.\n\nUpgrade to unlock exclusive recipes and advanced nutrition features.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PremiumScreen(),
                  ),
                );
              },
              child: const Text("Upgrade"),
            ),
          ],
        );
      },
    );
  }
}
