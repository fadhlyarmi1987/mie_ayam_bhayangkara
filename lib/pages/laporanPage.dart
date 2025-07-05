import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String selectedFilter = 'Hari Ini';

  final List<String> filterOptions = [
    'Hari Ini',
    'Kemarin',
    '7 Hari Terakhir',
    '30 Hari Terakhir',
  ];

  Map<String, DateTimeRange> getFilterRange() {
    final now = DateTime.now();
    DateTime base = DateTime(now.year, now.month, now.day, 6);
    if (now.isBefore(base)) {
      base = base.subtract(const Duration(days: 1));
    }

    switch (selectedFilter) {
      case 'Hari Ini':
        return {
          'range': DateTimeRange(
            start: base,
            end: base.add(const Duration(days: 1)),
          ),
        };
      case 'Kemarin':
        return {
          'range': DateTimeRange(
            start: base.subtract(const Duration(days: 1)),
            end: base,
          ),
        };
      case '7 Hari Terakhir':
        return {
          'range': DateTimeRange(
            start: base.subtract(const Duration(days: 6)),
            end: base.add(const Duration(days: 1)),
          ),
        };
      case '30 Hari Terakhir':
      default:
        return {
          'range': DateTimeRange(
            start: base.subtract(const Duration(days: 29)),
            end: base.add(const Duration(days: 1)),
          ),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = getFilterRange()['range']!;
    final start = Timestamp.fromDate(dateRange.start);
    final end = Timestamp.fromDate(dateRange.end);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 226, 199, 164), Color(0xFFFFEBD5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔝 Header Custom Pengganti AppBar
              Container(
                height: screenHeight * 0.1,
                width: screenWidth,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 226, 199, 164),
                      Color(0xFFFFEBD5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(42, 0, 0, 0),
                      spreadRadius: 0.1,
                      blurRadius: 5,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'LAPORAN PENJUALAN',
                    style: GoogleFonts.jockeyOne(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // 🔘 Horizontal Filter Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...filterOptions.map((option) {
                        final isSelected = option == selectedFilter;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedFilter = option;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Colors.green
                                  : Colors.grey[300],
                              foregroundColor: isSelected
                                  ? Colors.white
                                  : Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(option),
                          ),
                        );
                      }),
                      // 🔴 Tombol Hapus Data di sebelah kanan
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: InkWell(
                          onTap: () async {
                            final TextEditingController controller =
                                TextEditingController();
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(
                                  0xFFFFEBD5,
                                ), // Warna krem
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Center(
                                  child: Text(
                                    'Konfirmasi Penghapusan',
                                    style: GoogleFonts.jockeyOne(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Ketik "hapus" untuk menghapus seluruh riwayat pesanan:',
                                      style: GoogleFonts.jockeyOne(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: controller,
                                      decoration: InputDecoration(
                                        hintText: 'ketik hapus',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                actionsPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (controller.text
                                              .trim()
                                              .toLowerCase() ==
                                          'hapus') {
                                        Navigator.pop(context, true);
                                      } else {
                                        Navigator.pop(context, false);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Teks tidak sesuai, penghapusan dibatalkan.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('Konfirmasi'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              try {
                                final snapshot = await FirebaseFirestore
                                    .instance
                                    .collection('pesanan')
                                    .where(
                                      'tanggal',
                                      isGreaterThanOrEqualTo:
                                          Timestamp.fromDate(
                                            getFilterRange()['range']!.start,
                                          ),
                                    )
                                    .where(
                                      'tanggal',
                                      isLessThan: Timestamp.fromDate(
                                        getFilterRange()['range']!.end,
                                      ),
                                    )
                                    .get();

                                final batch = FirebaseFirestore.instance
                                    .batch();
                                for (var doc in snapshot.docs) {
                                  batch.delete(doc.reference);
                                }
                                await batch.commit();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Data berhasil dihapus'),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal menghapus data: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.delete, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Hapus Data',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔄 StreamBuilder (Laporan Penjualan)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pesanan')
                      .where('tanggal', isGreaterThanOrEqualTo: start)
                      .where('tanggal', isLessThan: end)
                      .orderBy('tanggal', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada data pesanan.'),
                      );
                    }

                    int totalPendapatan = docs.fold(0, (sum, doc) {
                      return sum + (doc['total_harga'] as int);
                    });

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final id = doc['id'];
                              final items = doc['items'] as List<dynamic>;
                              final totalHarga = doc['total_harga'];
                              final tanggal = doc['tanggal'] as Timestamp;

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: const Color(0xFFFFEBD5),
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pesanan #$id',
                                        style: GoogleFonts.jockeyOne(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat(
                                          'dd MMM yyyy, HH:mm',
                                        ).format(tanggal.toDate()),
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const Divider(height: 20, thickness: 1),
                                      ...items.map((item) {
                                        final nama = item['nama'];
                                        final jumlah = item['jumlah'];
                                        final catatan = item['catatan'];

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$nama x $jumlah',
                                                style: GoogleFonts.jockeyOne(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (catatan != null &&
                                                  catatan.toString().isNotEmpty)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Catatan:',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      catatan,
                                                      style:
                                                          GoogleFonts.jockeyOne(
                                                            fontSize: 16,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      Text(
                                        'Total Harga: Rp ${NumberFormat('#,###', 'id_ID').format(totalHarga)}',
                                        style: GoogleFonts.jockeyOne(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // 💰 Total Pendapatan
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Total Pendapatan: Rp ${NumberFormat('#,###', 'id_ID').format(totalPendapatan)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
