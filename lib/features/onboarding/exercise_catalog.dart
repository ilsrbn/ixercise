class ExerciseSeed {
  const ExerciseSeed({
    required this.id,
    required this.name,
    required this.group,
  });

  final String id;
  final String name;
  final String group;
}

List<ExerciseSeed> buildExerciseCatalog() {
  const List<String> names = <String>[
    'Push-ups',
    'Incline push-ups',
    'Decline push-ups',
    'Wide push-ups',
    'Diamond push-ups',
    'Dumbbell bench press',
    'Dumbbell floor press',
    'Dumbbell flyes',
    'Incline dumbbell press',
    'Decline dumbbell press (bench)',
    'Dumbbell rows',
    'One-arm dumbbell row',
    'Bent-over dumbbell rows',
    'Reverse dumbbell flyes',
    'Superman hold',
    'Superman raises',
    'Renegade rows',
    'Dumbbell pullovers',
    'Incline bench rows',
    'Reverse snow angels',
    'Bodyweight squats',
    'Goblet squats',
    'Bulgarian split squats',
    'Lunges',
    'Reverse lunges',
    'Walking lunges',
    'Step-ups (bench)',
    'Dumbbell deadlifts',
    'Romanian deadlifts',
    'Sumo squats',
    'Wall sit',
    'Calf raises',
    'Single-leg calf raises',
    'Glute bridges',
    'Hip thrusts (bench)',
    'Dumbbell shoulder press',
    'Seated dumbbell press',
    'Arnold press',
    'Lateral raises',
    'Front raises',
    'Bent-over lateral raises',
    'Upright rows (dumbbell)',
    'Pike push-ups',
    'Handstand hold (wall)',
    'Dumbbell shrugs',
    'Biceps curls',
    'Hammer curls',
    'Concentration curls',
    'Incline dumbbell curls',
    'Zottman curls',
    'Triceps dips (bench)',
    'Close-grip push-ups',
    'Overhead triceps extension',
    'Triceps kickbacks',
    'Skull crushers (dumbbell)',
    'Cross-body hammer curls',
    'Reverse curls',
    'Isometric biceps hold',
    'Isometric triceps hold',
    'Alternating curls',
    'Plank',
    'Side plank',
    'Plank shoulder taps',
    'Mountain climbers',
    'Bicycle crunches',
    'Crunches',
    'Reverse crunches',
    'Leg raises',
    'Hanging leg raises (if possible)',
    'Russian twists',
    'Dead bug',
    'Flutter kicks',
    'V-ups',
    'Toe touches',
    'Heel taps',
    'Sit-ups',
    'Plank with leg lift',
    'Side plank hip dips',
    'Hollow body hold',
    'Superman plank',
    'Jumping jacks',
    'High knees',
    'Running in place',
    'Burpees',
    'Half burpees',
    'Squat jumps',
    'Jump lunges',
    'Skater jumps',
    'Fast feet',
    'Mountain climbers (fast)',
    'Plank jacks',
    'Tuck jumps',
    'Broad jumps',
    'Shadow boxing',
    'Bear crawl',
    'Crab walk',
    'Inchworms',
    'Jump rope (imaginary)',
    'Sprint intervals (in place)',
    'Step touch (fast)',
  ];

  return names
      .map(
        (String name) => ExerciseSeed(
          id: _idFromName(name),
          name: name,
          group: _groupForName(name),
        ),
      )
      .toList(growable: false);
}

String _idFromName(String name) {
  if (name == 'Push-ups') {
    return 'pushups';
  }
  final String lower = name.toLowerCase();
  final String normalized = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return normalized.replaceAll(RegExp(r'^_+|_+$'), '');
}

String _groupForName(String name) {
  final String n = name.toLowerCase();

  if (n.contains('curl') || n.contains('triceps') || n.contains('biceps')) {
    return 'Arms';
  }
  if (n.contains('push-up') ||
      n.contains('bench press') ||
      n.contains('dumbbell press') ||
      n.contains('flyes') ||
      n.contains('close-grip')) {
    return 'Chest';
  }
  if (n.contains('squat') ||
      n.contains('lunge') ||
      n.contains('calf') ||
      n.contains('deadlift') ||
      n.contains('step-up') ||
      n.contains('wall sit') ||
      n.contains('glute') ||
      n.contains('thrust')) {
    return 'Legs';
  }
  if (n.contains('plank') ||
      n.contains('crunch') ||
      n.contains('sit-up') ||
      n.contains('leg raise') ||
      n.contains('twist') ||
      n.contains('flutter') ||
      n.contains('v-up') ||
      n.contains('dead bug') ||
      n.contains('toe touches') ||
      n.contains('heel taps') ||
      n.contains('hollow')) {
    return 'Core';
  }
  if (n.contains('row') ||
      n.contains('superman') ||
      n.contains('pullovers') ||
      n.contains('snow angels') ||
      n.contains('shrugs')) {
    return 'Back';
  }
  if (n.contains('jump') ||
      n.contains('run') ||
      n.contains('burpee') ||
      n.contains('high knees') ||
      n.contains('fast') ||
      n.contains('boxing') ||
      n.contains('crawl') ||
      n.contains('inchworm') ||
      n.contains('rope') ||
      n.contains('intervals')) {
    return 'Cardio';
  }
  return 'Other';
}
