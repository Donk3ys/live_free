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

  int get totalSavings {
    int total = 0;
    for (final saving in savingList) {
      total = total + saving.amount;
    }
    return total;
  }

  Future<void> fetchSavingList(
    BuildContext context,
  ) async =>
      _makeCall(context, () async {
        _setState(_State.fetchingSaving);
        savingList = await _financeRepository.fetchSavingList();
      });

  Future<bool> addSaving(
    BuildContext context,
    Saving saving,
  ) async {
    try {
      _setState(_State.addingSaving);

      final newSaving = saving.copyWith(uuid: const Uuid().v1());

      await _financeRepository.addSaving(newSaving);
      savingList.add(newSaving);
      // await Future.delayed(const Duration(milliseconds: 1000));
      _setState(_State.idle);
      return true;
    } catch (e, s) {
      ViewModelUtil.handleException(
        e,
        s,
        context: context,
      );
      _setState(_State.idle);
      return false;
    }
  }

  Future<void> removeSaving(
    BuildContext context,
    Saving saving,
  ) async =>
      _makeCall(context, () async {
        _setState(_State.removingSaving);

        await _financeRepository.removeSaving(saving);
        savingList.remove(saving);
      });

  // NOTE: wrapper for return void
  Future<void> _makeCall(BuildContext context, Function call) async {
    try {
      call();
    } catch (e, s) {
      ViewModelUtil.handleException(
        e,
        s,
        context: context,
      );
    }
    //await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
  }
}
