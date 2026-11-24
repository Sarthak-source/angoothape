import 'package:flutter/foundation.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/utils/format.dart';
import '../../domain/entities/join_draft.dart';
import '../../domain/repositories/join_repository.dart';

mixin JoinController on ChangeNotifier {
  JoinRepository get joinRepository;
  JoinDraft get join;
  set join(JoinDraft value);

  void go(String next, {Map<String, String>? params});
  void toast(String msg, {bool sim = false});

  void startJoin() {
    join = JoinDraft();
    go('join');
  }

  void setRole(String role) {
    join.role = role;
    notifyListeners();
  }

  bool joinStepBack() {
    if (join.step <= 0) return false;
    join.step--;
    join.tried = false;
    notifyListeners();
    return true;
  }

  Future<void> joinNext(Map<String, String> fields) async {
    join.f.addAll(fields);
    join.tried = true;
    var ok = true;
    if (join.step == 1) {
      final req = [
        'name',
        'mobile',
        'biz',
        'type',
        'addr',
        'pin',
        'state',
        if (join.role != 'retailer') 'area',
      ];
      ok =
          req.every((k) => (join.f[k] ?? '').trim().isNotEmpty) &&
          validMobile(join.f['mobile'] ?? '') &&
          validPin(join.f['pin'] ?? '');
    }
    if (join.step == 2) {
      final docs = [
        'pancard',
        'shop',
        'cheque',
        if (join.role != 'retailer') 'gstc',
      ];
      ok =
          validPan(join.f['pan'] ?? '') &&
          join.ekyc &&
          join.agree &&
          docs.every((k) => join.docs.containsKey(k));
    }
    if (!ok) {
      notifyListeners();
      return;
    }
    if (join.step == 2) {
      join.busy = true;
      notifyListeners();
      try {
        final res = await joinRepository.submit(
          role: join.role,
          fields: join.f,
          docs: join.docs,
          ekycId: join.ekycId,
        );
        final app = Map<String, dynamic>.from(res['application'] as Map);
        join.applicationId = app['id'] as String?;
        join.busy = false;
      } on ApiException catch (e) {
        join.busy = false;
        toast(e.message);
        notifyListeners();
        return;
      }
    }
    join.step++;
    join.tried = false;
    notifyListeners();
  }

  void setAgree(bool v) {
    join.agree = v;
    notifyListeners();
  }

  Future<void> runEkyc([String pan = '']) async {
    join.ekycBusy = true;
    notifyListeners();
    try {
      final value = pan.trim().toUpperCase().isEmpty
          ? (join.f['pan'] ?? '').trim().toUpperCase()
          : pan.trim().toUpperCase();
      join.f['pan'] = value;
      final res = await joinRepository.startEkyc(pan: value);
      join.ekycId = (res['ekyc'] as Map?)?['id'] as String?;
      join.ekyc = true;
    } on ApiException catch (e) {
      toast(e.message);
    } finally {
      join.ekycBusy = false;
      notifyListeners();
    }
  }

  void attachDoc(String key, String name) {
    join.docs[key] = name;
    notifyListeners();
  }

  Future<void> simulateApproval() async {
    final id = join.applicationId;
    if (id == null) return;
    try {
      await joinRepository.approve(id);
      join.approved = true;
      notifyListeners();
    } on ApiException catch (e) {
      toast(e.message);
    }
  }
}
