import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/ums_log_cubit.dart';
import '../../l10n/l10n.dart';
import '../../repositories/mdb_repository.dart';
import '../../repositories/redis_mdb_repository.dart';
import '../../state/usb.dart';

class UmsOverlay extends StatefulWidget {
  const UmsOverlay({super.key});

  @override
  State<UmsOverlay> createState() => _UmsOverlayState();
}

class _UmsOverlayState extends State<UmsOverlay> {
  void _onStatusChanged(BuildContext context, String status) {
    final logCubit = context.read<UmsLogCubit>();

    if (status == "idle") {
      logCubit.stopPolling();
      logCubit.clear();
    } else if (status == "processing") {
      logCubit.startPolling();
    } else {
      logCubit.stopPolling();
    }

  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsbSync, UsbData>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, usbData) {
        final repo = RepositoryProvider.of<MDBRepository>(context);
        if (repo is RedisMDBRepository) {
          repo.suppressConnectionToasts = usbData.status != "idle";
        }
        _onStatusChanged(context, usbData.status);
      },
      child: BlocBuilder<UsbSync, UsbData>(
        buildWhen: (previous, current) =>
            previous.status != current.status || previous.step != current.step,
        builder: (context, usbData) {
          final status = usbData.status;

          if (status == "idle") {
            return const SizedBox.shrink();
          }

          final l10n = context.l10n;

          return Container(
            color: Colors.black,
            child: Center(
              child: _buildContent(context, l10n, usbData),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, UsbData usbData) {
    switch (usbData.status) {
      case "preparing":
        return _buildWithSpinner(l10n.umsPreparingStorage);
      case "active":
        return _buildActive(l10n);
      case "processing":
        return _buildProcessing(context, l10n, usbData.step);
      default:
        return _buildWithSpinner(l10n.umsStatus(usbData.status));
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

  Widget _buildProcessing(BuildContext context, AppLocalizations l10n, String step) {
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
          l10n.umsProcessingFiles,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.center,
        ),
        if (step.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '→ $step',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: 72,
          child: BlocBuilder<UmsLogCubit, List<String>>(
            builder: (context, logEntries) {
              final visible = logEntries.length > 4 ? logEntries.sublist(logEntries.length - 4) : logEntries;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: visible
                    .map(
                      (entry) => Text(
                        entry,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                    .toList(),
              );
            },
          ),
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
