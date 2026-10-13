class UserModel {
  final String name;
  final String email;
  final String job;
  final String status;
  final String userType;

  UserModel({
    required this.name,
    required this.email,
    required this.job,
    required this.status,
    required this.userType,
  });
  factory UserModel.fromDocument(Map<String, dynamic> data) {
    return UserModel(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      job: data['job'] ?? '',
      status: data['status'] ?? '',
      userType: data['user_type'] ?? '',
    );
  }
}
