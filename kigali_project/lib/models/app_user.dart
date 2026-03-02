class AppUser {
  final String uid;
  final String email;
  final String? name;

  AppUser({
    required this.uid,
    required this.email,
    this.name,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
    };
  }
}
