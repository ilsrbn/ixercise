import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ixercise/app/router.dart';

class IxerciseApp extends ConsumerWidget {
  IxerciseApp({super.key, GoRouter? router}) : _router = router ?? buildRouter();

  final GoRouter _router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Ixercise',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
