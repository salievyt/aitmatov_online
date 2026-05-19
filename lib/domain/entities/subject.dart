import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;

  const Subject({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
  });

  @override
  List<Object?> get props => [id, name, slug, description, icon];
}
