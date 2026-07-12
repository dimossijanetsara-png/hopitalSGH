import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/utils/date_formatter.dart';
import 'package:sghl_mobile/core/widgets/primary_button.dart';
import 'package:sghl_mobile/core/widgets/loading_widget.dart';
import 'package:sghl_mobile/features/appointments/appointment_models.dart';
import 'package:sghl_mobile/features/appointments/appointment_notifier.dart';
import 'package:sghl_mobile/features/auth/auth_notifier.dart';
import 'package:sghl_mobile/features/lab_results/lab_models.dart';
import 'package:sghl_mobile/features/lab_results/lab_notifier.dart';
import 'package:sghl_mobile/features/medical_records/clinical_notifier.dart';
import 'package:sghl_mobile/features/messaging/messaging_models.dart';
import 'package:sghl_mobile/features/messaging/messaging_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final labOrdersAsync = ref.watch(labOrdersProvider);
    final conversationsAsync = ref.watch(conversationsProvider);
    // Watch consultationsProvider so it stays warm and the refresh trigger works.
    ref.watch(consultationsProvider);

    final user = authState.user;
    final firstName = user?.firstName ?? 'Patient';
    final now = DateTime.now();
    final dateLabel = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(now);
    // Capitalise first letter
    final dateDisplay =
        dateLabel.isNotEmpty ? dateLabel[0].toUpperCase() + dateLabel.substring(1) : dateLabel;

    // Derive counts from async values
    final upcomingCount = appointmentsAsync.when(
      data: (list) =>
          list.where((a) => a.status == 'CONFIRMED' && a.appointmentDate.isAfter(now)).length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final conversationCount = conversationsAsync.when(
      data: (list) => list.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final publishedLabCount = labOrdersAsync.when(
      data: (list) => list.where((o) => o.status == 'PUBLISHED').length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.read(appointmentsProvider.notifier).refresh();
          ref.read(labOrdersProvider.notifier).refresh();
          ref.read(conversationsProvider.notifier).refresh();
          ref.read(consultationsProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            // ----------------------------------------------------------------
            // HEADER — blue gradient
            // ----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _DashboardHeader(
                firstName: firstName,
                dateDisplay: dateDisplay,
              ),
            ),

            // ----------------------------------------------------------------
            // QUICK STATS ROW
            // ----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _QuickStatsRow(
                upcomingCount: upcomingCount,
                conversationCount: conversationCount,
                publishedLabCount: publishedLabCount,
              ),
            ),

            // ----------------------------------------------------------------
            // PROCHAIN RENDEZ-VOUS
            // ----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _SectionWrapper(
                title: 'Prochain rendez-vous',
                icon: Icons.event_available_rounded,
                onSeeAll: () => context.go('/appointments'),
                seeAllLabel: 'Voir tout',
                child: appointmentsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: LoadingWidget(),
                  ),
                  error: (e, _) => _InlineError(
                    message: 'Impossible de charger les rendez-vous.',
                    onRetry: () =>
                        ref.read(appointmentsProvider.notifier).refresh(),
                  ),
                  data: (appointments) {
                    final upcoming = appointments
                        .where((a) =>
                            (a.status == 'CONFIRMED' || a.status == 'PENDING') &&
                            a.appointmentDate.isAfter(now))
                        .toList()
                      ..sort((a, b) =>
                          a.appointmentDate.compareTo(b.appointmentDate));

                    if (upcoming.isEmpty) {
                      return _NoAppointmentCard(
                        onBook: () => context.go('/appointments/book'),
                      );
                    }
                    return _AppointmentCard(appointment: upcoming.first);
                  },
                ),
              ),
            ),

            // ----------------------------------------------------------------
            // DERNIERES ANALYSES
            // ----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _SectionWrapper(
                title: 'Dernières analyses',
                icon: Icons.science_rounded,
                onSeeAll: () => context.go('/labs'),
                seeAllLabel: 'Voir tout',
                child: labOrdersAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: LoadingWidget(),
                  ),
                  error: (e, _) => _InlineError(
                    message: 'Impossible de charger les analyses.',
                    onRetry: () =>
                        ref.read(labOrdersProvider.notifier).refresh(),
                  ),
                  data: (orders) {
                    if (orders.isEmpty) {
                      return _EmptyListTile(
                        message: 'Aucune analyse disponible.',
                        icon: Icons.science_outlined,
                      );
                    }
                    final shown = orders.take(2).toList();
                    return Column(
                      children: shown
                          .map((o) => _LabOrderTile(order: o))
                          .toList(),
                    );
                  },
                ),
              ),
            ),

            // ----------------------------------------------------------------
            // MESSAGES NON LUS
            // ----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _SectionWrapper(
                title: 'Messages',
                icon: Icons.chat_bubble_rounded,
                onSeeAll: () => context.go('/messages'),
                seeAllLabel: 'Voir tout',
                child: conversationsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: LoadingWidget(),
                  ),
                  error: (e, _) => _InlineError(
                    message: 'Impossible de charger les messages.',
                    onRetry: () =>
                        ref.read(conversationsProvider.notifier).refresh(),
                  ),
                  data: (conversations) {
                    if (conversations.isEmpty) {
                      return _EmptyListTile(
                        message: 'Aucun message pour le moment.',
                        icon: Icons.chat_bubble_outline_rounded,
                      );
                    }
                    final shown = conversations.take(2).toList();
                    return Column(
                      children: shown
                          .map((c) => _ConversationTile(conversation: c))
                          .toList(),
                    );
                  },
                ),
              ),
            ),

            // ----------------------------------------------------------------
            // INFORMATIONS UTILES
            // ----------------------------------------------------------------
            const SliverToBoxAdapter(child: _InfoCard()),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _DashboardHeader extends StatelessWidget {
  final String firstName;
  final String dateDisplay;

  const _DashboardHeader({
    required this.firstName,
    required this.dateDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour,',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$firstName !',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            dateDisplay,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Hospital logo placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// QUICK STATS ROW
// ============================================================================

class _QuickStatsRow extends StatelessWidget {
  final int upcomingCount;
  final int conversationCount;
  final int publishedLabCount;

  const _QuickStatsRow({
    required this.upcomingCount,
    required this.conversationCount,
    required this.publishedLabCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.event_available_rounded,
              label: 'Prochains RDV',
              count: upcomingCount,
              iconColor: AppColors.primary,
              bgColor: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.chat_bubble_rounded,
              label: 'Messages',
              count: conversationCount,
              iconColor: AppColors.accent,
              bgColor: AppColors.accent.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.science_rounded,
              label: 'Analyses',
              count: publishedLabCount,
              iconColor: AppColors.success,
              bgColor: AppColors.success.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color iconColor;
  final Color bgColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION WRAPPER
// ============================================================================

class _SectionWrapper extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onSeeAll;
  final String? seeAllLabel;
  final Widget child;

  const _SectionWrapper({
    required this.title,
    required this.icon,
    this.onSeeAll,
    this.seeAllLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header row
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    seeAllLabel ?? 'Voir tout',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Content card container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// APPOINTMENT CARD
// ============================================================================

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentCard({required this.appointment});

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return AppColors.success;
      case 'PENDING':
        return AppColors.warning;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'CONFIRMED':
        return 'Confirmé';
      case 'PENDING':
        return 'En attente';
      case 'CANCELLED':
        return 'Annulé';
      case 'COMPLETED':
        return 'Terminé';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(appointment.status);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date badge
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('dd', 'fr_FR')
                      .format(appointment.appointmentDate),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  DateFormat('MMM', 'fr_FR')
                      .format(appointment.appointmentDate)
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.formatTime(appointment.appointmentDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${appointment.durationMinutes} min)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  appointment.reason.isNotEmpty
                      ? appointment.reason
                      : 'Consultation générale',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(appointment.status),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}

class _NoAppointmentCard extends StatelessWidget {
  final VoidCallback onBook;

  const _NoAppointmentCard({required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun rendez-vous à venir',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: PrimaryButton(
              label: 'Prendre un RDV',
              icon: Icons.add_rounded,
              onPressed: onBook,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LAB ORDER TILE
// ============================================================================

class _LabOrderTile extends StatelessWidget {
  final LabOrderModel order;

  const _LabOrderTile({required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case 'PUBLISHED':
        return AppColors.success;
      case 'VALIDATED':
        return AppColors.primary;
      case 'ORDERED':
        return AppColors.warning;
      case 'SAMPLED':
        return AppColors.accent;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PUBLISHED':
        return 'Publié';
      case 'VALIDATED':
        return 'Validé';
      case 'ORDERED':
        return 'Commandé';
      case 'SAMPLED':
        return 'Échantillon prélevé';
      case 'CANCELLED':
        return 'Annulé';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.biotech_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyse du ${DateFormatter.formatDate(order.createdAt)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusLabel(order.status),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                          ),
                        ),
                        if (order.isUrgent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'URGENT',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                            ),
                          ),
                        ],
                        if (order.hasAbnormalResults) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.warning_amber_rounded,
                              size: 14, color: AppColors.warning),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.5)),
            ],
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

// ============================================================================
// CONVERSATION TILE
// ============================================================================

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.forum_rounded,
                        color: AppColors.accent, size: 24),
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            conversation.unreadCount > 9
                                ? '9+'
                                : '${conversation.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.subject.isNotEmpty
                          ? conversation.subject
                          : 'Conversation',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (conversation.lastMessage != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        conversation.lastMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: hasUnread
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.timeAgo(conversation.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.5)),
            ],
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

// ============================================================================
// INFORMATIONS UTILES
// ============================================================================

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark.withValues(alpha: 0.85),
              AppColors.primary.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations utiles',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pour toute urgence, contactez immédiatement '
                      'le personnel médical ou composez le 15 (SAMU). '
                      'Notre équipe est disponible 24h/24, 7j/7.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.phone_in_talk_rounded,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Urgences : 15 · Hôpital : +221 33 000 00 00',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HELPERS
// ============================================================================

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _InlineError({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Réessayer', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _EmptyListTile extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyListTile({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 22),
          const SizedBox(width: 10),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
