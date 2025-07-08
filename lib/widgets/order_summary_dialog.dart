// lib/widgets/order_summary_dialog.dart
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mie_ayam_bhayangkara/utils/item_data.dart';

class OrderSummaryDialog extends StatefulWidget {
  final List<String> selectedItems;
  final VoidCallback onConfirm;
  final Map<String, String> itemNotes;
  final Function(String itemName, String note) onNoteSaved;

  const OrderSummaryDialog({
    super.key,
    required this.selectedItems,
    required this.onConfirm,
    required this.itemNotes,
    required this.onNoteSaved,
  });

  @override
  State<OrderSummaryDialog> createState() => _OrderSummaryDialogState();
}

class _OrderSummaryDialogState extends State<OrderSummaryDialog> {
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController buyerDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    for (var item in widget.selectedItems) {
      final name = item.split(':')[0];
      _controllers[name] = TextEditingController(
        text: widget.itemNotes[name] ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      FocusScope.of(context).unfocus(); // Untuk menutup keyboard jika tap di luar
    },
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        insetPadding: const EdgeInsets.all(16), // agar tidak menabrak layar
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFDEBD0),
        child: Material( // Tambahkan Material agar text selection bekerja
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(), // cegah overscroll
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'KETERANGAN PESANAN',
                      style: GoogleFonts.jockeyOne(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...widget.selectedItems.map((item) {
                    final parts = item.split(':');
                    final name = parts[0];
                    final qty = parts[1].trim();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  name.toUpperCase(),
                                  style: GoogleFonts.jockeyOne(fontSize: 16),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  qty,
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.jockeyOne(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controllers[name],
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Tambahkan catatan...',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              widget.onNoteSaved(name, val);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  Text(
                    'Ciri-ciri Pembeli:',
                    style: GoogleFonts.jockeyOne(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: buyerDescriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Masukkan Ciri-ciri Pembeli',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: showConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black54,
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}


  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFDEBD0), // Warna krem
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'KONFIRMASI PESANAN',
                    style: GoogleFonts.jockeyOne(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ TAMPILKAN LIST ITEM & CATATAN
                ...widget.selectedItems.map((item) {
                  final name = item.split(':')[0];
                  final qty = item.split(':')[1].trim();
                  final note = widget.itemNotes[name];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$name x$qty',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (note != null && note.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Catatan: $note',
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        const Divider(height: 16, thickness: 0.5),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Hitung items
                        List<Map<String, dynamic>> items = widget.selectedItems
                            .map((item) {
                              final name = item.split(':')[0].trim();
                              final qty =
                                  int.tryParse(item.split(':')[1].trim()) ?? 0;
                              final note = widget.itemNotes[name] ?? '';
                              return {
                                'nama': name,
                                'jumlah': qty,
                                'catatan': note,
                              };
                            })
                            .toList();

                        // Hitung total harga
                        int totalHarga = 0;
                        for (var item in items) {
                          final nama = item['nama'] as String;
                          final qty = item['jumlah'] as int;
                          final hargaPerItem = itemPrices[nama] ?? 0;
                          totalHarga += qty * hargaPerItem;
                        }

                        // Tentukan waktu reset 06:00 pagi hari ini
                        DateTime now = DateTime.now();
                        DateTime resetTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          6,
                        );

                        // Jika sekarang sebelum jam 6 pagi, maka resetTime adalah jam 6 pagi kemarin
                        if (now.isBefore(resetTime)) {
                          resetTime = resetTime.subtract(
                            const Duration(days: 1),
                          );
                        }

                        // Ambil semua dokumen setelah resetTime
                        QuerySnapshot snapshot = await FirebaseFirestore
                            .instance
                            .collection('pesanan')
                            .where(
                              'tanggal',
                              isGreaterThanOrEqualTo: Timestamp.fromDate(
                                resetTime,
                              ),
                            )
                            .orderBy('tanggal')
                            .get();

                        int nextId = snapshot.docs.length + 1;

                        // Simpan ke Firestore
                        await FirebaseFirestore.instance
                            .collection('pesanan')
                            .add({
                              'tanggal': Timestamp.now(),
                              'items': items,
                              'total_harga': totalHarga,
                              'id': nextId,
                              'ciri_pembeli': buyerDescriptionController.text
                                  .trim(),
                              'status' : 'a'
                            });

                        Navigator.of(context).pop();
                        widget.onConfirm();
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Konfirmasi',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
