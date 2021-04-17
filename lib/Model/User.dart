class User {
  int userId;
  String firstName;
  String surename;
  String password;
  String email;
  String profilePic;
  String username;

  User(
      {this.userId,
        this.firstName,
        this.surename,
        this.password,
        this.email,
        this.profilePic,
        this.username});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    firstName = json['first_name'];
    surename = json['surename'];
    password = json['password'];
    email = json['email'];
    username = json['username'];
    profilePic = json['profile_pic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['first_name'] = this.firstName;
    data['surename'] = this.surename;
    data['password'] = this.password;
    data['email'] = this.email;
    data['username'] = this.username;
    data['profile_pic'] = this.profilePic;

    return data;
  }
}

