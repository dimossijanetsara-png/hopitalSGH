import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/utils/date_formatter.dart';
import 'package:sghl_mobile/core/widgets/error_card.dart';
import 'package:sghl_mobile/core/widgets/loading_widget.dart';
import 'package:sghl_mobile/features/medical_records/clinical_models.dart';
import 'package:sghl_mobile/features/medical_records/clinical_notifier.dart';

class ConsultationDetailScreen extends ConsumerWidget {
  final String consultationId;

  const ConsultationDetailScreen({
    super.key,
    required this.consultationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(consultationDetailProvider(consultationId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détail de la consultation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: detailAsync.when(
        loading: () => const LoadingWidget(
            message: 'Chargement de la consultation...'),
        error: (error, _) => ErrorCard(
          message: 'Impossible de charger la consultation.\n$error',
          onRetry: () =>
              ref.invalidate(consultationDetailProvider(consultationId)),
        ),
        data: (detail) => _DetailBody(detail: detail),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final ConsultationDetailModel detail;

  const _DetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'INFORMATIONS GÉNÉRALES',
            icon: Icons.info_outline,
            children: [
              _InfoRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: DateFormatter.formatDateTime(detail.consultationDate),
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.person_outline,
                label: 'Médecin',
                value: 'Dr. ${detail.doctorId}',
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.flag_outlined,
                label: 'Statut',
                value: _statusLabel(detail.status),
                valueWidget: _ConsultationStatusBadge(status: detail.status),
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.notes,
                label: 'Motif principal',
                value: detail.chiefComplaint,
              ),
            ],
          ),
          if (detail.anamnesis != null && detail.anamnesis!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'ANAMNÈSE',
              icon: Icons.history_edu_outlined,
              children: [
                _TextBlock(text: detail.anamnesis!),
              ],
            ),
          ],
          if (detail.physicalExam != null &&
              detail.physicalExam!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'EXAMEN CLINIQUE',
              icon: Icons.monitor_heart_outlined,
              children: [
                _TextBlock(text: detail.physicalExam!),
              ],
            ),
          ],
          if (detail.diagnoses.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'DIAGNOSTICS',
              icon: Icons.biotech_outlined,
              children: [
                ...detail.diagnoses.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DiagnosisCard(diagnosis: d),
                  ),
                ),
              ],
            ),
          ],
          if (detail.prescriptions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'PRESCRIPTIONS',
              icon: Icons.medication_outlined,
              children: [
                ...detail.prescriptions.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PrescriptionCard(prescription: p),
                  ),
                ),
              ],
            ),
          ],
          if (detail.notes != null && detail.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'NOTES',
              icon: Icons.edit_note_outlined,
              children: [
                _TextBlock(text: detail.notes!),
              ],
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      'COMPLETED' => 'Terminée',
      'CLOSED' => 'Clôturée',
      'PENDING' => 'En cours',
      _ => status,
    };
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                ),
              ],
            ),
            const Divider(height: 20, color: AppColors.border),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? valueWidget;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: valueWidget ??
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
        ),
      ],
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String text;

  const _TextBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
      ),
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  final DiagnosisModel diagnosis;

  const _DiagnosisCard({required this.diagnosis});

  @override
  Widget build(BuildContext context) {
    final isPrincipal = diagnosis.isPrincipal;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrincipal
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  diagnosis.icd10Code,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _DiagTypeBadge(diagType: diagnosis.diagType),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            diagnosis.icd10Label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (diagnosis.notes != null && diagnosis.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              diagnosis.notes!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiagTypeBadge extends StatelessWidget {
  final String diagType;

  const _DiagTypeBadge({required this.diagType});

  @override
  Widget build(BuildContext context) {
    final isPrincipal = diagType == 'PRINCIPAL';
    final label = isPrincipal ? 'Principal' : 'Secondaire';
    final color = isPrincipal ? AppColors.primary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

class _PrescriptionCard extends StatelessWidget {
  final PrescriptionModel prescription;

  const _PrescriptionCard({required this.prescription});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Ordonnance',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              _PrescriptionStatusBadge(status: prescription.status),
            ],
          ),
          if (prescription.notes != null &&
              prescription.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              prescription.notes!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
          if (prescription.items.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            ...prescription.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PrescriptionItemRow(item: item),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrescriptionItemRow extends StatelessWidget {
  final PrescriptionItemModel item;

  const _PrescriptionItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6, right: 10),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.medicationName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Wrap(
                spacing: 8,
                children: [
                  _MedInfoChip(label: item.dosage),
                  _MedInfoChip(label: item.frequency),
                  _MedInfoChip(label: item.duration),
                  if (item.route != null && item.route!.isNotEmpty)
                    _MedInfoChip(label: item.route!),
                ],
              ),
              if (item.instructions != null &&
                  item.instructions!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  item.instructions!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MedInfoChip extends StatelessWidget {
  final String label;

  const _MedInfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
      ),
    );
  }
}

class _PrescriptionStatusBadge extends StatelessWidget {
  final String status;

  const _PrescriptionStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'VALIDATED' => ('Validée', AppColors.success),
      'DISPENSED' => ('Dispensée', AppColors.primary),
      'DRAFT' => ('Brouillon', AppColors.warning),
      _ => (status, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
