import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/features/home/home_controller.dart';

class HomeOverviewScreen extends ConsumerWidget {
  const HomeOverviewScreen({
    super.key,
    this.onStartTraining,
    this.onEditTraining,
    this.onDeleteTraining,
    this.onCreateTraining,
  });

  final ValueChanged<TrainingPlan>? onStartTraining;
  final ValueChanged<TrainingPlan>? onEditTraining;
  final ValueChanged<TrainingPlan>? onDeleteTraining;
  final VoidCallback? onCreateTraining;

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
                  TextButton.icon(
                    key: const Key('home_new_training'),
                    onPressed: onCreateTraining,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0A0A0A),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'New',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: homeState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : homeState.plans.isEmpty
                        ? const Center(
                            child: Text(
                              'No trainings yet.\nTap New to create your first one.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Color(0xFF6B6B6B), height: 1.4),
                            ),
                          )
                        : ListView.separated(
                            itemCount: homeState.plans.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, color: Color(0xFFE8E8E8)),
                            itemBuilder: (BuildContext context, int index) {
                              final TrainingPlan plan = homeState.plans[index];
                              return _SwipeActionRow(
                                onEdit: () => onEditTraining?.call(plan),
                                onDelete: () => onDeleteTraining?.call(plan),
                                child: Padding(
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
                                              '${plan.items.length} exercises · ${_estimatedDuration(plan)} · ${_scheduleLabel(homeState.schedulesByPlanId[plan.id])}',
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
                                        onPressed: () => onStartTraining?.call(plan),
                                        style: IconButton.styleFrom(
                                          fixedSize: const Size(40, 40),
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(color: Color(0xFFE8E8E8)),
                                        ),
                                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                                      ),
                                    ],
                                  ),
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

  String _scheduleLabel(Map<String, dynamic>? schedule) {
    if (schedule == null) {
      return 'Not scheduled';
    }
    final String type = schedule['type'] as String? ?? 'none';
    final String time = schedule['time'] as String? ?? '';
    if (type == 'alternating') {
      return time.isEmpty ? 'Alternating days' : 'Alternating days · $time';
    }
    if (type == 'weekdays') {
      final List<dynamic> raw = schedule['weekdays'] as List<dynamic>? ?? <dynamic>[];
      const Map<int, String> dayNames = <int, String>{
        1: 'Mon',
        2: 'Tue',
        3: 'Wed',
        4: 'Thu',
        5: 'Fri',
        6: 'Sat',
        7: 'Sun',
      };
      final List<String> days = raw
          .whereType<int>()
          .map((int d) => dayNames[d] ?? '')
          .where((String d) => d.isNotEmpty)
          .toList(growable: false);
      final String dayText = days.isEmpty ? 'Weekdays' : days.join(' · ');
      return time.isEmpty ? dayText : '$dayText · $time';
    }
    return 'Not scheduled';
  }
}

class _SwipeActionRow extends StatefulWidget {
  const _SwipeActionRow({
    required this.child,
    required this.onEdit,
    required this.onDelete,
  });

  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<_SwipeActionRow> createState() => _SwipeActionRowState();
}

class _SwipeActionRowState extends State<_SwipeActionRow> {
  static const double _maxReveal = 126;
  double _drag = 0;

  @override
  Widget build(BuildContext context) {
    final double reveal = (-_drag / _maxReveal).clamp(0.0, 1.0);
    return SizedBox(
      height: 98,
      child: ClipRect(
        child: Stack(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                final double next = (_drag + details.delta.dx).clamp(-_maxReveal, 0.0);
                setState(() => _drag = next);
              },
              onHorizontalDragEnd: (_) {
                setState(() => _drag = _drag.abs() > _maxReveal * 0.4 ? -_maxReveal : 0);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(_drag, 0, 0),
                color: const Color(0xFFFAFAFA),
                child: widget.child,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: _maxReveal,
              child: IgnorePointer(
                ignoring: reveal < 0.18,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 140),
                  opacity: reveal,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _ActionIcon(
                          icon: Icons.edit_outlined,
                          color: const Color(0xFF0A0A0A),
                          onTap: () {
                            widget.onEdit?.call();
                            setState(() => _drag = 0);
                          },
                        ),
                        const SizedBox(width: 8),
                        _ActionIcon(
                          icon: Icons.delete_outline,
                          color: const Color(0xFFE11D2E),
                          onTap: () {
                            widget.onDelete?.call();
                            setState(() => _drag = 0);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
