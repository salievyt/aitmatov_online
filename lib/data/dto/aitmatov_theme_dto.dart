import '../../domain/entities/aitmatov_theme.dart';

class AitmatovThemeDto {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? icon;

  AitmatovThemeDto({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.icon,
  });

  factory AitmatovThemeDto.fromJson(Map<String, dynamic> json) {
    return AitmatovThemeDto(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String?,
    );
  }

  AitmatovTheme toEntity() => AitmatovTheme(
        id: id,
        name: name,
        slug: slug,
        description: description,
        icon: icon,
      );
}
