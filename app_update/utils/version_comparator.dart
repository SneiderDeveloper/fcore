class VersionComparator {
  const VersionComparator._();

  /// Returns a negative number if [a] < [b], 0 if equal, positive if [a] > [b].
  /// Ignores build metadata ("1.2.3+4", "1.2.3-beta").
  static int compare(String a, String b) {
    final left = _parse(a);
    final right = _parse(b);
    final length = left.length > right.length ? left.length : right.length;

    for (var i = 0; i < length; i++) {
      final l = i < left.length ? left[i] : 0;
      final r = i < right.length ? right[i] : 0;
      if (l != r) return l.compareTo(r);
    }
    return 0;
  }

  static bool isLowerThan(String a, String b) => compare(a, b) < 0;

  static List<int> _parse(String version) {
    final core = version.split(RegExp(r'[+\-\s]')).first;
    return core.split('.').map((part) => int.tryParse(part) ?? 0).toList();
  }
}
