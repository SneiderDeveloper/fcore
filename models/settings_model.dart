class AppSetting {
  final String name;
  final dynamic value;
  final String? type;
  final Map<String, dynamic>? props;
  final String? plainValue;

  AppSetting({
    required this.name,
    required this.value,
    this.type,
    this.props,
    this.plainValue,
  });

  factory AppSetting.fromJson(Map<String, dynamic> json) {
    return AppSetting(
      name: json['name'] as String,
      value: json['value'],
      type: json['type'] as String?,
      props: json['props'] != null ? Map<String, dynamic>.from(json['props']) : null,
      plainValue: json['plainValue'] as String?,
    );
  }
}
