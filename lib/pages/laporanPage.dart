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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan Penjualan',
          style: GoogleFonts.jockeyOne(fontSize: 24),
        ),
        backgroundColor: const Color(0xFFFFEBD5),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          // 🔘 Horizontal Button Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filterOptions.map((option) {
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(option),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 🔄 StreamBuilder
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
                  return const Center(child: Text('Tidak ada data pesanan.'));
                }

                int totalPendapatan = docs.fold(0, (sum, doc) {
                  return sum + (doc['total_harga'] as int);
                });

                return Column(
                  children: [
                    // 📋 List Pesanan
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pesanan #$id',
                                    style: GoogleFonts.jockeyOne(
                                      fontSize: 30,
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
                                            Text(
                                              'Catatan: ',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black
                                              ),
                                            ),
                                            Text(
                                              '$catatan',
                                              style: GoogleFonts.jockeyOne(
                                                fontSize: 16,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  Text(
                                    'Total Harga: Rp ${NumberFormat('#,###', 'id_ID').format(totalHarga)}',
                                    style: GoogleFonts.jockeyOne(
                                      fontSize: 24,
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
    );
  }
}
