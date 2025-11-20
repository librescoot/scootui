import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../repositories/address_repository.dart' as addresses;
import '../repositories/address_repository.dart';
import '../repositories/tiles_repository.dart' as tiles;

part 'address_state.dart';
part 'address_cubit.freezed.dart';

class AddressCubit extends Cubit<AddressState> {
  final addresses.AddressRepository addressRepository;
  final tiles.TilesRepository tilesRepository;

  AddressCubit({
    required this.addressRepository,
    required this.tilesRepository,
  }) : super(const AddressState.loading('Loading address database...'));

  Future<void> _load() async {
    final mapHash = await tilesRepository.getMapHash();
    if (mapHash == null) {
      emit(const AddressState.error('Map file not found.'));
      return;
    }

    final db = await addressRepository.loadDatabase();
    emit(await _unpackDb(db, mapHash, true));
  }

  Future<AddressState> _unpackDb(
      addresses.Addresses db, String mapHash, bool rebuild) async {
    switch (db) {
      case addresses.Success(:final database):
        if (database.mapHash != mapHash) {
          if (rebuild) {
            emit(const AddressState.loading(
                'Rebuilding address database due to hash mismatch...'));
            return _unpackDb(
                await addressRepository.buildDatabase(tilesRepository),
                mapHash,
                false);
          } else {
            return AddressState.error('Map hash mismatch after rebuild.');
          }
        } else {
          return AddressState.loaded(database.addresses);
        }
      case addresses.NotFound():
        if (rebuild) {
          emit(const AddressState.loading('Creating address database...'));
          return _unpackDb(
              await addressRepository.buildDatabase(tilesRepository),
              mapHash,
              false);
        }
        return const AddressState.error('Failed to build address database.');
      case addresses.Error(:final message):
        return AddressState.error(message);
    }
  }

  static AddressCubit create(BuildContext context) => AddressCubit(
        addressRepository: context.read<addresses.AddressRepository>(),
        tilesRepository: context.read<tiles.TilesRepository>(),
      ).._load();
}
