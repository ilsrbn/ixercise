import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/features/onboarding/onboarding_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({
    super.key,
    this.onContinue,
  });

  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingControllerProvider);
    final OnboardingController controller =
        ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
              children: <Widget>[
                Row(
                  children: List<Widget>.generate(3, (int i) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
                        height: 3,
                        decoration: BoxDecoration(
                          color: i == 0 ? const Color(0xFF0A0A0A) : const Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                const Text(
                  'STEP 1 OF 3',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    color: Color(0xFF9A9A9A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pick exercises\nyou actually do.',
                  style: TextStyle(
                    fontSize: 42,
                    letterSpacing: -1.2,
                    height: 1.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Build your personal library. You can always add more later.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B6B6B),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  key: const Key('onboarding_search'),
                  onChanged: controller.setQuery,
                  decoration: InputDecoration(
                    hintText: 'Search exercises',
                    hintStyle: const TextStyle(color: Color(0xFF9A9A9A)),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.groups.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final String group = state.groups[index];
                      final bool active = group == state.group;
                      return OutlinedButton(
                        onPressed: () => controller.setGroup(group),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: active ? const Color(0xFF0A0A0A) : Colors.transparent,
                          foregroundColor: active ? Colors.white : const Color(0xFF0A0A0A),
                          side: BorderSide(
                            color: active ? const Color(0xFF0A0A0A) : const Color(0xFFE8E8E8),
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(group),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.filteredExercises.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final exercise = state.filteredExercises[index];
                    final bool selected = state.selectedExerciseIds.contains(exercise.id);
                    return InkWell(
                      key: Key('exercise_card_${exercise.id}'),
                      onTap: () => controller.toggleExercise(exercise.id),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: selected ? const Color(0xFF0A0A0A) : Colors.white,
                          border: Border.all(
                            color: selected ? const Color(0xFF0A0A0A) : const Color(0xFFE8E8E8),
                          ),
                        ),
                        child: Stack(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.fitness_center_outlined,
                                  size: 28,
                                  color: selected ? Colors.white : const Color(0xFF0A0A0A),
                                ),
                                const Spacer(),
                                Text(
                                  exercise.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? Colors.white : const Color(0xFF0A0A0A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exercise.group.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: selected
                                        ? Colors.white.withOpacity(0.55)
                                        : const Color(0xFF9A9A9A),
                                  ),
                                ),
                              ],
                            ),
                            if (selected)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE11D2E),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0x00FAFAFA), Color(0xFFFAFAFA)],
                    stops: <double>[0, 0.35],
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: '${state.selectedExerciseIds.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0A0A0A),
                            fontWeight: FontWeight.w700,
                          ),
                          children: const <InlineSpan>[
                            TextSpan(
                              text: ' selected',
                              style: TextStyle(
                                color: Color(0xFF6B6B6B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      key: const Key('onboarding_continue'),
                      onPressed: state.canContinue ? onContinue ?? () {} : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF0A0A0A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF0A0A0A).withOpacity(0.35),
                        minimumSize: const Size(140, 56),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
