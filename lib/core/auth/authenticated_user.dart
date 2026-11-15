class AuthenticatedUser {
  const AuthenticatedUser({
    required this.name,
    required this.email,
    this.userId,
    this.companyId,
    this.companyName,
    this.jobTitle,
    this.role,
  });

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) =>
      AuthenticatedUser(
        name: json['nome'] as String,
        email: json['email'] as String,
        userId: json['usuarioId'] as String?,
        companyId: json['empresaId'] as String?,
      );

  factory AuthenticatedUser.fromProfileJson(Map<String, dynamic> json) {
    final company = json['empresa'] as Map<String, dynamic>;
    return AuthenticatedUser(
      name: json['nome'] as String,
      email: json['email'] as String,
      userId: json['id'] as String,
      companyId: company['id'] as String,
      companyName: company['nome'] as String,
      jobTitle: json['cargo'] as String?,
      role: json['papel'] as String?,
    );
  }

  final String name;
  final String email;
  final String? userId;
  final String? companyId, companyName, jobTitle, role;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    return [
      parts.first,
      if (parts.length > 1) parts.last,
    ].map((part) => String.fromCharCode(part.runes.first)).join().toUpperCase();
  }
}
