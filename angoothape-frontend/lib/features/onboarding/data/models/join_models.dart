/// Join payloads are maps until a typed application model is needed.
class JoinApplication {
  const JoinApplication({required this.id});
  final String id;

  factory JoinApplication.fromJson(Map<String, dynamic> json) {
    return JoinApplication(id: json['id'] as String? ?? '');
  }
}
