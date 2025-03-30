class LoginData {
  String email;
  String username;
  bool? isloggedin;

  LoginData({
    required this.email,
    required this.username,
    this.isloggedin,
  });
}
