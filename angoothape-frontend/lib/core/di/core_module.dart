import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/http_client.dart';
import '../responsive/layout_service.dart';

final httpClientProvider = Provider<HttpClient>((ref) => HttpClient());

final layoutServiceProvider = Provider<LayoutService>(
  (ref) => const LayoutService(),
);

class ViewportWidth extends Notifier<double> {
  @override
  double build() => 390;

  void update(double width) {
    if ((state - width).abs() < 1) return;
    state = width;
  }
}

final viewportWidthProvider = NotifierProvider<ViewportWidth, double>(
  ViewportWidth.new,
);

final layoutProfileProvider = Provider<LayoutProfile>((ref) {
  final width = ref.watch(viewportWidthProvider);
  return ref.watch(layoutServiceProvider).resolve(width);
});
