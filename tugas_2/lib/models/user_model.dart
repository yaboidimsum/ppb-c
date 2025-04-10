class User {
  final String username;
  final String password;
  final String? email;

  User({required this.username, required this.password, this.email});

  Map<String, dynamic> toMap() => {'password': password, 'email': email};

  static User fromMap(String username, Map<dynamic, dynamic> map) {
    return User(
      username: username,
      password: map['password'],
      email: map['email'],
    );
  }
}
