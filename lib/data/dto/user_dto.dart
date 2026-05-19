import '../../domain/entities/user.dart';

class UserDto {
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

  UserDto({
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

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      username: json['username'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      avatarUrl: (json['avatar_url'] ?? json['avatar']) as String?,
      role: ((json['role'] ?? 'student') as String).trim().toLowerCase(),
      classLevel: json['class_level'] as int?,
      school: json['school'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'role': role,
      'class_level': classLevel,
      'school': school,
    };
  }

  User toEntity() => User(
        id: id,
        email: email,
        phone: phone,
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarUrl: avatarUrl,
        role: role,
        classLevel: classLevel,
        school: school,
      );
}
