import '../../domain/entities/subject.dart';

class SubjectDto {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;

  SubjectDto({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
  });

  factory SubjectDto.fromJson(Map<String, dynamic> json) {
    return SubjectDto(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? 'Без названия',
      slug: (json['slug'] as String?) ?? 'unknown',
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Subject toEntity() => Subject(
        id: id,
        name: name,
        slug: slug,
        description: description,
        icon: icon,
      );
}
