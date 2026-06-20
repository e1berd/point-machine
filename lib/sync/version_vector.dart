class VersionVector {
  const VersionVector(this.counters);

  factory VersionVector.fromMap(Map<String, dynamic> map) =>
      VersionVector(map.map((key, value) => MapEntry(key, value as int)));

  final Map<String, int> counters;

  static const empty = VersionVector({});

  VersionVector increment(String deviceId) => VersionVector({
        ...counters,
        deviceId: (counters[deviceId] ?? 0) + 1,
      });

  VersionVector merge(VersionVector other) {
    final merged = Map<String, int>.from(counters);
    other.counters.forEach((device, count) {
      final current = merged[device] ?? 0;
      if (count > current) merged[device] = count;
    });
    return VersionVector(merged);
  }

  bool dominates(VersionVector other) => other.counters.entries
      .every((entry) => (counters[entry.key] ?? 0) >= entry.value);

  bool concurrentWith(VersionVector other) =>
      !dominates(other) && !other.dominates(this);

  Map<String, int> toMap() => Map.unmodifiable(counters);
}
