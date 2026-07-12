class DiagnosisModel {
  final String id;
  final String icd10Code;
  final String icd10Label;
  final String diagType;
  final String? notes;

  const DiagnosisModel({
    required this.id,
    required this.icd10Code,
    required this.icd10Label,
    required this.diagType,
    this.notes,
  });

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      id: json['id']?.toString() ?? '',
      icd10Code: json['icd10_code'] as String? ?? '',
      icd10Label: json['icd10_label'] as String? ?? '',
      diagType: json['diag_type'] as String? ?? 'PRINCIPAL',
      notes: json['notes'] as String?,
    );
  }

  bool get isPrincipal => diagType == 'PRINCIPAL';
}

class PrescriptionItemModel {
  final String id;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final String? route;
  final String? instructions;
  final int quantity;

  const PrescriptionItemModel({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.route,
    this.instructions,
    required this.quantity,
  });

  factory PrescriptionItemModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionItemModel(
      id: json['id']?.toString() ?? '',
      medicationName: json['medication_name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      route: json['route'] as String?,
      instructions: json['instructions'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class PrescriptionModel {
  final String id;
  final String status;
  final String? notes;
  final DateTime? validatedAt;
  final DateTime createdAt;
  final List<PrescriptionItemModel> items;

  const PrescriptionModel({
    required this.id,
    required this.status,
    this.notes,
    this.validatedAt,
    required this.createdAt,
    required this.items,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final List<dynamic> itemsList =
        rawItems is List ? rawItems : [];

    return PrescriptionModel(
      id: json['id']?.toString() ?? '',
      status: json['status'] as String? ?? 'DRAFT',
      notes: json['notes'] as String?,
      validatedAt: json['validated_at'] != null
          ? DateTime.tryParse(json['validated_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      items: itemsList
          .map((e) =>
              PrescriptionItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ConsultationModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String status;
  final DateTime consultationDate;
  final String chiefComplaint;
  final String? anamnesis;
  final String? physicalExam;
  final String? notes;
  final DateTime createdAt;

  const ConsultationModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.status,
    required this.consultationDate,
    required this.chiefComplaint,
    this.anamnesis,
    this.physicalExam,
    this.notes,
    required this.createdAt,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    return ConsultationModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      status: json['status'] as String? ?? 'PENDING',
      consultationDate: json['consultation_date'] != null
          ? DateTime.tryParse(json['consultation_date'] as String) ??
              DateTime.now()
          : DateTime.now(),
      chiefComplaint: json['chief_complaint'] as String? ?? '',
      anamnesis: json['anamnesis'] as String?,
      physicalExam: json['physical_exam'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  bool get isCompleted => status == 'COMPLETED';
  bool get isClosed => status == 'CLOSED';
  bool get isPending => status == 'PENDING';
}

class ConsultationDetailModel extends ConsultationModel {
  final List<DiagnosisModel> diagnoses;
  final List<PrescriptionModel> prescriptions;

  const ConsultationDetailModel({
    required super.id,
    required super.patientId,
    required super.doctorId,
    required super.status,
    required super.consultationDate,
    required super.chiefComplaint,
    super.anamnesis,
    super.physicalExam,
    super.notes,
    required super.createdAt,
    required this.diagnoses,
    required this.prescriptions,
  });

  factory ConsultationDetailModel.fromJson(Map<String, dynamic> json) {
    final rawDiagnoses = json['diagnoses'];
    final List<dynamic> diagnosesList =
        rawDiagnoses is List ? rawDiagnoses : [];

    final rawPrescriptions = json['prescriptions'];
    final List<dynamic> prescriptionsList =
        rawPrescriptions is List ? rawPrescriptions : [];

    return ConsultationDetailModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      status: json['status'] as String? ?? 'PENDING',
      consultationDate: json['consultation_date'] != null
          ? DateTime.tryParse(json['consultation_date'] as String) ??
              DateTime.now()
          : DateTime.now(),
      chiefComplaint: json['chief_complaint'] as String? ?? '',
      anamnesis: json['anamnesis'] as String?,
      physicalExam: json['physical_exam'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      diagnoses: diagnosesList
          .map((e) => DiagnosisModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      prescriptions: prescriptionsList
          .map((e) => PrescriptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
