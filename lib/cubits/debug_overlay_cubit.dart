import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/mdb_repository.dart';
import '../state/dashboard.dart';
import 'dashboard_cubit.dart';

enum DebugMode { off, overlay, full }

extension DebugModeString on String {
  DebugMode toDebugMode() {
    switch (toLowerCase()) {
      case 'overlay':
        return DebugMode.overlay;
      case 'full':
        return DebugMode.full;
      case 'off':
      default:
        return DebugMode.off;
    }
  }
}

class DebugOverlayCubit extends Cubit<DebugMode> {
  final MDBRepository? _mdbRepository;
  StreamSubscription<DashboardData>? _dashboardSubscription;

  static const _redisKey = 'dashboard';
  static const _redisField = 'debug';

  DebugOverlayCubit({
    MDBRepository? mdbRepository,
    Stream<DashboardData>? dashboardStream,
  })  : _mdbRepository = mdbRepository,
        super(DebugMode.off) {
    if (dashboardStream != null) {
      _dashboardSubscription = dashboardStream.listen((data) {
        final debugMode = (data.debug == null || data.debug!.isEmpty)
            ? DebugMode.off
            : data.debug!.toDebugMode();
        if (debugMode != state) emit(debugMode);
      });
    }
  }

  static DebugOverlayCubit create(BuildContext context) {
    return DebugOverlayCubit(
      mdbRepository: context.read<MDBRepository>(),
      dashboardStream: context.read<DashboardSyncCubit>().stream,
    );
  }

  void toggleMode() async {
    final DebugMode newMode = switch (state) {
      DebugMode.off => DebugMode.overlay,
      DebugMode.overlay => DebugMode.off,
      DebugMode.full => DebugMode.off,
    };

    emit(newMode);
    await _updateRedisValue(newMode);
  }

  void setMode(DebugMode mode) async {
    emit(mode);
    await _updateRedisValue(mode);
  }

  void showOverlay() async {
    emit(DebugMode.overlay);
    await _updateRedisValue(DebugMode.overlay);
  }

  void showFullDebug() async {
    emit(DebugMode.full);
    await _updateRedisValue(DebugMode.full);
  }

  void hideDebug() async {
    emit(DebugMode.off);
    await _updateRedisValue(DebugMode.off);
  }

  Future<void> _updateRedisValue(DebugMode mode) async {
    if (_mdbRepository == null) return;

    final String value = switch (mode) {
      DebugMode.off => 'off',
      DebugMode.overlay => 'overlay',
      DebugMode.full => 'full',
    };

    try {
      await _mdbRepository!.set(_redisKey, _redisField, value);
    } catch (e) {
      debugPrint('Error updating debug mode in Redis: $e');
    }
  }

  @override
  Future<void> close() {
    _dashboardSubscription?.cancel();
    return super.close();
  }
}
