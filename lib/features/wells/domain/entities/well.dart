enum WellComponentType { pump, thermal, power, communication }

enum WellComponentStatus { online, offline }

/// A physical component monitored on a well (pump, thermal relay, power feed,
/// telemetry link). Modeled as a status, not a color — presentation maps
/// [WellComponentStatus] to a visual tone.
class WellComponent {
  final WellComponentType type;
  final WellComponentStatus status;
  const WellComponent({required this.type, required this.status});
}

class Well {
  final String id;
  final String name;
  final String ownerName;
  final String province;
  final String district;
  final List<WellComponent> components;

  const Well({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.province,
    required this.district,
    required this.components,
  });
}
