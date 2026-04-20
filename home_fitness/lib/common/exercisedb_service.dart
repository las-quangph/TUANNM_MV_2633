import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/exercisedb_exercise.dart';

class ExerciseDbService {
  ExerciseDbService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl =
      String.fromEnvironment(
        'EXERCISEDB_BASE_URL',
        defaultValue:
            'https://oss.exercisedb.dev',
      );
  static const String _searchPath =
      String.fromEnvironment(
        'EXERCISEDB_SEARCH_PATH',
        defaultValue: '/api/v1/exercises',
      );
  static const String _apiKey =
      String.fromEnvironment(
        'EXERCISEDB_API_KEY',
        defaultValue: 'ee8fe8d315msh2d6ad08f438f151p1fdf39jsnb917308ee4d0',
      );
  static const String _apiKeyHeader = String.fromEnvironment(
    'EXERCISEDB_API_KEY_HEADER',
    defaultValue: 'x-rapidapi-key',
  );
  static const String _hostHeader = String.fromEnvironment(
    'EXERCISEDB_HOST_HEADER',
    defaultValue: 'x-rapidapi-host',
  );
  static const String _hostValue = String.fromEnvironment(
    'EXERCISEDB_HOST_VALUE',
    defaultValue: 'edb-with-videos-and-images-by-ascendapi.p.rapidapi.com',
  );
  static const String _mediaBaseUrl = 'https://static.exercisedb.dev';


  bool get isConfigured => _baseUrl.trim().isNotEmpty;

  Future<ExerciseDbExercise?> fetchExerciseByName(String name) async {
    if (!isConfigured) {
      return null;
    }

    final baseUri = Uri.tryParse(_baseUrl.trim());
    if (baseUri == null) {
      return null;
    }

    final headers = <String, String>{
      'accept': 'application/json',
      'content-type': 'application/json',
    };
    if (_hostValue.isNotEmpty) {
      headers[_hostHeader] = _hostValue;
    }
    if (_apiKey.isNotEmpty) {
      headers[_apiKeyHeader] = _apiKey;
    }

    try {
      for (final uri in _candidateUris(baseUri, name)) {
        // Debug actual ExerciseDB requests and responses while tuning endpoints.
        print('[ExerciseDbService] request=$uri');
        final response = await _client.get(uri, headers: headers);
        print('[ExerciseDbService] status=${response.statusCode} for $uri');
        if (response.statusCode < 200 || response.statusCode >= 300) {
          continue;
        }

        final decoded = jsonDecode(response.body);
        final items = _extractItems(decoded);
        if (items.isEmpty) {
          continue;
        }

        final normalizedName = name.trim().toLowerCase();
        Map<String, dynamic>? match;
        for (final item in items) {
          final itemName = (item['name'] ?? '').toString().trim().toLowerCase();
          if (itemName == normalizedName) {
            match = item;
            break;
          }
        }
        match ??= items.first;

        return ExerciseDbExercise.fromJson(
          match,
          mediaBaseUrl: _mediaBaseUrl,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  List<Uri> _candidateUris(Uri baseUri, String name) {
    final encodedName = Uri.encodeComponent(name.trim());
    final basePath = _resolvePath(baseUri.path, _searchPath);
    final legacyPath = _resolvePath(baseUri.path, '/exercises/name/$encodedName');

    return [
      baseUri.replace(
        path: basePath,
        queryParameters: {
          'name': name,
          'limit': '10',
          'offset': '0',
        },
      ),
      baseUri.replace(
        path: '$basePath/$encodedName',
      ),
      baseUri.replace(
        path: '$basePath/name/$encodedName',
      ),
      baseUri.replace(
        path: legacyPath,
      ),
    ];
  }

  static String _resolvePath(String basePath, String configuredPath) {
    final cleanBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    final cleanPath = configuredPath.startsWith('/')
        ? configuredPath
        : '/$configuredPath';
    return '$cleanBase$cleanPath';
  }

  static List<Map<String, dynamic>> _extractItems(dynamic decoded) {
    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
    }

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList(growable: false);
      }
      final items = decoded['items'];
      if (items is List) {
        return items.whereType<Map<String, dynamic>>().toList(growable: false);
      }
    }

    return const [];
  }
}
