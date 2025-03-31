import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

@immutable
class SystemState {
  final DateTime currentTime;

  const SystemState(this.currentTime);

  String get formattedTime => DateFormat("HH:mm").format(currentTime);
}

class SystemCubit extends Cubit<SystemState> {
  Timer? _timer;

  SystemCubit() : super(SystemState(DateTime.now())) {
    _timer = Timer.periodic(Duration(seconds: 1), updateTime);
  }

  static SystemState watch(BuildContext context) =>
      context.watch<SystemCubit>().state;

  static SystemCubit create(BuildContext context) =>
      SystemCubit();

  void updateTime(Timer t) {
    emit(SystemState(DateTime.now()));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
