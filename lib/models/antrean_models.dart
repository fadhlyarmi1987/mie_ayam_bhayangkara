// lib/models/pesanan_model.dart
class PesananModel {
  final String id;
  final String docId;
  final List<Map<String, dynamic>> items;
  final int totalHarga;
  final String ciriPembeli;

  PesananModel({
    required this.id,
    required this.docId,
    required this.items,
    required this.totalHarga,
    required this.ciriPembeli,
  });
}
