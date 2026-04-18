import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/app/shell.dart';

void main() {
  runApp(
    ProviderScope(
      child: IxerciseApp(),
    ),
  );
}
