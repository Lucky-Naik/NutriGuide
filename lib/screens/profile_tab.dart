import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../widgets/calorie_ring.dart';
import '../services/report_service.dart';
import '../services/notification_service.dart';

class ProfileTab extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const ProfileTab({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  UserModel? _user;
  bool _loading = true;
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final user = await UserService().getUser(uid);

    if (!mounted) return;

    setState(() {
      _user = user;
      _nameController.text = user?.name ?? "";
      _ageController.text = user?.age.toString() ?? "";
      _heightController.text = user?.height.toString() ?? "";
      _weightController.text = user?.weight.toString() ?? "";
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (name.isEmpty || age == null || height == null || weight == null) {
      _showMessage("Please enter valid values");
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await UserService().updateUserProfile(uid, {
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'profileCompleted': true,
    });

    setState(() {
      _isEditing = false;
    });

    _loadUser();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _logout() async {
    await AuthService().logout();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// PROFILE HEADER
              _buildProfileHeader(),

              const SizedBox(height: 25),

              /// USER INFO SECTION
              Row(
                children: const [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "User Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _buildInfoCard(),
              const SizedBox(height: 15),
              _buildBmiCard(),

              const SizedBox(height: 25),

              /// HEALTH STATS
              Row(
                children: const [
                  Icon(Icons.monitor_heart, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Health Stats",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _buildStreakCard(),
              const SizedBox(height: 15),
              _buildGoalCard(),
              const SizedBox(height: 15),

              /// TOOLS
              Row(
                children: const [
                  Icon(Icons.build, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Tools",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Export Nutrition Report"),
                onPressed: () async {
                  await ReportService().exportNutritionReport();
                },
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.notifications),
                label: const Text("Test Notification"),
                onPressed: () {
                  _showNotificationOptions();
                },
              ),

              const SizedBox(height: 25),

              /// SETTINGS
              Row(
                children: const [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Account",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _buildSettingsCard(),

              const SizedBox(height: 20),

              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text("Save Changes"),
                  ),
                ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: _logout,
                  child: const Text("Logout"),
                ),
              ),

              const SizedBox(height: 20),
            ],
          )),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Theme.of(context).cardColor,
            child: Text(
              _nameController.text.isNotEmpty
                  ? _nameController.text[0].toUpperCase()
                  : "U",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _nameController.text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _user?.email ?? "",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _cardWrapper(
      Column(
        children: [
          _buildField("Name", _nameController, _isEditing),
          _buildField("Age", _ageController, _isEditing, isNumber: true),
          _buildField("Height (cm)", _heightController, _isEditing,
              isNumber: true),
          _buildField("Weight (kg)", _weightController, _isEditing,
              isNumber: true),
        ],
      ),
    );
  }

  Widget _buildBmiCard() {
    final bmi = _user?.calculatedBmi ?? 0.0;

    return _cardWrapper(
      Column(
        children: [
          const Text(
            "Body Mass Index (BMI)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            bmi.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    final streak = _user?.streakCount ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.orange.shade900.withOpacity(0.3)
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department,
              color: Colors.orange, size: 32),
          const SizedBox(width: 12),
          Text(
            "$streak Day Streak 🔥",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    return _cardWrapper(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your Goal",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Daily Target: ${_user?.dailyCalorieTarget ?? 0} kcal"),
        ],
      ),
    );
  }

  Widget _buildCalorieRingCard() {
    return _cardWrapper(
      Column(
        children: [
          const Text("Daily Progress",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          CalorieRing(
            consumed: 0.0,
            target: (_user?.dailyCalorieTarget ?? 2000).toDouble(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return _cardWrapper(
      Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text("Change Theme"),
            trailing: DropdownButton<ThemeMode>(
              value: ThemeMode.system,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text("Light"),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text("Dark"),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text("System"),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  widget.onThemeChanged(mode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController controller, bool editable,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      enabled: editable,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _cardWrapper(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }

  void _showNotificationOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Set Meal Reminder",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.wb_sunny),
                title: const Text("Breakfast Reminder"),
                onTap: () {
                  NotificationService.scheduleMealReminder(8, 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.lunch_dining),
                title: const Text("Lunch Reminder"),
                onTap: () {
                  NotificationService.scheduleMealReminder(13, 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dinner_dining),
                title: const Text("Dinner Reminder"),
                onTap: () {
                  NotificationService.scheduleMealReminder(20, 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Custom Time"),
                onTap: () {
                  Navigator.pop(context);
                  _pickCustomTime();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickCustomTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      NotificationService.scheduleMealReminder(time.hour, time.minute);
    }
  }
}
