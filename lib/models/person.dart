class Person {
  final int id;
  final String? name;
  final String? originalName;
  final String? profilePath;
  final bool? adult;
  final double? popularity;
  final String? knownForDepartment;
  final String? mediaType;
  final List<dynamic>? knownFor;

  Person({
    required this.id,
    this.name,
    this.originalName,
    this.profilePath,
    this.adult,
    this.popularity,
    this.knownForDepartment,
    this.mediaType,
    this.knownFor,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] ?? 0,
      name: json['name'],
      originalName: json['original_name'],
      profilePath: json['profile_path'],
      adult: json['adult'],
      popularity: json['popularity']?.toDouble(),
      knownForDepartment: json['known_for_department'],
      mediaType: json['media_type'],
      knownFor: json['known_for'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'original_name': originalName,
      'profile_path': profilePath,
      'adult': adult,
      'popularity': popularity,
      'known_for_department': knownForDepartment,
      'media_type': mediaType,
      'known_for': knownFor,
    };
  }

  String get fullProfilePath {
    if (profilePath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$profilePath';
  }
}
