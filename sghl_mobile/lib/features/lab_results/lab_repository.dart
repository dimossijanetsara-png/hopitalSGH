import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/core/constants/api_constants.dart';
import 'package:sghl_mobile/core/network/api_client.dart';
import 'package:sghl_mobile/features/lab_results/lab_models.dart';

class LabRepository {
  final ApiClient _apiClient;

  LabRepository(this._apiClient);

  Future<List<LabOrderModel>> getMyLabOrders({String? status}) async {
    final patientId = await _apiClient.storage.getUserId();
    if (patientId == null || patientId.isEmpty) {
      throw Exception('Utilisateur non authentifie');
    }

    final queryParams = <String, dynamic>{
      'patient_id': patientId,
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      ApiConstants.labOrders,
      queryParams: queryParams,
    );

    final raw = response.data;
    final List<dynamic> items =
        raw is List ? raw : (raw['items'] as List<dynamic>? ?? []);

    return items
        .map((e) => LabOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LabOrderModel> getLabOrderDetail(String id) async {
    final response = await _apiClient.get(
      '${ApiConstants.labOrders}/$id',
    );

    return LabOrderModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final labRepositoryProvider = Provider<LabRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LabRepository(apiClient);
});
