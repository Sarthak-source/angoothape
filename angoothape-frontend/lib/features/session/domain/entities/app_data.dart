import '../../../auth/domain/entities/retailer.dart';
import '../../../home/domain/entities/bank_account.dart';
import '../../../home/domain/entities/settlement.dart';
import '../../../home/domain/entities/txn.dart';
import '../../../home/domain/entities/wallet.dart';
import '../../../support/domain/entities/ticket.dart';

class AppData {
  AppData({
    required this.retailer,
    required this.tx,
    required this.wallet,
    required this.settlements,
    required this.accounts,
    required this.tickets,
  }) {
    index();
  }
  Retailer retailer;
  final List<Txn> tx;
  final Wallet wallet;
  final List<Settlement> settlements;
  final List<BankAccount> accounts;
  final List<Ticket> tickets;
  final Map<String, Txn> txByRef = {};
  final Map<String, Ticket> ticketById = {};
  final Map<String, List<Ticket>> ticketsByRef = {};
  final Map<String, String> last4ByBank = {};

  void index() {
    txByRef
      ..clear()
      ..addEntries(tx.map((x) => MapEntry(x.ref, x)));
    ticketById
      ..clear()
      ..addEntries(tickets.map((k) => MapEntry(k.id, k)));
    ticketsByRef.clear();
    for (final k in tickets) {
      final ref = k.ref;
      if (ref != null && ref.isNotEmpty) {
        (ticketsByRef[ref] ??= []).add(k);
      }
    }
    last4ByBank.clear();
    for (final a in accounts) {
      last4ByBank.putIfAbsent(a.bank, () => a.last4);
    }
  }

  void replaceTx(Iterable<Txn> next) {
    tx
      ..clear()
      ..addAll(next);
    txByRef
      ..clear()
      ..addEntries(tx.map((x) => MapEntry(x.ref, x)));
  }

  void prependTx(Txn x) {
    tx.insert(0, x);
    txByRef[x.ref] = x;
  }

  void putTx(Txn next) {
    final i = tx.indexWhere((t) => t.ref == next.ref);
    if (i >= 0) tx[i] = next;
    txByRef[next.ref] = next;
  }

  void addAccount(BankAccount a) {
    accounts.add(a);
    last4ByBank.putIfAbsent(a.bank, () => a.last4);
  }

  void prependTicket(Ticket k) {
    tickets.insert(0, k);
    ticketById[k.id] = k;
    final ref = k.ref;
    if (ref != null && ref.isNotEmpty) {
      (ticketsByRef[ref] ??= []).insert(0, k);
    }
  }
}

AppData emptyAppData() => AppData(
  retailer: Retailer.empty(),
  tx: [],
  wallet: Wallet(main: 0, aeps: 0, earn: 0),
  settlements: [],
  accounts: [],
  tickets: [],
);
