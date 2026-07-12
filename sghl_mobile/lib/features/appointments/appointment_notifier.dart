import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/features/appointments/appointment_models.dart';
import 'package:sghl_mobile/features/appointments/appointment_repository.dart';

class AppointmentsNotifier
    extends StateNotifier<AsyncValue<List<AppointmentModel>>> {
  final AppointmentRepository _repository;

  AppointmentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    state = const AsyncValue.loading();
    try {
      final appointments = await _repository.getMyAppointments();
      state = AsyncValue.data(appointments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => loadAppointments();

  Future<void> cancelAppointment(String id, {String? reason}) async {
    try {
      await _repository.cancelAppointment(id, reason: reason);
      await loadAppointments();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final appointmentsProvider = StateNotifierProvider<AppointmentsNotifier,
    AsyncValue<List<AppointmentModel>>>((ref) {
  final repository = ref.watch(appointmentRepositoryProvider);
  return AppointmentsNotifier(repository);
});

final upcomingAppointmentsProvider =
    FutureProvider<List<AppointmentModel>>((ref) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getMyAppointments(status: 'CONFIRMED');
});
