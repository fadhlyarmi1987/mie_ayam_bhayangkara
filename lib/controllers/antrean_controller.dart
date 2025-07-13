// lib/controllers/antrean_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/antrean_models.dart';

class AntreanController {
  Stream<List<PesananModel>> getActiveOrders(DateTime batasWaktu) {
    final timestampStart = Timestamp.fromDate(batasWaktu);
    return FirebaseFirestore.instance
        .collection('pesanan')
        .where('status', isEqualTo: 'a')
        .where('tanggal', isGreaterThanOrEqualTo: timestampStart)
        .orderBy('tanggal')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final List<Map<String, dynamic>> items = (data['items'] as List<dynamic>)
                .map((item) => Map<String, dynamic>.from(item))
                .toList();

            return PesananModel(
              id: data['id'].toString(),
              docId: doc.id,
              items: items,
              totalHarga: data['total_harga'] ?? 0,
              ciriPembeli: data['ciri_pembeli'] ?? '',
            );
          }).toList();
        });
  }

  Future<void> markAsSelesaiBayar(String docId) async {
    await FirebaseFirestore.instance
        .collection('pesanan')
        .doc(docId)
        .update({'status': 'b'});
  }

  Future<void> deletePesanan(String docId) async {
    await FirebaseFirestore.instance
        .collection('pesanan')
        .doc(docId)
        .delete();
  }

  Future<void> updateCatatan(String docId, String name, int qty, String oldNote, String newNote) async {
    final docRef = FirebaseFirestore.instance.collection('pesanan').doc(docId);
    final docSnapshot = await docRef.get();
    final List<dynamic> itemsRaw = docSnapshot.data()?['items'] ?? [];

    final updatedItems = itemsRaw.map((item) {
      final mapItem = Map<String, dynamic>.from(item);
      if (mapItem['nama'] == name &&
          mapItem['jumlah'] == qty &&
          mapItem['catatan'] == oldNote) {
        mapItem['catatan'] = newNote;
      }
      return mapItem;
    }).toList();

    await docRef.update({'items': updatedItems});
  }
}
