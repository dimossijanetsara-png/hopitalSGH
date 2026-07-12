import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/core/constants/api_constants.dart';
import 'package:sghl_mobile/core/network/api_client.dart';
import 'package:sghl_mobile/features/medical_records/clinical_models.dart';

class ClinicalRepository {
  final ApiClient _apiClient;

  ClinicalRepository(this._apiClient);

  Future<List<ConsultationModel>> getMyConsultations({int page = 1}) async {
    final patientId = await _apiClient.storage.getUserId();
    if (patientId == null || patientId.isEmpty) {
      throw Exception('Utilisateur non authentifié');
    }

    final response = await _apiClient.get(
      ApiConstants.consultations,
      queryParams: {
        'patient_id': patientId,
        'page': page,
        'per_page': 20,
      },
    );

    final raw = response.data;
    final List<dynamic> items =
        raw is List ? raw : (raw['items'] as List<dynamic>? ?? []);

    return items
        .map((e) => ConsultationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ConsultationDetailModel> getConsultationDetail(String id) async {
    final response = await _apiClient.get(
      '${ApiConstants.consultations}/$id',
    );

    return ConsultationDetailModel.fromJson(
        response.data as Map<String, dynamic>);
  }
}

final clinicalRepositoryProvider = Provider<ClinicalRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ClinicalRepository(apiClient);
});
