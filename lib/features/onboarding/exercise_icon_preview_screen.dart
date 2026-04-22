import 'package:flutter/material.dart';
import 'package:ixercise/features/onboarding/exercise_group_icon.dart';

class ExerciseIconPreviewScreen extends StatelessWidget {
  const ExerciseIconPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> groups = supportedExerciseIconGroups.toList(
      growable: false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          itemCount: groups.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return const _PreviewTitle();
            }
            final String group = groups[index - 1];
            return _IconPreviewCard(group: group);
          },
        ),
      ),
    );
  }
}

class _PreviewTitle extends StatelessWidget {
  const _PreviewTitle();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Muscle\nicons.',
        style: TextStyle(
          fontSize: 34,
          height: 0.95,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
      ),
    );
  }
}

class _IconPreviewCard extends StatelessWidget {
  const _IconPreviewCard({required this.group});

  final String group;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ExerciseGroupIcon(
            group: group,
            size: 86,
            color: const Color(0xFF0A0A0A),
          ),
          const Spacer(),
          Text(
            group,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'ICON PREVIEW',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
              color: Color(0xFF9A9A9A),
            ),
          ),
        ],
      ),
    );
  }
}
