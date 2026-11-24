class Bank {
  Bank({
    required this.id,
    required this.name,
    required this.short,
    required this.color,
    required this.popular,
    this.ifscPrefix,
  });
  final String id;
  final String name;
  final String short;
  final int color;
  final bool popular;
  final String? ifscPrefix;

  late final String nameLower = name.toLowerCase();
  late final String shortLower = short.toLowerCase();
}

List<Bank> banks = <Bank>[];
List<Bank> popularBanks = const <Bank>[];
final Map<String, Bank> _banksById = {};

Bank? bankById(String? id) => id == null ? null : _banksById[id];

Map<String, String> ifscBank = <String, String>{};

void applyBanks(List<Bank> nextBanks) {
  banks
    ..clear()
    ..addAll(nextBanks);
  _banksById
    ..clear()
    ..addEntries(nextBanks.map((b) => MapEntry(b.id, b)));
  popularBanks = [for (final b in nextBanks) if (b.popular) b];
  ifscBank
    ..clear()
    ..addAll({
      for (final b in nextBanks)
        if (b.ifscPrefix != null && b.ifscPrefix!.isNotEmpty)
          b.ifscPrefix!: b.id,
    });
}
