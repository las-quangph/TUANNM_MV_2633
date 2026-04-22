class ExerciseDbExercise {
  const ExerciseDbExercise({
    required this.id,
    required this.name,
    this.gifUrl,
    this.imageUrl,
    this.overview,
    this.instructions = const [],
    this.tips = const [],
    this.targetMuscles = const [],
    this.secondaryMuscles = const [],
    this.equipments = const [],
    this.exerciseType,
    this.level,
  });

  final String id;
  final String name;
  final String? gifUrl;
  final String? imageUrl;
  final String? overview;
  final List<String> instructions;
  final List<String> tips;
  final List<String> targetMuscles;
  final List<String> secondaryMuscles;
  final List<String> equipments;
  final String? exerciseType;
  final String? level;

  factory ExerciseDbExercise.fromJson(
    Map<String, dynamic> json, {
    String? mediaBaseUrl,
  }) {
    return ExerciseDbExercise(
      id: (json['exerciseId'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      gifUrl: _pickGifUrl(json),
      imageUrl: _pickImageUrl(json),
      overview: json['overview']?.toString(),
      instructions: _toStringList(json['instructions']),
      tips: _toStringList(json['exerciseTips']),
      targetMuscles: _toStringList(json['targetMuscles']),
      secondaryMuscles: _toStringList(json['secondaryMuscles']),
      equipments: _toStringList(json['equipments']),
      exerciseType: _pickExerciseType(json),
      level: json['difficulty']?.toString() ?? json['level']?.toString(),
    );
  }

  static String? _pickGifUrl(Map<String, dynamic> json) {
    final singleGif = json['gifUrl']?.toString();
    if (singleGif != null && singleGif.isNotEmpty) {
      return singleGif;
    }

    final gifUrls = json['gifUrls'];
    if (gifUrls is Map) {
      for (final key in const ['720p', '480p', '360p']) {
        final value = gifUrls[key]?.toString();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
      for (final value in gifUrls.values) {
        final stringValue = value?.toString();
        if (stringValue != null && stringValue.isNotEmpty) {
          return stringValue;
        }
      }
    }

    return null;
  }

  static String? _pickImageUrl(Map<String, dynamic> json) {
    final singleImage = json['imageUrl']?.toString();
    if (singleImage != null && singleImage.isNotEmpty) {
      return singleImage;
    }

    final imageUrls = json['imageUrls'];
    if (imageUrls is Map) {
      for (final key in const ['720p', '480p', '360p']) {
        final value = imageUrls[key]?.toString();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
      for (final value in imageUrls.values) {
        final stringValue = value?.toString();
        if (stringValue != null && stringValue.isNotEmpty) {
          return stringValue;
        }
      }
    }

    return null;
  }

  static String? _pickExerciseType(Map<String, dynamic> json) {
    final direct = json['exerciseType']?.toString();
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    final list = json['exerciseTypes'];
    if (list is List && list.isNotEmpty) {
      return list.first.toString();
    }

    return null;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    return value.map((item) => item.toString()).toList(growable: false);
  }
}
