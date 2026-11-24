import '../../../../core/enums.dart';

class AepsDraft {
  AepsStep step = AepsStep.details;
  String service = 'cw';
  String mobile = '';
  String aadhaar = '';
  String idType = 'aadhaar';
  bool showId = false;
  String? bank;
  String amount = '';
  bool consent = false;
  bool consentTried = false;
  bool tried = false;
  CapturePhase capture = CapturePhase.idle;
  int attempts = 0;
  bool devChecking = false;
  String? resultRef;
  int procStep = 0;
  bool offline = false;

  AepsDraft copyKeep() => AepsDraft()
    ..service = service
    ..mobile = mobile
    ..bank = bank
    ..amount = amount;
}
