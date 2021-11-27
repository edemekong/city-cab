class Rate {
  final String uid;
  final String subject;
  final String body;
  final double stars;

  const Rate({required this.uid, required this.subject, required this.body, required this.stars});

  factory Rate.fromMap(Map<String, dynamic> data) {
    return Rate(
      body: data['body'] ?? '',
      stars: data['stars'] ?? 0,
      subject: data['subject'] ?? '',
      uid: data['uid'] ?? '',
    );
  }
}
