class UserData {
  String id;
  String username;
  String? email;
  bool? isloggedin;

  UserData({
    required this.id,
    required this.username,
    this.email,
    this.isloggedin,
  });
}
