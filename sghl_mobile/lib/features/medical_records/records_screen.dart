import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/utils/date_formatter.dart';
import 'package:sghl_mobile/core/widgets/empty_state.dart';
import 'package:sghl_mobile/core/widgets/error_card.dart';
import 'package:sghl_mobile/core/widgets/loading_widget.dart';
import 'package:sghl_mobile/features/medical_records/clinical_models.dart';
import 'package:sghl_mobile/features/medical_records/clinical_notifier.dart';

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(consultationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Dossier Médical'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: () =>
                ref.read(consultationsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () =>
            const LoadingWidget(message: 'Chargement du dossier médical...'),
        error: (error, _) => ErrorCard(
          message: 'Impossible de charger le dossier médical.\n$error',
          onRetry: () => ref.read(consultationsProvider.notifier).refresh(),
        ),
        data: (consultations) {
          if (consultations.isEmpty) {
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(consultationsProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: const EmptyState(
                    icon: Icons.medical_information_outlined,
                    title: 'Aucune consultation',
                    subtitle:
                        'Votre dossier médical ne contient pas encore de consultations.',
                  ),
                ),
              ),
            );
          }

          final sorted = [...consultations]
            ..sort((a, b) =>
                b.consultationDate.compareTo(a.consultationDate));

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(consultationsProvider.notifier).refresh(),
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final consultation = sorted[index];
                return _ConsultationCard(
                  consultation: consultation,
                  onTap: () =>
                      context.go('/records/${consultation.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final ConsultationModel consultation;
  final VoidCallback onTap;

  const _ConsultationCard({
    required this.consultation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.folder_shared_outlined,
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
                          DateFormatter.formatDateTime(
                              consultation.consultationDate),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Dr. ${consultation.doctorId}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _ConsultationStatusBadge(status: consultation.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      consultation.chiefComplaint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Voir le détail',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsultationStatusBadge extends StatelessWidget {
  final String status;

  const _ConsultationStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'COMPLETED' => ('Terminée', AppColors.success),
      'CLOSED' => ('Clôturée', AppColors.textSecondary),
      'PENDING' => ('En cours', AppColors.warning),
      _ => (status, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
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
