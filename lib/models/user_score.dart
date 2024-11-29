class UserScore {
  String? userid;
  String? date;
  String? username;
  String? exercise;
  int? maxlift;

  UserScore(
      {this.userid, this.date, this.username, this.exercise, this.maxlift});

  // Method to compare two UserScore objects
  bool isEqual(UserScore other) {
    return this.userid == other.userid &&
        this.username == other.username &&
        this.exercise == other.exercise &&
        this.maxlift ==
            other
                .maxlift; // Optional: include maxlift if you want to compare it
  }
}
