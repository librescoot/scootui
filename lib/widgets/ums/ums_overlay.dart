import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/mdb_cubits.dart';
import '../../l10n/l10n.dart';
import '../../repositories/mdb_repository.dart';
import '../../repositories/redis_mdb_repository.dart';
import '../../state/usb.dart';

class UmsOverlay extends StatelessWidget {
  const UmsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsbSync, UsbData>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, usbData) {
        final repo = RepositoryProvider.of<MDBRepository>(context);
        if (repo is RedisMDBRepository) {
          repo.suppressConnectionToasts = usbData.status != "idle";
        }
      },
      child: BlocBuilder<UsbSync, UsbData>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, usbData) {
          final status = usbData.status;

          if (status == "idle") {
            return const SizedBox.shrink();
          }

          final l10n = context.l10n;

          return Container(
            color: Colors.black,
            child: Center(
              child: _buildContent(l10n, status),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, String status) {
    switch (status) {
      case "preparing":
        return _buildWithSpinner(l10n.umsPreparingStorage);
      case "active":
        return _buildActive(l10n);
      case "processing":
        return _buildWithSpinner(l10n.umsProcessingFiles);
      default:
        return _buildWithSpinner(l10n.umsStatus(status));
    }
  }

  Widget _buildWithSpinner(String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3.0,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActive(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.usb,
          color: Colors.white,
          size: 64,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.umsTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.umsConnectToComputer,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
