import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/mdb_repository.dart';

class UmsLogCubit extends Cubit<List<String>> {
  final MDBRepository _repository;
  Timer? _timer;

  static UmsLogCubit create(BuildContext context) =>
      UmsLogCubit(RepositoryProvider.of<MDBRepository>(context));

  UmsLogCubit(this._repository) : super([]);

  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) => _poll());
    _poll();
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  void clear() {
    emit([]);
  }

  // Strip leading timestamp ("YYYY-MM-DD HH:MM:SS " = 20 chars) for display.
  // Checks position 10 (space) and 13 (colon between HH and MM) to identify
  // the format produced by Go's time.Format("2006-01-02 15:04:05").
  static String _stripTimestamp(String entry) {
    if (entry.length > 20 && entry[10] == ' ' && entry[16] == ':') {
      return entry.substring(20);
    }
    return entry;
  }

  Future<void> _poll() async {
    try {
      final entries = await _repository.lrange("usb:log", 0, 19);
      if (!isClosed) emit(entries.reversed.map(_stripTimestamp).toList());
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
