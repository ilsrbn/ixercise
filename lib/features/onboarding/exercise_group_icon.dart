import 'package:flutter/material.dart';

const Set<String> supportedExerciseIconGroups = <String>{
  'Chest',
  'Back',
  'Legs',
  'Core',
  'Arms',
  'Cardio',
  'Shoulders',
  'Other',
};

bool hasExerciseGroupIcon(String group) => supportedExerciseIconGroups.any(
  (String item) => item.toLowerCase() == group.toLowerCase(),
);

class ExerciseGroupIcon extends StatelessWidget {
  const ExerciseGroupIcon({
    super.key,
    required this.group,
    required this.color,
    this.size = 36,
  });

  final String group;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetForGroup(group),
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.high,
    );
  }
}

String _assetForGroup(String group) {
  switch (_canonicalGroup(group)) {
    case 'Chest':
      return 'assets/icons/muscle/chest.png';
    case 'Back':
      return 'assets/icons/muscle/back.png';
    case 'Legs':
      return 'assets/icons/muscle/legs.png';
    case 'Core':
      return 'assets/icons/muscle/core.png';
    case 'Arms':
      return 'assets/icons/muscle/arms.png';
    case 'Cardio':
      return 'assets/icons/muscle/cardio.png';
    case 'Shoulders':
      return 'assets/icons/muscle/shoulders.png';
    default:
      return 'assets/icons/muscle/other.png';
  }
}

String _canonicalGroup(String group) {
  for (final String item in supportedExerciseIconGroups) {
    if (item.toLowerCase() == group.toLowerCase()) {
      return item;
    }
  }
  return 'Other';
}
