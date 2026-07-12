class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDate;
  final int durationMinutes;
  final String reason;
  final String status;
  final String? notes;
  final String? cancellationReason;
  final DateTime createdAt;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.durationMinutes,
    required this.reason,
    required this.status,
    this.notes,
    this.cancellationReason,
    required this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 30,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      notes: json['notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'appointment_date': appointmentDate.toIso8601String(),
      'duration_minutes': durationMinutes,
      'reason': reason,
      'status': status,
      if (notes != null) 'notes': notes,
      if (cancellationReason != null) 'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isUpcoming =>
      status == 'CONFIRMED' || status == 'PENDING';

  bool get isPast =>
      status == 'COMPLETED' || status == 'CANCELLED' || status == 'NO_SHOW';

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? appointmentDate,
    int? durationMinutes,
    String? reason,
    String? status,
    String? notes,
    String? cancellationReason,
    DateTime? createdAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DoctorAvailability {
  final String id;
  final String doctorId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final int slotDurationMinutes;
  final bool isActive;

  const DoctorAvailability({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotDurationMinutes,
    required this.isActive,
  });

  factory DoctorAvailability.fromJson(Map<String, dynamic> json) {
    return DoctorAvailability(
      id: json['id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      dayOfWeek: (json['day_of_week'] as num?)?.toInt() ?? 0,
      startTime: json['start_time'] as String? ?? '08:00',
      endTime: json['end_time'] as String? ?? '17:00',
      slotDurationMinutes:
          (json['slot_duration_minutes'] as num?)?.toInt() ?? 30,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Day name in French (0=Monday, 6=Sunday).
  String get dayName {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    if (dayOfWeek >= 0 && dayOfWeek < days.length) {
      return days[dayOfWeek];
    }
    return 'Inconnu';
  }
}
