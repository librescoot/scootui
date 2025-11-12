import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@immutable
class SystemState {
  final DateTime currentTime;

  const SystemState(this.currentTime);

  String get formattedTime {
    // If system clock is not set (before 2025-05-01), show placeholder
    final minValidDate = DateTime(2025, 5, 1);
    if (currentTime.isBefore(minValidDate)) {
      return '–';
    }
    return DateFormat("HH:mm").format(currentTime);
  }
}

class SystemCubit extends Cubit<SystemState> {
  Timer? _timer;

  SystemCubit() : super(SystemState(DateTime.now())) {
    _timer = Timer.periodic(Duration(seconds: 1), updateTime);
  }

  static SystemState watch(BuildContext context) => context.watch<SystemCubit>().state;

  static SystemCubit create(BuildContext context) => SystemCubit();

  void updateTime(Timer t) {
    emit(SystemState(DateTime.now()));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
