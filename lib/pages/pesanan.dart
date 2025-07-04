import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AntreanPage extends StatefulWidget {
  const AntreanPage({super.key});

  @override
  State<AntreanPage> createState() => _AntreanPageState();
}

class _AntreanPageState extends State<AntreanPage> {
  final Set<String> selesaiMasakIds = {};
  final Set<String> selesaiBayarIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEBD5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'ANTREAN',
              style: GoogleFonts.jockeyOne(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pesanan')
                    .where(
                      'status',
                      isEqualTo: 'a',
                    ) // ✅ Tampilkan hanya status 'a'
                    .orderBy('id', descending: false)
                    .snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Tidak ada antrean'));
                  }

                  final pesananList = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pesananList.length,
                    itemBuilder: (context, index) {
                      final data = pesananList[index];
                      final docId = data.id;

                      // Jika sudah dibayar, jangan tampilkan
                      if (selesaiBayarIds.contains(docId)) {
                        return const SizedBox.shrink();
                      }

                      final nomor = data['id'].toString();
                      final List<Map<String, dynamic>> items =
                          (data['items'] as List<dynamic>)
                              .map((item) => Map<String, dynamic>.from(item))
                              .toList();
                      final total = data['total_harga'] ?? 0;
                      final ciriPembeli = data['ciri_pembeli'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildOrderCard(
                          nomor,
                          items,
                          total,
                          docId,
                          ciriPembeli,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    String orderNumber,
    List<Map<String, dynamic>> items,
    int total,
    String docId,
    String ciriPembeli,
  ) {
    final isSelesaiMasak = selesaiMasakIds.contains(docId);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              orderNumber,
              style: GoogleFonts.jockeyOne(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ✅ Tambahkan ciri pembeli jika tidak kosong
          if (ciriPembeli.isNotEmpty) ...[
            Center(
              child: Text(
                'Ciri Pembeli: ${ciriPembeli.trim().isEmpty ? '-' : ciriPembeli}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            const SizedBox(height: 8),
          ],

          ...items.map(
            (item) => _buildItem(
              item['nama'] ?? '',
              item['catatan'] ?? '',
              item['jumlah'] ?? 1,
              docId,
            ),
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL :',
                style: GoogleFonts.jockeyOne(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
              Text(
                '${total.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.")}',
                style: GoogleFonts.jockeyOne(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  if (!isSelesaiMasak) {
                    _showKonfirmasiDialog(docId);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelesaiMasak ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isSelesaiMasak ? 'sudah diantar' : 'selesai masak',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showKonfirmasiHapusDialog(docId);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'selesai bayar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String name, String note, int qty, String docId) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBD5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📦 Item Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.jockeyOne(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                if (note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '# ${note.toUpperCase()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // 🔢 Jumlah + ✏️ Edit icon
          Column(
            children: [
              Text(
                'x$qty',
                style: GoogleFonts.jockeyOne(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 14),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    _showEditNoteDialog(docId, name, note, qty);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showKonfirmasiDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFEBD5), // Warna krem
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: const Text(
          'Apakah anda sudah menyelesaikan masakan?',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              setState(() {
                selesaiMasakIds.add(docId);
              });
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showKonfirmasiHapusDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFEBD5), // Warna krem
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: const Text(
          'Apakah pesanan ini sudah dibayar dan ingin dihapus dari tampilan?',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('pesanan')
                  .doc(docId)
                  .update({'status': 'b'}); // ✅ ubah status jadi 'b'

              Navigator.of(context).pop();
            },

            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditNoteDialog(String docId, String name, String oldNote, int qty) {
    final controller = TextEditingController(text: oldNote);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFEBD5),
        title: Text('Edit Catatan: $name'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Masukkan catatan...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newNote = controller.text.trim();
              final docRef = FirebaseFirestore.instance
                  .collection('pesanan')
                  .doc(docId);

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

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Catatan berhasil diperbarui')),
              );

              setState(() {}); // refresh tampilan setelah update
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
