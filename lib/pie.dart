import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AttendancePieChart extends StatelessWidget {
  final double attendedClasses;
  final double bunkedClasses;

  const AttendancePieChart({super.key, required this.attendedClasses, required this.bunkedClasses});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      // The fl_chart PieChart widget
      
      child: PieChart(
        PieChartData(
          sectionsSpace: 2, // Tiny gap between the green and red
          centerSpaceRadius: 40, // Makes it a "Donut" chart instead of a solid pie
          sections: [
            // The Safe Zone (Your Sage Green)
            PieChartSectionData(
              color: Theme.of(context).colorScheme.primary, 
              value: attendedClasses,
              title: 'Attended',
              radius: 50,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 16),
            ),
            // The Danger Zone (Your Brick Red)
            PieChartSectionData(
              color: Theme.of(context).colorScheme.error,
              value: bunkedClasses,
              title: 'Bunked',
              radius: 50,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}