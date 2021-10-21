import 'package:flutter/material.dart';
import 'package:live_free/data_models/saving.dart';
import 'package:live_free/repositories/finance_repo.dart';
import 'package:live_free/view_models/utils_vm.dart';
import 'package:uuid/uuid.dart';

enum _State { idle, error, fetchingSaving, addingSaving, removingSaving }

class SavingViewModel extends ChangeNotifier {
  final FinanceRepository _financeRepository;
  SavingViewModel({
    required FinanceRepository financeRepository,
  }) : _financeRepository = financeRepository;

  _State _state = _State.fetchingSaving;
  void _setState(_State viewState) {
    _state = viewState;
    notifyListeners();
  }

  List<Saving> savingList = const [];

  bool get isFetchingSaving => _state == _State.fetchingSaving;
  bool get isAddingSaving => _state == _State.addingSaving;
  bool get isRemovingSaving => _state == _State.removingSaving;
  bool get hasError => _state == _State.error;

  Future<void> fetchSavingList(BuildContext context) async {
    _setState(_State.fetchingSaving);

    final failOrList = await _financeRepository.fetchSavingList();
    failOrList.fold(
      (failure) {
        ViewModelUtil.handleFailure(
          context: context,
          failure: failure,
        );
      },
      (list) {
        savingList = list;
      },
    );

    // await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
  }

  Future<bool> addSaving(
    BuildContext context,
    Saving saving,
  ) async {
    _setState(_State.addingSaving);
    bool success = false;

    final newSaving = saving.copyWith(uuid: const Uuid().v1());

    final failOrSuccess = await _financeRepository.addSaving(newSaving);
    failOrSuccess.fold(
      (failure) {
        ViewModelUtil.handleFailure(
          context: context,
          failure: failure,
        );
      },
      (_) {
        savingList.add(newSaving);
        success = true;
      },
    );

    // await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
    return success;
  }

  Future<void> removeSaving(
    BuildContext context,
    Saving saving,
  ) async {
    _setState(_State.removingSaving);

    final failOrSuccess = await _financeRepository.removeSaving(saving);
    failOrSuccess.fold(
      (failure) {
        ViewModelUtil.handleFailure(
          context: context,
          failure: failure,
        );
      },
      (_) {
        savingList.remove(saving);
      },
    );

    // await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
  }
}
