import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/utils/date_formatter.dart';
import 'package:sghl_mobile/core/widgets/empty_state.dart';
import 'package:sghl_mobile/core/widgets/error_card.dart';
import 'package:sghl_mobile/core/widgets/loading_widget.dart';
import 'package:sghl_mobile/features/lab_results/lab_models.dart';
import 'package:sghl_mobile/features/lab_results/lab_notifier.dart';

class LabResultsScreen extends ConsumerWidget {
  const LabResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Analyses'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: () => ref.read(labOrdersProvider.notifier).refresh(),
          ),
        ],
      ),
      body: ref.watch(labOrdersProvider).when(
            loading: () =>
                const LoadingWidget(message: 'Chargement des analyses...'),
            error: (error, _) => ErrorCard(
              message: 'Impossible de charger les analyses.\n$error',
              onRetry: () => ref.read(labOrdersProvider.notifier).refresh(),
            ),
            data: (orders) {
              if (orders.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(labOrdersProvider.notifier).refresh(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const EmptyState(
                        icon: Icons.science_outlined,
                        title: 'Aucune analyse',
                        subtitle:
                            'Vous n\'avez aucune demande d\'analyse en cours.',
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(labOrdersProvider.notifier).refresh(),
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _LabOrderCard(
                      order: order,
                      onTap: () => _showOrderDetail(context, ref, order),
                    );
                  },
                ),
              );
            },
          ),
    );
  }

  void _showOrderDetail(
      BuildContext context, WidgetRef ref, LabOrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LabOrderDetailSheet(order: order),
    );
  }
}

class _LabOrderCard extends StatelessWidget {
  final LabOrderModel order;
  final VoidCallback onTap;

  const _LabOrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = _statusInfo(order.status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                      Icons.biotech,
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
                          DateFormatter.formatDate(order.createdAt),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${order.items.length} analyse${order.items.length > 1 ? 's' : ''}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Badge(
                        label: statusLabel,
                        color: statusColor,
                      ),
                      if (order.isUrgent) ...[
                        const SizedBox(height: 4),
                        _Badge(
                          label: 'URGENT',
                          color: AppColors.error,
                          icon: Icons.priority_high,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (order.hasAbnormalResults) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 14, color: AppColors.error),
                      const SizedBox(width: 5),
                      Text(
                        'Resultats anormaux detectes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
              if (order.isPublished) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 5),
                    Text(
                      '${order.resultedCount}/${order.items.length} resultats disponibles',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Voir le detail  >',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static (String, Color) _statusInfo(String status) {
    return switch (status) {
      'ORDERED' => ('Commande', AppColors.textSecondary),
      'SAMPLED' => ('Prelevee', AppColors.warning),
      'ASSIGNED' => ('Assignee', AppColors.warning),
      'RESULTED' => ('En cours', const Color(0xFFFB8C00)),
      'VALIDATED' => ('Validee', AppColors.primary),
      'PUBLISHED' => ('Publiee', AppColors.success),
      _ => (status, Colors.grey),
    };
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Badge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabOrderDetailSheet extends StatelessWidget {
  final LabOrderModel order;

  const _LabOrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = _LabOrderCard._statusInfo(order.status);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.biotech,
                          color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demande d\'analyse',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormatter.formatDateTime(order.createdAt),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    _Badge(label: statusLabel, color: statusColor),
                  ],
                ),
              ),
              // Priority & notes summary
              if (order.isUrgent || order.clinicalNotes != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.isUrgent)
                        _Badge(
                            label: 'PRIORITE URGENTE',
                            color: AppColors.error,
                            icon: Icons.priority_high),
                      if (order.clinicalNotes != null &&
                          order.clinicalNotes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notes cliniques',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order.clinicalNotes!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const Divider(height: 1),
              // Test items list
              Expanded(
                child: order.items.isEmpty
                    ? const EmptyState(
                        icon: Icons.science_outlined,
                        title: 'Aucun test',
                        subtitle: 'Aucun test associe a cette demande.',
                      )
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: order.items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          return _LabTestItemTile(
                              item: item, index: index + 1);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LabTestItemTile extends StatelessWidget {
  final LabOrderItemModel item;
  final int index;

  const _LabTestItemTile({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isAbnormal
            ? AppColors.error.withValues(alpha: 0.05)
            : AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: item.isAbnormal
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Analyse #$index',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              if (item.isAbnormal)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ANORMAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Result value
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.assessment_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                'Resultat : ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                item.resultDisplay,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: item.hasResult
                          ? (item.isAbnormal
                              ? AppColors.error
                              : AppColors.textPrimary)
                          : AppColors.textSecondary,
                      fontWeight: item.hasResult
                          ? FontWeight.w700
                          : FontWeight.normal,
                      fontStyle: item.hasResult
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
              ),
            ],
          ),
          if (item.resultedAt != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule,
                    size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.formatDateTime(item.resultedAt!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ],
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                item.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
