import 'package:scooter_cluster/map/map_draw_command.dart';

class DisplayTile {
  final int z;
  final int x;
  final int y;
  final List<MapDrawCommand> commands;

  DisplayTile({
    required this.z,
    required this.x,
    required this.y,
    required this.commands,
  });
}
