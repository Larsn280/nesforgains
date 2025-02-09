class UserData {
  String id;
  String username;
  bool? isloggedin;

  UserData({
    required this.id,
    required this.username,
    this.isloggedin,
  });
}
