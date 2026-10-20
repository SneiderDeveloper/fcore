class AppContextAuthProvider {
  final int id;
  final String name;
  final String alias;
  final bool status;
  final Map<String, dynamic>? options;
  final Map<String, dynamic> rawData;

  AppContextAuthProvider.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      name = json['name'] as String,
      alias = json['alias'] as String,
      status = json['status'] as bool,
      options = json['options'] == null
          ? null
          : Map<String, dynamic>.unmodifiable(
              json['options'] as Map<String, dynamic>,
            ),
      rawData = Map<String, dynamic>.unmodifiable(json);
}
