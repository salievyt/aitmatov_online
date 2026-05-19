import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String? email;
  final String? phone;
  final String? username;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String role;
  final int? classLevel;
  final String? school;

  const User({
    required this.id,
    this.email,
    this.phone,
    this.username,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.role,
    this.classLevel,
    this.school,
  });

  String get fullName => '$firstName $lastName';
  String get displayName => (username != null && username!.isNotEmpty) ? '@$username' : fullName;
  String get normalizedRole => role.trim().toLowerCase();
  bool get isStudent => normalizedRole == 'student';
  bool get isTeacher => normalizedRole == 'teacher';
  bool get isAdmin => normalizedRole == 'admin';

  String get roleLabel {
    if (isTeacher) return 'Учитель';
    if (isAdmin) return 'Администратор';
    return 'Студент';
  }

  @override
  List<Object?> get props => [id, email, phone, username, firstName, lastName, avatarUrl, role, classLevel, school];
}
