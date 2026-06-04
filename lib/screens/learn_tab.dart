import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LearnTab extends StatelessWidget {
  const LearnTab({super.key});

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Learn & Grow"),
          bottom: const TabBar(
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Nutrition"),
              Tab(text: "Fitness"),
              Tab(text: "Lifestyle"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NutritionTab(),
            FitnessTab(),
            LifestyleTab(),
          ],
        ),
      ),
    );
  }
}

class NutritionTab extends StatelessWidget {
  const NutritionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildList([
      {
        "title": "Balance Your Macros",
        "content":
            "A healthy diet is not about cutting carbs or avoiding fats completely. Your body needs a balanced intake of protein, carbohydrates, and healthy fats to function properly. Protein supports muscle repair and growth, carbohydrates provide energy, and fats help regulate hormones and absorb vitamins.\n\nInstead of eliminating food groups, focus on portion control and quality. Choose whole grains over refined carbs, lean proteins over processed meats, and healthy fats like nuts and olive oil. Balance creates sustainability."
      },
      {
        "title": "Hydration is Key",
        "content":
            "Water plays a major role in digestion, metabolism, and nutrient transport. Even mild dehydration can cause fatigue, headaches, and reduced performance during workouts.\n\nAim for at least 2–3 liters of water daily. Increase your intake if you exercise regularly or live in a hot climate. A simple habit like drinking a glass of water before every meal can dramatically improve hydration."
      },
      {
        "title": "Protein Supports Recovery",
        "content":
            "Protein is essential for repairing muscle tissue after workouts. Without enough protein, your recovery slows down and muscle growth becomes difficult.\n\nInclude protein sources like eggs, chicken, fish, lentils, tofu, paneer, or Greek yogurt in your meals. Distribute protein intake throughout the day instead of consuming it all at once."
      },
      {
        "title": "Fiber for Digestive Health",
        "content":
            "Fiber improves digestion, stabilizes blood sugar levels, and keeps you full for longer periods. It also supports gut bacteria that influence immunity and overall health.\n\nInclude fruits, vegetables, legumes, and whole grains daily. Gradually increase fiber intake to avoid bloating and always pair it with adequate hydration."
      },
      {
        "title": "Reduce Processed Sugar",
        "content":
            "Excess sugar contributes to fat gain, energy crashes, and long-term health risks. Many packaged foods contain hidden sugars that increase calorie intake without providing nutrition.\n\nLimit sugary drinks, candies, and processed snacks. Instead, satisfy cravings with fruits or dark chocolate in moderation."
      },
      {
        "title": "Consistency Over Perfection",
        "content":
            "Healthy eating is not about being perfect every single day. It’s about making better choices most of the time. Occasional treats will not ruin your progress, but daily poor choices will.\n\nBuild sustainable habits. Focus on long-term health rather than short-term restrictions."
      },
    ]);
  }
}

class FitnessTab extends StatelessWidget {
  const FitnessTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildList([
      {
        "title": "Start Small and Build Momentum",
        "content":
            "If you're new to fitness, avoid jumping into intense workout routines immediately. Starting small helps prevent burnout and injury. Begin with 20–30 minutes of walking, light jogging, or bodyweight exercises.\n\nAs your stamina improves, gradually increase intensity and duration. Consistency matters more than intensity in the beginning."
      },
      {
        "title": "Strength Training is Essential",
        "content":
            "Strength training builds muscle mass, increases metabolism, and improves bone density. It is not only for bodybuilders — everyone benefits from resistance training.\n\nTrain major muscle groups 2–3 times per week. Include exercises like squats, push-ups, lunges, and rows. Progressive overload (gradually increasing weight or reps) leads to real progress."
      },
      {
        "title": "Cardio Improves Heart Health",
        "content":
            "Cardiovascular exercise strengthens the heart and improves lung capacity. Activities like running, cycling, swimming, or brisk walking enhance endurance and burn calories.\n\nAim for at least 150 minutes of moderate cardio per week. Even small sessions throughout the day add up significantly."
      },
      {
        "title": "Rest and Recovery Matter",
        "content":
            "Muscles grow during recovery, not during the workout itself. Without adequate rest, your performance declines and injury risk increases.\n\nSleep 7–8 hours per night and schedule at least one rest day per week. Active recovery like stretching or yoga can help reduce soreness."
      },
      {
        "title": "Discipline Beats Motivation",
        "content":
            "Motivation is temporary. Discipline is what creates long-term results. There will be days when you don’t feel like working out — show up anyway.\n\nBuild routines instead of relying on feelings. Habit formation is the key to transformation."
      },
      {
        "title": "Track Progress Weekly",
        "content":
            "Progress should be measured weekly, not daily. Daily fluctuations are normal due to water retention and muscle soreness.\n\nTrack your strength improvements, endurance, or body measurements to see meaningful changes over time."
      },
    ]);
  }
}

class LifestyleTab extends StatelessWidget {
  const LifestyleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _ExpandableCard(
          title: "Sleep Improves Fat Loss",
          content:
              "Quality sleep regulates hormones like cortisol and leptin, helping control hunger and stress.",
        ),
        const _ExpandableCard(
          title: "Stress Management",
          content:
              "Meditation, journaling and deep breathing improve mental clarity and reduce cravings.",
        ),
        const _ExpandableCard(
          title: "Sleep Improves Fat Loss",
          content:
              "Sleep regulates hormones like cortisol and leptin that control hunger and stress. Poor sleep increases cravings and slows fat loss.\n\nAim for consistent sleep timing and reduce screen exposure before bedtime to improve sleep quality.",
        ),
        const SizedBox(height: 20),
        Text(
          "Recommended Videos",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 10),
        _VideoCard(
          title: "10 Minute Home Workout",
          url: "https://youtu.be/ml6cT4AZdqI",
        ),
        _VideoCard(
          title: "Healthy Eating Explained",
          url: "https://youtu.be/9tRohh0gErM",
        ),
      ],
    );
  }
}

Widget _buildList(List<Map<String, String>> items) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return _ExpandableCard(
        title: item["title"]!,
        content: item["content"]!,
      );
    },
  );
}

class _ExpandableCard extends StatefulWidget {
  final String title;
  final String content;

  const _ExpandableCard({
    required this.title,
    required this.content,
  });

  @override
  State<_ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<_ExpandableCard>
    with SingleTickerProviderStateMixin {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: expanded
            ? Colors.green.withOpacity(0.08)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.06,
            ),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            expanded = !expanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 10),
              Text(
                widget.content,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String url;

  const _VideoCard({
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.play_circle_fill, color: Colors.red),
        title: Text(title),
        trailing: const Icon(Icons.open_in_new),
        onTap: () async {
          final uri = Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
      ),
    );
  }
}
