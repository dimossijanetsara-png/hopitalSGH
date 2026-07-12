import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/widgets/primary_button.dart';
import 'package:sghl_mobile/features/appointments/appointment_repository.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends ConsumerState<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  // Doctor dropdown state
  List<Map<String, dynamic>> _doctors = [];
  String? _selectedDoctorId;
  bool _loadingDoctors = true;
  String? _doctorsError;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final repo = ref.read(appointmentRepositoryProvider);
      final doctors = await repo.getDoctors();
      if (mounted) {
        setState(() {
          _doctors = doctors;
          _loadingDoctors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _doctorsError = 'Impossible de charger la liste des médecins.';
          _loadingDoctors = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _formattedDate {
    if (_selectedDate == null) return 'Selectionner une date';
    return DateFormat('d MMMM yyyy', 'fr_FR').format(_selectedDate!);
  }

  String get _formattedTime {
    if (_selectedTime == null) return 'Selectionner une heure';
    final hour = _selectedTime!.hour.toString().padLeft(2, '0');
    final minute = _selectedTime!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
      helpText: 'Selectionner la date',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Selectionner l\'heure',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      _showError('Veuillez selectionner une date.');
      return;
    }
    if (_selectedTime == null) {
      _showError('Veuillez selectionner une heure.');
      return;
    }

    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (appointmentDateTime.isBefore(DateTime.now())) {
      _showError(
          'La date et l\'heure du rendez-vous doivent etre dans le futur.');
      return;
    }

    if (_selectedDoctorId == null) {
      _showError('Veuillez selectionner un medecin.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(appointmentRepositoryProvider);
      await repo.createAppointment(
        doctorId: _selectedDoctorId!,
        appointmentDate: appointmentDateTime,
        reason: _reasonController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rendez-vous pris avec succes !'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('Erreur lors de la prise de rendez-vous.\n$e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prendre un rendez-vous'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                icon: Icons.person_outline,
                title: 'Medecin',
              ),
              const SizedBox(height: 8),
              if (_loadingDoctors)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_doctorsError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _doctorsError!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _loadingDoctors = true;
                            _doctorsError = null;
                          });
                          _loadDoctors();
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedDoctorId,
                  decoration: _inputDecoration(
                    label: 'Sélectionner un médecin',
                    prefixIcon: Icons.medical_services_outlined,
                  ),
                  isExpanded: true,
                  hint: const Text('Choisir un médecin'),
                  items: _doctors.map((doc) {
                    final id = doc['id']?.toString() ?? '';
                    final name = 'Dr. ${doc['first_name'] ?? ''} ${doc['last_name'] ?? ''}'.trim();
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(name, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedDoctorId = val),
                  validator: (_) => _selectedDoctorId == null ? 'Veuillez sélectionner un médecin' : null,
                ),
              const SizedBox(height: 24),
              _SectionHeader(
                icon: Icons.calendar_month_outlined,
                title: 'Date et heure',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _PickerField(
                      label: _formattedDate,
                      icon: Icons.calendar_today,
                      onTap: _pickDate,
                      isSelected: _selectedDate != null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickerField(
                      label: _formattedTime,
                      icon: Icons.access_time,
                      onTap: _pickTime,
                      isSelected: _selectedTime != null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                icon: Icons.notes_outlined,
                title: 'Motif et notes',
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                decoration: _inputDecoration(
                  label: 'Motif du rendez-vous *',
                  hint: 'Ex: Consultation generale, douleurs abdominales...',
                  prefixIcon: Icons.medical_services_outlined,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Le motif est requis';
                  }
                  if (v.trim().length < 5) {
                    return 'Le motif doit comporter au moins 5 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: _inputDecoration(
                  label: 'Notes supplementaires (optionnel)',
                  hint: 'Informations complementaires pour le medecin...',
                  prefixIcon: Icons.info_outline,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Confirmer le rendez-vous',
                isLoading: _isSubmitting,
                icon: Icons.check_circle_outline,
                onPressed: _isSubmitting ? null : _submit,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Annuler',
                outlined: true,
                onPressed: _isSubmitting ? null : () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  const _PickerField({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
