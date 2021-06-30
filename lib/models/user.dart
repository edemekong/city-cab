class User {
  String? uid;
  String? firstname;
  String? lastname;
  String? email;
  DateTime? createAt;
  bool? isVerified;

  User.fromJson(String? uid, Map<String, dynamic> data) {
    this.uid = uid;
    if (data.containsKey('isVerified')) {
      isVerified = data['isVerified'];
    }
    if (data.containsKey('firstname')) {
      firstname = data['firstname'];
    }
    if (data.containsKey('lastname')) {
      lastname = data['lastname'];
    }
    if (data.containsKey('email')) {
      email = data['email'];
    }
    if (data.containsKey('createAt')) {
      createAt = DateTime.fromMillisecondsSinceEpoch(data['createdAt'].millisecondsSinceEpoch);
    }
  }
}
