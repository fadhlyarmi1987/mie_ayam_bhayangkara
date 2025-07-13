// lib/viewmodels/antrean_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/antrean_controller.dart';
import '../models/antrean_models.dart';

class AntreanViewModel extends ChangeNotifier {
  final AntreanController controller = AntreanController();

  Set<String> selesaiMasakIds = {};
  Set<String> selesaiBayarIds = {};
  Timer? _refreshTimer;

  void startAutoRefresh(VoidCallback onRefresh) {
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (_) => onRefresh());
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  Stream<List<PesananModel>> fetchActiveOrders() {
    final now = DateTime.now();
    DateTime batasWaktu = DateTime(now.year, now.month, now.day, 6);
    if (now.isBefore(batasWaktu)) {
      batasWaktu = batasWaktu.subtract(const Duration(days: 1));
    }
    return controller.getActiveOrders(batasWaktu);
  }

  void tandaiSelesaiMasak(String docId) {
    selesaiMasakIds.add(docId);
    notifyListeners();
  }

  Future<void> selesaiBayar(String docId) async {
    await controller.markAsSelesaiBayar(docId);
    selesaiBayarIds.add(docId);
    notifyListeners();
  }

  Future<void> hapusPesanan(String docId) async {
    await controller.deletePesanan(docId);
    notifyListeners();
  }

  Future<void> updateCatatan(
    String docId, String name, int qty, String oldNote, String newNote,
  ) async {
    await controller.updateCatatan(docId, name, qty, oldNote, newNote);
    notifyListeners();
  }
}
