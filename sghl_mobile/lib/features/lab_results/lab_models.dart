class LabOrderItemModel {
  final String id;
  final String testId;
  final String? resultValue;
  final String? resultUnit;
  final bool isAbnormal;
  final String? notes;
  final DateTime? resultedAt;

  const LabOrderItemModel({
    required this.id,
    required this.testId,
    this.resultValue,
    this.resultUnit,
    required this.isAbnormal,
    this.notes,
    this.resultedAt,
  });

  factory LabOrderItemModel.fromJson(Map<String, dynamic> json) {
    return LabOrderItemModel(
      id: json['id']?.toString() ?? '',
      testId: json['test_id']?.toString() ?? '',
      resultValue: json['result_value'] as String?,
      resultUnit: json['result_unit'] as String?,
      isAbnormal: json['is_abnormal'] as bool? ?? false,
      notes: json['notes'] as String?,
      resultedAt: json['resulted_at'] != null
          ? DateTime.tryParse(json['resulted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'test_id': testId,
      if (resultValue != null) 'result_value': resultValue,
      if (resultUnit != null) 'result_unit': resultUnit,
      'is_abnormal': isAbnormal,
      if (notes != null) 'notes': notes,
      if (resultedAt != null) 'resulted_at': resultedAt!.toIso8601String(),
    };
  }

  bool get hasResult => resultValue != null && resultValue!.isNotEmpty;

  String get resultDisplay {
    if (!hasResult) return 'En attente';
    if (resultUnit != null && resultUnit!.isNotEmpty) {
      return '$resultValue $resultUnit';
    }
    return resultValue!;
  }
}

class LabOrderModel {
  final String id;
  final String patientId;
  final String orderedById;
  final String status;
  final String priority;
  final String? clinicalNotes;
  final DateTime? sampledAt;
  final DateTime? validatedAt;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final List<LabOrderItemModel> items;

  const LabOrderModel({
    required this.id,
    required this.patientId,
    required this.orderedById,
    required this.status,
    required this.priority,
    this.clinicalNotes,
    this.sampledAt,
    this.validatedAt,
    this.publishedAt,
    required this.createdAt,
    required this.items,
  });

  factory LabOrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final List<dynamic> itemsList =
        rawItems is List ? rawItems : [];

    return LabOrderModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      orderedById: json['ordered_by_id']?.toString() ?? '',
      status: json['status'] as String? ?? 'ORDERED',
      priority: json['priority'] as String? ?? 'NORMAL',
      clinicalNotes: json['clinical_notes'] as String?,
      sampledAt: json['sampled_at'] != null
          ? DateTime.tryParse(json['sampled_at'] as String)
          : null,
      validatedAt: json['validated_at'] != null
          ? DateTime.tryParse(json['validated_at'] as String)
          : null,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      items: itemsList
          .map((e) => LabOrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'ordered_by_id': orderedById,
      'status': status,
      'priority': priority,
      if (clinicalNotes != null) 'clinical_notes': clinicalNotes,
      if (sampledAt != null) 'sampled_at': sampledAt!.toIso8601String(),
      if (validatedAt != null) 'validated_at': validatedAt!.toIso8601String(),
      if (publishedAt != null) 'published_at': publishedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  bool get isUrgent => priority == 'URGENT';

  bool get isPublished => status == 'PUBLISHED';

  bool get hasAbnormalResults => items.any((i) => i.isAbnormal);

  int get resultedCount => items.where((i) => i.hasResult).length;
}
