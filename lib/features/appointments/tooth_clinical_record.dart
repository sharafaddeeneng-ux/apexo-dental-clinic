/// A diagnosis or procedure recorded for one FDI-numbered tooth in a visit.
class ToothClinicalRecord {
  const ToothClinicalRecord({
    required this.id,
    required this.tooth,
    required this.recordedAt,
    this.diagnosis = '',
    this.treatment = '',
    this.notes = '',
  });

  final String id;
  final String tooth;
  final DateTime recordedAt;
  final String diagnosis;
  final String treatment;
  final String notes;

  factory ToothClinicalRecord.fromJson(Map<String, dynamic> json) {
    return ToothClinicalRecord(
      id: json['id'] as String? ?? '',
      tooth: json['tooth'] as String? ?? '',
      recordedAt: DateTime.tryParse(json['recordedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      diagnosis: json['diagnosis'] as String? ?? '',
      treatment: json['treatment'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tooth': tooth,
        'recordedAt': recordedAt.toIso8601String(),
        if (diagnosis.trim().isNotEmpty) 'diagnosis': diagnosis.trim(),
        if (treatment.trim().isNotEmpty) 'treatment': treatment.trim(),
        if (notes.trim().isNotEmpty) 'notes': notes.trim(),
      };
}
