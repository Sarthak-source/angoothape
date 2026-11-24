import '../../domain/entities/retailer.dart';

Retailer retailerFromJson(Map<String, dynamic> j) => Retailer(
  id: j['id'] as String? ?? '',
  name: j['name'] as String? ?? '',
  shop: j['shop'] as String? ?? '',
  city: j['city'] as String? ?? '',
  mobile: j['mobile'] as String? ?? '',
  mobileFull: j['mobileFull'] as String? ?? '',
  role: j['role'] as String? ?? '',
  distributor: j['distributor'] as String? ?? '',
);
