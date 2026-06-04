import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import 'package:flutter/services.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _controller = PageController();
  int _currentStep = 0;
  bool _loading = false;
  bool _isStepValid() {
    if (_currentStep == 0) {
      final name = _nameController.text.trim();
      final age = int.tryParse(_ageController.text.trim());

      return name.isNotEmpty && age != null && _gender != null;
    }

    if (_currentStep == 1) {
      final height = double.tryParse(_heightController.text.trim());
      final weight = double.tryParse(_weightController.text.trim());

      return height != null && weight != null;
    }

    if (_currentStep == 2) {
      return _goal != null;
    }

    if (_currentStep == 3) {
      return _activityLevel != null;
    }

    return false;
  }

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? _gender;
  String? _goal;
  String? _activityLevel;

  final int _totalSteps = 4;
  @override
  void initState() {
    super.initState();

    _nameController.addListener(() => setState(() {}));
    _ageController.addListener(() => setState(() {}));
    _heightController.addListener(() => setState(() {}));
    _weightController.addListener(() => setState(() {}));
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (name.isEmpty ||
        age == null ||
        height == null ||
        weight == null ||
        _gender == null ||
        _goal == null ||
        _activityLevel == null) {
      _showMessage("Please complete all fields");
      return;
    }

    setState(() => _loading = true);

    try {
      double bmr = (_gender == "Male")
          ? (10 * weight) + (6.25 * height) - (5 * age) + 5
          : (10 * weight) + (6.25 * height) - (5 * age) - 161;

      double activityMultiplier = switch (_activityLevel) {
        "Sedentary (Little or no exercise)" => 1.2,
        "Moderate (Exercise 3-5 days/week)" => 1.55,
        "Active (Daily exercise or intense activity)" => 1.725,
        _ => 1.2,
      };

      double dailyTarget = bmr * activityMultiplier;

      if (_goal == "Lose Weight") dailyTarget -= 300;
      if (_goal == "Gain Muscle") dailyTarget += 300;

      double proteinPercent;
      double carbPercent;
      double fatPercent;

      if (_goal == "Lose Weight") {
        proteinPercent = 0.35;
        carbPercent = 0.35;
        fatPercent = 0.30;
      } else if (_goal == "Gain Muscle") {
        proteinPercent = 0.30;
        carbPercent = 0.45;
        fatPercent = 0.25;
      } else {
        proteinPercent = 0.30;
        carbPercent = 0.40;
        fatPercent = 0.30;
      }

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await UserService().updateUserProfile(uid, {
        'name': name,
        'age': age,
        'gender': _gender,
        'height': height,
        'weight': weight,
        'goal': _goal,
        'activityLevel': _activityLevel,
        'dailyCalorieTarget': dailyTarget.round(),
        'macroProteinPercent': proteinPercent,
        'macroCarbPercent': carbPercent,
        'macroFatPercent': fatPercent,
        'profileCompleted': true,
      });

      if (!mounted) return;
      _showMessage("Profile completed successfully!");
    } catch (e) {
      _showMessage("Something went wrong. Please try again.");
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _progressIndicator() {
    double progress = (_currentStep + 1) / _totalSteps;

    return Column(
      children: [
        Text(
          "Step ${_currentStep + 1} of $_totalSteps",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(
      String value, String groupValue, Function(String) onSelect) {
    final bool isSelected = groupValue == value;

    return GestureDetector(
      onTap: () => onSelect(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4CAF50)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF2E7D32),
              Color(0xFF1B5E20),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _progressIndicator(),
              const SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentStep = index);
                  },
                  children: [
                    _buildCard(
                      Column(
                        children: [
                          _buildTextField(_nameController, "Name"),
                          const SizedBox(height: 15),
                          _buildTextField(_ageController, "Age",
                              isNumber: true),
                          const SizedBox(height: 15),
                          _buildOptionTile("Male", _gender ?? "",
                              (val) => setState(() => _gender = val)),
                          _buildOptionTile("Female", _gender ?? "",
                              (val) => setState(() => _gender = val)),
                        ],
                      ),
                    ),
                    _buildCard(
                      Column(
                        children: [
                          _buildTextField(_heightController, "Height (cm)",
                              isNumber: true),
                          const SizedBox(height: 15),
                          _buildTextField(_weightController, "Weight (kg)",
                              isNumber: true),
                        ],
                      ),
                    ),
                    _buildCard(
                      Column(
                        children: [
                          Text(
                            "Select Your Goal",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildOptionTile("Lose Weight", _goal ?? "",
                              (val) => setState(() => _goal = val)),
                          _buildOptionTile("Maintain", _goal ?? "",
                              (val) => setState(() => _goal = val)),
                          _buildOptionTile("Gain Muscle", _goal ?? "",
                              (val) => setState(() => _goal = val)),
                        ],
                      ),
                    ),
                    _buildCard(
                      Column(
                        children: [
                          Text(
                            "Select Activity Level",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildOptionTile(
                              "Sedentary (Little or no exercise)",
                              _activityLevel ?? "",
                              (val) => setState(() => _activityLevel = val)),
                          _buildOptionTile(
                              "Moderate (Exercise 3-5 days/week)",
                              _activityLevel ?? "",
                              (val) => setState(() => _activityLevel = val)),
                          _buildOptionTile(
                              "Active (Daily exercise or intense activity)",
                              _activityLevel ?? "",
                              (val) => setState(() => _activityLevel = val)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Back"),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 10),
                    Expanded(
                      child: _loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF2E7D32),
                              ),
                              onPressed: _isStepValid() ? _nextStep : null,
                              child: Text(
                                _currentStep == _totalSteps - 1
                                    ? "Finish Setup"
                                    : "Next",
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: child,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters:
          isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFF4CAF50),
            width: 2,
          ),
        ),
      ),
    );
  }
}
