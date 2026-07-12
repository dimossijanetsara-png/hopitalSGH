import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/widgets/primary_button.dart';

class CarePlanScreen extends ConsumerWidget {
  const CarePlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Plan de Soins'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Main informational card
          _MainInfoCard(context: context),
          const SizedBox(height: 16),

          // Vital signs section
          _SectionCard(
            icon: Icons.monitor_heart_outlined,
            iconColor: AppColors.error,
            title: 'Signes Vitaux',
            children: [
              _InfoRow(
                icon: Icons.favorite_border,
                label: 'Surveillance continue',
                value:
                    'Vos constantes vitales sont mesurees et enregistrees regulierement par l\'equipe soignante.',
              ),
              const SizedBox(height: 10),
              _VitalSignItem(
                icon: Icons.favorite,
                color: AppColors.error,
                label: 'Frequence cardiaque',
                description: 'Surveille en continu',
              ),
              _VitalSignItem(
                icon: Icons.air,
                color: AppColors.primary,
                label: 'Pression arterielle',
                description: 'Mesuree regulierement',
              ),
              _VitalSignItem(
                icon: Icons.thermostat,
                color: AppColors.warning,
                label: 'Temperature',
                description: 'Verifiee a chaque passage',
              ),
              _VitalSignItem(
                icon: Icons.bubble_chart_outlined,
                color: const Color(0xFF00ACC1),
                label: 'Saturation en oxygene',
                description: 'Monitoree en permanence',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Access to care plan section
          _SectionCard(
            icon: Icons.assignment_outlined,
            iconColor: AppColors.primary,
            title: 'Acces au Plan de Soins',
            children: [
              const Text(
                'Votre plan de soins est elabore et mis a jour par votre equipe medicale en fonction de votre etat de sante et de l\'evolution de votre hospitalisation.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              _InfoRow(
                icon: Icons.person_outline,
                label: 'Medecin referent',
                value: 'Responsable de votre suivi medical et therapeutique.',
              ),
              _InfoRow(
                icon: Icons.medical_services_outlined,
                label: 'Infirmier(ere) referent(e)',
                value:
                    'Assure la coordination de vos soins au quotidien.',
              ),
              _InfoRow(
                icon: Icons.update,
                label: 'Mise a jour',
                value:
                    'Votre plan est actualise en fonction de votre evolution clinique.',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Medication reminders section
          _SectionCard(
            icon: Icons.medication_outlined,
            iconColor: const Color(0xFF7B1FA2),
            title: 'Mes Rappels Medicaments',
            children: [
              const Text(
                'Les rappels de prise de medicaments sont geres par votre equipe soignante lors de votre hospitalisation.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B1FA2).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF7B1FA2).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _MedReminderItem(
                      time: 'Matin',
                      icon: Icons.wb_sunny_outlined,
                      color: AppColors.warning,
                      description: 'Selon prescription medicale',
                    ),
                    const Divider(height: 16),
                    _MedReminderItem(
                      time: 'Midi',
                      icon: Icons.light_mode_outlined,
                      color: const Color(0xFFFB8C00),
                      description: 'Selon prescription medicale',
                    ),
                    const Divider(height: 16),
                    _MedReminderItem(
                      time: 'Soir',
                      icon: Icons.nights_stay_outlined,
                      color: AppColors.primary,
                      description: 'Selon prescription medicale',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pour toute question concernant vos medicaments, adressez-vous directement a votre infirmier(ere).',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contact team button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(height: 10),
                Text(
                  'Besoin d\'information ?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Contactez votre equipe soignante directement via la messagerie securisee.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Ouvrir la messagerie',
                  icon: Icons.message_outlined,
                  onPressed: () => context.push('/messages'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MainInfoCard extends StatelessWidget {
  final BuildContext context;

  const _MainInfoCard({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bed,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre plan de soins est gere par votre equipe medicale',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Pour toute question, contactez votre infirmier(ere) referent(e)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label : ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  TextSpan(
                    text: value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalSignItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String description;

  const _VitalSignItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedReminderItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final Color color;
  final String description;

  const _MedReminderItem({
    required this.time,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(
          time,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Icon(Icons.circle, size: 8, color: color.withValues(alpha: 0.5)),
      ],
    );
  }
}
