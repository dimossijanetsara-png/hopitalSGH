import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/core/constants/api_constants.dart';
import 'package:sghl_mobile/core/network/api_client.dart';
import 'package:sghl_mobile/features/appointments/appointment_models.dart';

class AppointmentRepository {
  final ApiClient _apiClient;

  AppointmentRepository(this._apiClient);

  Future<List<AppointmentModel>> getMyAppointments({String? status}) async {
    final patientId = await _apiClient.storage.getUserId();
    if (patientId == null || patientId.isEmpty) {
      throw Exception('Utilisateur non authentifié');
    }

    final queryParams = <String, dynamic>{
      'patient_id': patientId,
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      ApiConstants.appointments,
      queryParams: queryParams,
    );

    final raw = response.data;
    final List<dynamic> items =
        raw is List ? raw : (raw['items'] as List<dynamic>? ?? []);

    return items
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getDoctors() async {
    final response = await _apiClient.get('/rendez-vous/medecins');
    final raw = response.data;
    final List<dynamic> items = raw is List ? raw : (raw['items'] as List<dynamic>? ?? []);
    return items.cast<Map<String, dynamic>>();
  }

  Future<AppointmentModel> createAppointment({
    required String doctorId,
    required DateTime appointmentDate,
    required String reason,
    String? notes,
    int durationMinutes = 30,
  }) async {
    // patient_id non envoyé : le backend le résout depuis le JWT pour le rôle PATIENT
    final body = <String, dynamic>{
      'doctor_id': doctorId,
      'appointment_date': appointmentDate.toIso8601String(),
      'duration_minutes': durationMinutes,
      'reason': reason,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final response = await _apiClient.post(
      ApiConstants.appointments,
      data: body,
    );

    return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AppointmentModel> cancelAppointment(
    String id, {
    String? reason,
  }) async {
    final body = <String, dynamic>{
      'status': 'CANCELLED',
      if (reason != null && reason.isNotEmpty) 'cancellation_reason': reason,
    };

    final response = await _apiClient.patch(
      '${ApiConstants.appointments}/$id',
      data: body,
    );

    return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<DoctorAvailability>> getDoctorAvailability(
      String doctorId) async {
    final response = await _apiClient.get(
      '${ApiConstants.doctorAvailability}/$doctorId',
    );

    final raw = response.data;
    final List<dynamic> items =
        raw is List ? raw : (raw['items'] as List<dynamic>? ?? []);

    return items
        .map((e) => DoctorAvailability.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AppointmentRepository(apiClient);
});
