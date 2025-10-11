class TVShow {
  final int id;
  final String? name;
  final String? originalName;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? firstAirDate;
  final double? voteAverage;
  final int? voteCount;
  final String? originalLanguage;
  final List<int>? genreIds;
  final double? popularity;
  final String? mediaType;
  final List<String>? originCountry;

  TVShow({
    required this.id,
    this.name,
    this.originalName,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.firstAirDate,
    this.voteAverage,
    this.voteCount,
    this.originalLanguage,
    this.genreIds,
    this.popularity,
    this.mediaType,
    this.originCountry,
  });

  factory TVShow.fromJson(Map<String, dynamic> json) {
    return TVShow(
      id: json['id'] ?? 0,
      name: json['name'],
      originalName: json['original_name'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      firstAirDate: json['first_air_date'],
      voteAverage: json['vote_average']?.toDouble(),
      voteCount: json['vote_count'],
      originalLanguage: json['original_language'],
      genreIds: json['genre_ids']?.cast<int>(),
      popularity: json['popularity']?.toDouble(),
      mediaType: json['media_type'],
      originCountry: json['origin_country']?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'original_name': originalName,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'first_air_date': firstAirDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'original_language': originalLanguage,
      'genre_ids': genreIds,
      'popularity': popularity,
      'media_type': mediaType,
      'origin_country': originCountry,
    };
  }

  String get fullPosterPath {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get fullBackdropPath {
    if (backdropPath == null) return '';
    return 'https://image.tmdb.org/t/p/w1280$backdropPath';
  }
}
