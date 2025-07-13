// lib/views/antrean_view.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/antrean_viewmodel.dart';
import '../models/antrean_models.dart';
import '../widgets/swipeable_card.dart';

class AntreanView extends StatefulWidget {
  const AntreanView({super.key});

  @override
  State<AntreanView> createState() => _AntreanViewState();
}

class _AntreanViewState extends State<AntreanView> {
  late AntreanViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = AntreanViewModel();
    viewModel.startAutoRefresh(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    viewModel.stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
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
                  ),
                  child: Center(
                    child: Text(
                      'ANTREAN',
                      style: GoogleFonts.jockeyOne(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<PesananModel>>(
                    stream: viewModel.fetchActiveOrders(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'Tidak ada antrean',
                            style: GoogleFonts.jockeyOne(),
                          ),
                        );
                      }

                      final pesananList = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pesananList.length,
                        itemBuilder: (context, index) {
                          final pesanan = pesananList[index];

                          if (viewModel.selesaiBayarIds.contains(pesanan.docId)) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SwipeableCard(
                              onDelete: () => viewModel.hapusPesanan(pesanan.docId),
                              child: Text('#${pesanan.id}'), // Ganti dengan UI asli dari _buildOrderCard
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
        ),
      ),
    );
  }
}
