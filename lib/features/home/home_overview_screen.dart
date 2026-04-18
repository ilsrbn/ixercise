import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/home/home_controller.dart';

class HomeOverviewScreen extends ConsumerWidget {
  const HomeOverviewScreen({
    super.key,
    this.onStartTraining,
  });

  final VoidCallback? onStartTraining;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text(
                    'Ixercise',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.settings_outlined, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'SAT, APR 18',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.1,
                  color: Color(0xFF9A9A9A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nothing scheduled.',
                style: TextStyle(
                  fontSize: 46,
                  letterSpacing: -1.4,
                  height: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: <Widget>[
                  Text(
                    'YOUR TRAININGS · ${homeState.plans.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: Color(0xFF9A9A9A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.add, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'New',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: homeState.plans.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE8E8E8)),
                  itemBuilder: (BuildContext context, int index) {
                    final TrainingPlan plan = homeState.plans[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  plan.name,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${plan.items.length} exercises · ${_estimatedDuration(plan)} · ${index == 0 ? 'Mon · Wed · Fri · 07:30' : 'Not scheduled'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B6B6B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            key: index == 0 ? const Key('home_start_training') : null,
                            onPressed: onStartTraining ?? () {},
                            style: IconButton.styleFrom(
                              fixedSize: const Size(40, 40),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFE8E8E8)),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _estimatedDuration(TrainingPlan plan) {
    int total = 0;
    for (final item in plan.items) {
      total += item.mode == ExerciseMode.time ? item.value : item.value * 3;
      total += item.restSeconds;
    }
    final int m = total ~/ 60;
    final int s = total % 60;
    if (m == 0) {
      return '${s}s';
    }
    return '${m}m ${s}s';
  }
}
