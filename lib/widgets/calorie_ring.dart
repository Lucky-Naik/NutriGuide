import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CalorieRing extends StatelessWidget {
  final double consumed;
  final double target;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final percent = target == 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0);

    final remaining = (target - consumed).clamp(0, target);

    return Center(
      child: CircularPercentIndicator(
        radius: 90,
        lineWidth: 14,
        percent: percent,
        animation: true,
        animationDuration: 1000,
        circularStrokeCap: CircularStrokeCap.round,
        backgroundColor: Colors.grey.shade300,
        progressColor: Colors.green,
        center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${(percent * 100).toInt()}%",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              "${consumed.toInt()} / ${target.toInt()} kcal",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              "${remaining.toInt()} kcal left",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
