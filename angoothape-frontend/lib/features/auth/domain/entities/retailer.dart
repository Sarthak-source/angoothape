class Retailer {
  Retailer({
    required this.id,
    required this.name,
    required this.shop,
    required this.city,
    required this.mobile,
    this.mobileFull = '',
    required this.role,
    required this.distributor,
  });

  final String id;
  final String name;
  final String shop;
  final String city;
  final String mobile;
  final String mobileFull;
  final String role;
  final String distributor;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'AP';
    if (parts.length == 1) {
      final w = parts.first;
      return (w.length >= 2 ? w.substring(0, 2) : w.padRight(2, 'P')).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static Retailer empty() => Retailer(
    id: '',
    name: '',
    shop: '',
    city: '',
    mobile: '',
    mobileFull: '',
    role: '',
    distributor: '',
  );
}
