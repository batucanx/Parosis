import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/wells/domain/entities/well.dart';
import 'package:parosis_sulama/features/wells/domain/repositories/well_repository.dart';

const _online = WellComponentStatus.online;
const _offline = WellComponentStatus.offline;

/// In-memory stand-in for the wells API.
///
/// Kuyular **paylaşımlı bir havuz** — her kullanıcı aynı listeyi görür ve
/// (Program Sulama'daki "Sıra Al" ile) birbirlerinin kuyusuna da randevu
/// talebi gönderebilir; bu, `Well` entity'sine henüz eklenmeyen gerçek
/// sahiplik modelinden bağımsız çalışıyor (bkz. memory
/// `project_well_ownership_deferred`). İsimler, kullanıcının paylaştığı
/// referans "Su" panelindeki gerçek kuyu isimleri gelene kadar geçici
/// yer tutucu ("Cihan Test Silme" hariç, o panelde test verisiydi).
final class MockWellRepository implements WellRepository {
  static const List<Well> _wells = [
    Well(
      id: 'k1',
      name: 'Ali Yurtseven Taşlı Tarla',
      province: 'Burdur',
      district: 'Tefenni',
      components: [
        WellComponent(type: WellComponentType.pump, status: _online),
        WellComponent(type: WellComponentType.thermal, status: _online),
        WellComponent(type: WellComponentType.power, status: _online),
        WellComponent(type: WellComponentType.communication, status: _online),
      ],
    ),
    Well(
      id: 'k2',
      name: 'Alihsan Özçoban Karapınar',
      province: 'Burdur',
      district: 'Tefenni',
      components: [
        WellComponent(type: WellComponentType.pump, status: _online),
        WellComponent(type: WellComponentType.thermal, status: _offline),
        WellComponent(type: WellComponentType.power, status: _offline),
        WellComponent(
          type: WellComponentType.communication,
          status: _offline,
        ),
      ],
    ),
    Well(
      id: 'k3',
      name: 'Alihsan Özçoban Taşlı Tarla',
      province: 'Burdur',
      district: 'Tefenni',
      components: [
        WellComponent(type: WellComponentType.pump, status: _online),
        WellComponent(type: WellComponentType.thermal, status: _online),
        WellComponent(type: WellComponentType.power, status: _online),
        WellComponent(type: WellComponentType.communication, status: _online),
      ],
    ),
    Well(
      id: 'k4',
      name: 'Emin Avcıkol Bozdağ',
      province: 'Burdur',
      district: 'Tefenni',
      components: [
        WellComponent(type: WellComponentType.pump, status: _online),
        WellComponent(type: WellComponentType.thermal, status: _online),
        WellComponent(type: WellComponentType.power, status: _online),
        WellComponent(type: WellComponentType.communication, status: _online),
      ],
    ),
    Well(
      id: 'k5',
      name: 'GY İnşaat Mermer Ocağı Kuyusu',
      province: 'Denizli',
      district: 'Acıpayam',
      components: [
        WellComponent(type: WellComponentType.pump, status: _online),
        WellComponent(type: WellComponentType.thermal, status: _online),
        WellComponent(type: WellComponentType.power, status: _online),
        WellComponent(type: WellComponentType.communication, status: _online),
      ],
    ),
    Well(
      id: 'k6',
      name: 'İsmet Serttaş Bozdağın Dibi',
      province: 'Burdur',
      district: 'Tefenni',
      components: [
        WellComponent(type: WellComponentType.pump, status: _online),
        WellComponent(type: WellComponentType.thermal, status: _online),
        WellComponent(type: WellComponentType.power, status: _online),
        WellComponent(type: WellComponentType.communication, status: _online),
      ],
    ),
    Well(
      id: 'k7',
      name: 'Rahmi Ekinci Harım Yeni Sondaj',
      province: 'Burdur',
      district: 'Tefenni',
      components: [
        WellComponent(type: WellComponentType.pump, status: _online),
        WellComponent(type: WellComponentType.thermal, status: _online),
        WellComponent(type: WellComponentType.power, status: _online),
        WellComponent(type: WellComponentType.communication, status: _online),
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
