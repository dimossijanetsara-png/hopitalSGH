import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/features/medical_records/clinical_models.dart';
import 'package:sghl_mobile/features/medical_records/clinical_repository.dart';

class ConsultationsNotifier
    extends StateNotifier<AsyncValue<List<ConsultationModel>>> {
  final ClinicalRepository _repository;

  ConsultationsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadConsultations();
  }

  Future<void> loadConsultations({int page = 1}) async {
    state = const AsyncValue.loading();
    try {
      final consultations =
          await _repository.getMyConsultations(page: page);
      state = AsyncValue.data(consultations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => loadConsultations();
}

final consultationsProvider = StateNotifierProvider<ConsultationsNotifier,
    AsyncValue<List<ConsultationModel>>>((ref) {
  final repository = ref.watch(clinicalRepositoryProvider);
  return ConsultationsNotifier(repository);
});

final consultationDetailProvider =
    FutureProvider.family<ConsultationDetailModel, String>((ref, id) async =>
        ref.watch(clinicalRepositoryProvider).getConsultationDetail(id));
