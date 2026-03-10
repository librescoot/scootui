import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../repositories/address_repository.dart' as addresses;
import '../repositories/tiles_repository.dart' as tiles;
import '../services/l10n_service.dart';

part 'address_state.dart';
part 'address_cubit.freezed.dart';

class AddressCubit extends Cubit<AddressState> {
  final addresses.AddressRepository addressRepository;
  final tiles.TilesRepository tilesRepository;

  Isolate? _buildIsolate;
  ReceivePort? _buildPort;

  AddressCubit({
    required this.addressRepository,
    required this.tilesRepository,
  }) : super(AddressState.loading(L10nService.current.addressLoading));

  Future<void> _load() async {
    try {
      final db = await addressRepository.loadDatabase();
      switch (db) {
        case addresses.NotFound():
          final mapHash = await tilesRepository.getMapHash();
          if (mapHash == null) {
            emit(AddressState.error(L10nService.current.addressMapNotFound));
            return;
          }
          emit(AddressState.loading(L10nService.current.addressCreatingDb));
          await _startBuild(mapHash);

        case addresses.Success(:final database):
          final mapHash = await tilesRepository.getMapHash();
          if (mapHash == null) {
            emit(AddressState.error(L10nService.current.addressMapNotFound));
            return;
          }
          if (database.mapHash != mapHash) {
            emit(AddressState.loading(L10nService.current.addressRebuildingHash));
            await _startBuild(mapHash);
          } else {
            emit(AddressState.loaded(database.addresses));
          }

        case addresses.Error(message: final errorMessage):
          emit(AddressState.error(errorMessage));
      }
    } catch (e, st) {
      print('[AddressCubit] Error loading address database: $e\n$st');
      if (!isClosed) emit(AddressState.error(L10nService.current.addressBuildFailed));
    }
  }

  Future<void> _startBuild(String mapHash) async {
    try {
      final (:isolate, :port) = await addressRepository.buildDatabase(tilesRepository);
      _buildIsolate = isolate;
      _buildPort = port;

      await for (final message in port) {
        if (isClosed) break;

        if (message is (double, int)) {
          final (progress, addressCount) = message;
          emit(AddressState.loading(
            L10nService.current.addressCreatingDb,
            progress: progress,
            addressCount: addressCount,
          ));
        } else if (message is addresses.Addresses) {
          _buildIsolate = null;
          _buildPort = null;
          port.close();

          switch (message) {
            case addresses.Success(:final database):
              if (database.mapHash == mapHash) {
                if (!isClosed) emit(AddressState.loaded(database.addresses));
              } else {
                if (!isClosed) emit(AddressState.error(L10nService.current.addressHashMismatch));
              }
            case addresses.NotFound():
              if (!isClosed) emit(AddressState.error(L10nService.current.addressBuildFailed));
            case addresses.Error(message: final errorMessage):
              if (!isClosed) emit(AddressState.error(errorMessage));
          }
          break;
        }
      }
    } catch (e, st) {
      print('[AddressCubit] Error building address database: $e\n$st');
      if (!isClosed) emit(AddressState.error(L10nService.current.addressBuildFailed));
    }
  }

  @override
  Future<void> close() {
    _buildPort?.close();
    _buildIsolate?.kill(priority: Isolate.immediate);
    return super.close();
  }

  static AddressCubit create(BuildContext context) => AddressCubit(
        addressRepository: context.read<addresses.AddressRepository>(),
        tilesRepository: context.read<tiles.TilesRepository>(),
      ).._load();
}
