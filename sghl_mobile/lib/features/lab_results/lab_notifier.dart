import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/features/lab_results/lab_models.dart';
import 'package:sghl_mobile/features/lab_results/lab_repository.dart';

class LabOrdersNotifier
    extends StateNotifier<AsyncValue<List<LabOrderModel>>> {
  final LabRepository _repository;

  LabOrdersNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadLabOrders();
  }

  Future<void> loadLabOrders({String? status}) async {
    state = const AsyncValue.loading();
    try {
      final orders = await _repository.getMyLabOrders(status: status);
      // Sort by newest first
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => loadLabOrders();
}

final labOrdersProvider = StateNotifierProvider<LabOrdersNotifier,
    AsyncValue<List<LabOrderModel>>>((ref) {
  final repository = ref.watch(labRepositoryProvider);
  return LabOrdersNotifier(repository);
});

final labOrderDetailProvider =
    FutureProvider.family<LabOrderModel, String>((ref, id) async {
  final repository = ref.watch(labRepositoryProvider);
  return repository.getLabOrderDetail(id);
});
