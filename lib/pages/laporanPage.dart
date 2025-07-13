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
            colors: [
              Color.fromARGB(255, 226, 199, 164),
              Color.fromARGB(255, 230, 202, 172),
            ],
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
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                                    style: GoogleFonts.jockeyOne(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                      return Center(
                        child: Text(
                          'Tidak ada data pesanan.',
                          style: GoogleFonts.jockeyOne(),
                        ),
                      );
                    }

                    int totalPendapatan = docs.fold(0, (sum, doc) {
                      return sum + (doc['total_harga'] as int);
                    });

                    return Column(
                      children: [
                        // 🔼 List Pesanan
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final id = doc['id'];
                              final items = doc['items'] as List<dynamic>;
                              final totalHarga = doc['total_harga'];
                              final ciripembeli = doc['ciri_pembeli'];
                              final tanggal = doc['tanggal'] as Timestamp;

                              return _CustomExpansionCard(
                                id: id,
                                ciriPembeli: ciripembeli,
                                tanggal: tanggal,
                                items: items,
                                totalHarga: totalHarga,
                              );
                            },
                          ),
                        ),

                        // 🔽 Total Pendapatan Paling Bawah
                        Padding(
                          padding: const EdgeInsets.only(bottom: 57),
                          child: Container(
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
                              'Total Pendapatan: Rp ${NumberFormat('#,###', 'id_ID').format(docs.fold(0, (sum, doc) => sum + (doc['total_harga'] as int)))}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
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

class _CustomExpansionCard extends StatefulWidget {
  final int id;
  final String? ciriPembeli;
  final Timestamp tanggal;
  final List<dynamic> items;
  final int totalHarga;

  const _CustomExpansionCard({
    required this.id,
    required this.ciriPembeli,
    required this.tanggal,
    required this.items,
    required this.totalHarga,
  });

  @override
  State<_CustomExpansionCard> createState() => _CustomExpansionCardState();
}

class _CustomExpansionCardState extends State<_CustomExpansionCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: const Color.fromARGB(173, 0, 0, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFFFEBD5),
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Pesanan #${widget.id}',
                              style: GoogleFonts.jockeyOne(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          Center(
                            child: Text(
                              'Ciri Pembeli',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),

                          Center(
                            child: Text(
                              (widget.ciriPembeli == null ||
                                      widget.ciriPembeli!.trim().isEmpty)
                                  ? '-'
                                  : widget.ciriPembeli!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.jockeyOne(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'EEE, dd MMM yyyy, HH:mm',
                                ).format(widget.tanggal.toDate()),
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween<double>(
                        begin: 0,
                        end: _expanded ? 0.5 : 0.0,
                      ),
                      curve: Curves.easeInOutBack,
                      builder: (context, value, child) => Transform.rotate(
                        angle: value * 3.1416 * 2,
                        child: const Icon(Icons.expand_more, size: 32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutQuart,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                // reverseDuration: const Duration(milliseconds: 700),
                // switchInCurve: Curves.easeInOut,
                // switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ClipRect(
                    child: FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, -0.02), // sedikit naik
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOut,
                                ),
                              ),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },

                child: _expanded
                    ? Padding(
                        key: const ValueKey(true),
                        padding: const EdgeInsets.all(1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              const Divider(thickness: 1),
                              ...widget.items.map((item) {
                                final nama = item['nama'];
                                final jumlah = item['jumlah'];
                                final catatan = item['catatan'];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            nama,
                                            style: GoogleFonts.jockeyOne(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'x $jumlah',
                                            style: GoogleFonts.jockeyOne(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (catatan != null &&
                                          catatan.toString().isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Catatan:',
                                          style: GoogleFonts.roboto(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          catatan,
                                          style: GoogleFonts.jockeyOne(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                              const Divider(thickness: 1),
                              Text(
                                'Total Harga: Rp ${NumberFormat('#,###', 'id_ID').format(widget.totalHarga)}',
                                style: GoogleFonts.jockeyOne(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey(false)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
