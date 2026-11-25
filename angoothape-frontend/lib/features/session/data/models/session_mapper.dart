import '../../../aeps/data/models/aeps_mappers.dart';
import '../../../auth/data/models/retailer_mapper.dart';
import '../../../home/data/models/home_mappers.dart';
import '../../../support/data/models/ticket_mapper.dart';
import '../../domain/entities/app_data.dart';
import '../../domain/entities/catalog.dart';

export '../../../aeps/data/models/aeps_mappers.dart';
export '../../../auth/data/models/retailer_mapper.dart';
export '../../../home/data/models/home_mappers.dart';
export '../../../support/data/models/ticket_mapper.dart';

void applyCatalogJson(Map<String, dynamic> json) {
  Map<String, List<(String, String)>> langPairs(
    Object? raw, {
    required String a,
    required String b,
  }) {
    final map = Map<String, dynamic>.from(raw as Map? ?? {});
    return {
      for (final e in map.entries)
        e.key: [
          for (final x in e.value as List? ?? [])
            if (x is Map) ((x[a] ?? '').toString(), (x[b] ?? '').toString()),
        ],
    };
  }

  Map<String, List<String>> langStrings(Object? raw) {
    final map = Map<String, dynamic>.from(raw as Map? ?? {});
    return {
      for (final e in map.entries)
        e.key: [for (final x in e.value as List? ?? []) x.toString()],
    };
  }

  applyCatalog(
    nextBanks: [
      for (final x in json['banks'] as List? ?? [])
        bankFromJson(Map<String, dynamic>.from(x as Map)),
    ],
    nextFaqs: langPairs(json['faqs'], a: 'q', b: 'a'),
    nextIssues: langStrings(json['issues']),
    nextFuture: langPairs(json['futureServices'], a: 'id', b: 'label'),
    nextGuides: {
      for (final e in Map<String, dynamic>.from(
        json['deviceGuides'] as Map? ?? {},
      ).entries)
        e.key: {
          for (final lang in Map<String, dynamic>.from(e.value as Map).entries)
            lang.key: [
              for (final step in lang.value as List? ?? []) step.toString(),
            ],
        },
    },
    nextDeviceFaqs: {
      for (final e in Map<String, dynamic>.from(
        json['deviceFaqs'] as Map? ?? {},
      ).entries)
        e.key: [
          for (final x in e.value as List? ?? [])
            if (x is Map)
              (
                (x['q'] ?? '').toString(),
                [for (final a in x['a'] as List? ?? []) a.toString()],
              ),
        ],
    },
    nextReasons: {
      for (final e in Map<String, dynamic>.from(
        json['failReasons'] as Map? ?? {},
      ).entries)
        e.key: reasonFromJson(Map<String, dynamic>.from(e.value as Map)),
    },
  );
}

AppData appDataFromSession(Map<String, dynamic> json) {
  final wallet = walletFromJson(
    Map<String, dynamic>.from(json['wallet'] as Map? ?? {}),
  );
  return AppData(
    retailer: retailerFromJson(
      Map<String, dynamic>.from(json['retailer'] as Map? ?? {}),
    ),
    tx: [
      for (final x in json['tx'] as List? ?? [])
        txnFromJson(Map<String, dynamic>.from(x as Map)),
    ],
    wallet: wallet,
    settlements: [
      for (final x in json['settlements'] as List? ?? [])
        settlementFromJson(Map<String, dynamic>.from(x as Map)),
    ],
    accounts: [
      for (final x in json['accounts'] as List? ?? [])
        accountFromJson(Map<String, dynamic>.from(x as Map)),
    ],
    tickets: [
      for (final x in json['tickets'] as List? ?? [])
        ticketFromJson(Map<String, dynamic>.from(x as Map)),
    ],
  );
}
