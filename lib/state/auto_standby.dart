import 'package:equatable/equatable.dart';

import '../builders/sync/annotations.dart';
import '../builders/sync/settings.dart';

part 'auto_standby.g.dart';

@StateClass('vehicle', Duration(milliseconds: 500))
class AutoStandbyData extends Equatable with $AutoStandbyData {
  @override
  @StateField()
  final int autoStandbyRemaining;

  AutoStandbyData({
    this.autoStandbyRemaining = 0,
  });

  @override
  List<Object?> get props => [autoStandbyRemaining];
}
