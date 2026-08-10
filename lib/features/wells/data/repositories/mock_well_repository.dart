import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/wells/domain/entities/well.dart';
import 'package:parosis_sulama/features/wells/domain/repositories/well_repository.dart';

const _online = WellComponentStatus.online;
const _offline = WellComponentStatus.offline;

/// In-memory stand-in for the wells API. Seed data mirrors the original
/// prototype fixtures so screen behavior is unchanged until a real backend
/// is wired up in [WellRepository]'s place.
final class MockWellRepository implements WellRepository {
  final List<Well> _wells = const [
    Well(
      id: 'k1',
      name: 'Ova Kuyu 1',
      province: 'Denizli',
      district: 'Pamukkale',
      components: [
        WellComponent(type: WellComponentType.pump, status: _online),
        WellComponent(type: WellComponentType.thermal, status: _online),
        WellComponent(type: WellComponentType.power, status: _online),
        WellComponent(type: WellComponentType.communication, status: _online),
      ],
    ),
    Well(
      id: 'k2',
      name: 'Ova Kuyu 2',
      province: 'Denizli',
      district: 'Sarayköy',
      components: [
        WellComponent(type: WellComponentType.pump, status: _offline),
        WellComponent(type: WellComponentType.thermal, status: _online),
        WellComponent(type: WellComponentType.power, status: _online),
        WellComponent(type: WellComponentType.communication, status: _online),
      ],
    ),
    Well(
      id: 'k3',
      name: 'Yayla Yaylası Ana Sulama Kuyusu ABCABCAB',
      province: 'Denizli',
      district: 'Çivril',
      components: [
        WellComponent(type: WellComponentType.pump, status: _online),
        WellComponent(type: WellComponentType.thermal, status: _offline),
        WellComponent(type: WellComponentType.power, status: _online),
        WellComponent(type: WellComponentType.communication, status: _offline),
      ],
    ),
    Well(
      id: 'k4',
      name: 'Menderes Kuyu',
      province: 'Aydın',
      district: 'Söke',
      components: [
        WellComponent(type: WellComponentType.pump, status: _online),
        WellComponent(type: WellComponentType.thermal, status: _online),
        WellComponent(type: WellComponentType.power, status: _online),
        WellComponent(type: WellComponentType.communication, status: _online),
      ],
    ),
    Well(
      id: 'k5',
      name: 'Bağ Kuyu',
      province: 'Denizli',
      district: 'Honaz',
      components: [
        WellComponent(type: WellComponentType.pump, status: _offline),
        WellComponent(type: WellComponentType.thermal, status: _offline),
        WellComponent(type: WellComponentType.power, status: _offline),
        WellComponent(type: WellComponentType.communication, status: _offline),
      ],
    ),
  ];

  @override
  Future<Result<List<Well>>> getWells() async =>
      Result.ok(List.unmodifiable(_wells));

  @override
  Future<Result<Well?>> getWellById(String id) async {
    for (final well in _wells) {
      if (well.id == id) return Result.ok(well);
    }
    return const Result.ok(null);
  }
}
