import '../../../../core/enums.dart';

class SheetModel {
  SheetModel(this.kind);
  final SheetKind kind;
  String q = '';
  String ref = '';
  String amt = '';
  bool tried = false;
  Map<String, String> f = {};
}
