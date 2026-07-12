import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/utils/date_formatter.dart';
import 'package:sghl_mobile/core/widgets/empty_state.dart';
import 'package:sghl_mobile/core/widgets/error_card.dart';
import 'package:sghl_mobile/core/widgets/loading_widget.dart';
import 'package:sghl_mobile/features/appointments/appointment_models.dart';
import 'package:sghl_mobile/features/appointments/appointment_notifier.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Rendez-vous'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Prendre un rendez-vous',
              onPressed: () => context.push('/appointments/book'),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'A venir'),
              Tab(text: 'Passes'),
            ],
          ),
        ),
        body: ref.watch(appointmentsProvider).when(
              loading: () =>
                  const LoadingWidget(message: 'Chargement des rendez-vous...'),
              error: (error, _) => ErrorCard(
                message: 'Impossible de charger les rendez-vous.\n$error',
                onRetry: () =>
                    ref.read(appointmentsProvider.notifier).refresh(),
              ),
              data: (appointments) {
                final upcoming = appointments
                    .where((a) => a.isUpcoming)
                    .toList()
                  ..sort((a, b) =>
                      a.appointmentDate.compareTo(b.appointmentDate));

                final past = appointments
                    .where((a) => a.isPast)
                    .toList()
                  ..sort((a, b) =>
                      b.appointmentDate.compareTo(a.appointmentDate));

                return TabBarView(
                  children: [
                    _AppointmentList(
                      appointments: upcoming,
                      isUpcoming: true,
                      onRefresh: () =>
                          ref.read(appointmentsProvider.notifier).refresh(),
                      onCancel: (id, reason) => ref
                          .read(appointmentsProvider.notifier)
                          .cancelAppointment(id, reason: reason),
                    ),
                    _AppointmentList(
                      appointments: past,
                      isUpcoming: false,
                      onRefresh: () =>
                          ref.read(appointmentsProvider.notifier).refresh(),
                      onCancel: null,
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final bool isUpcoming;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String id, String? reason)? onCancel;

  const _AppointmentList({
    required this.appointments,
    required this.isUpcoming,
    required this.onRefresh,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: EmptyState(
              icon: Icons.calendar_month_outlined,
              title: 'Aucun rendez-vous',
              subtitle: isUpcoming
                  ? 'Vous n\'avez pas de rendez-vous a venir.'
                  : 'Aucun rendez-vous passe.',
              action: isUpcoming
                  ? ElevatedButton.icon(
                      onPressed: () => context.push('/appointments/book'),
                      icon: const Icon(Icons.add),
                      label: const Text('Prendre un rendez-vous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appt = appointments[index];
          if (isUpcoming && onCancel != null) {
            return Dismissible(
              key: ValueKey(appt.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cancel, color: Colors.white, size: 28),
                    SizedBox(height: 4),
                    Text(
                      'Annuler',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              confirmDismiss: (_) async {
                return _showCancelDialog(context, appt, onCancel!);
              },
              onDismissed: (_) {},
              child: _AppointmentCard(appointment: appt),
            );
          }
          return _AppointmentCard(appointment: appt);
        },
      ),
    );
  }

  Future<bool> _showCancelDialog(
    BuildContext context,
    AppointmentModel appt,
    Future<void> Function(String id, String? reason) onCancel,
  ) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler le rendez-vous'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Etes-vous sur de vouloir annuler ce rendez-vous du ${DateFormatter.formatDateTime(appt.appointmentDate)} ?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motif d\'annulation (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Annuler le RDV'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final reason =
          reasonController.text.trim().isEmpty ? null : reasonController.text.trim();
      await onCancel(appt.id, reason);
    }

    return false;
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormatter.formatDateTime(appointment.appointmentDate),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dr. ${appointment.doctorId}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: appointment.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.notes, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    appointment.reason,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (appointment.durationMinutes > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Duree : ${appointment.durationMinutes} min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
            if (appointment.notes != null &&
                appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      appointment.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'CONFIRMED' => ('Confirme', AppColors.success),
      'PENDING' => ('En attente', AppColors.warning),
      'CANCELLED' => ('Annule', AppColors.error),
      'COMPLETED' => ('Termine', const Color(0xFF1565C0)),
      'NO_SHOW' => ('Absent', Colors.grey),
      _ => (status, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
