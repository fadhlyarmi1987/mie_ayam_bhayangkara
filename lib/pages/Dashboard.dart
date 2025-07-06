// lib/pages/dashboard.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/item_card.dart';
import '../widgets/order_summary_dialog.dart';
import '../utils/item_data.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF8B4513),
      body: SafeArea(child: DashboardCard()),
    );
  }
}

class DashboardCard extends StatefulWidget {
  const DashboardCard({super.key});

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  final Map<String, int> foodItems = {...initialFoodItems};
  final Map<String, int> drinkItems = {...initialDrinkItems};
  final Map<String, String> itemNotes = {};

  void _increment(String key, Map<String, int> items) {
    setState(() {
      items[key] = items[key]! + 1;
    });
  }

  void _decrement(String key, Map<String, int> items) {
    setState(() {
      if (items[key]! > 0) {
        items[key] = items[key]! - 1;
      }
    });
  }

  List<String> getSelectedItems() {
    final selected = <String>[];
    foodItems.forEach((k, v) => v > 0 ? selected.add('$k: $v') : null);
    drinkItems.forEach((k, v) => v > 0 ? selected.add('$k: $v') : null);
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final paddingSmall = screenWidth * 0.02; // ~12px di layar kecil
    final paddingMedium = screenWidth * 0.04; // ~20px
    final cornerRadius = screenWidth * 0.04; // ~16px
    final headerFontSize = screenWidth * 0.09; // ~32px
    final sectionFontSize = screenWidth * 0.05; // ~20px

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                // 🍹 Card Minuman
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.0325),
                  child: Card(
                    color: Color(0xFFFFEBD5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cornerRadius),
                    ),
                    elevation: 6,
                    child: SizedBox(
                      height: screenHeight * 0.78, //0.78
                      child: Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.45),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: screenHeight * 0.005,
                              ),
                              child: Text(
                                'MENU MINUMAN',
                                style: GoogleFonts.jockeyOne(
                                  fontSize: sectionFontSize,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(cornerRadius),
                                  bottomRight: Radius.circular(cornerRadius),
                                ),
                                child: ListView(
                                  padding: EdgeInsets.only(
                                    top: screenHeight * 0,
                                  ),
                                  children: drinkItems.keys
                                      .map(
                                        (item) => ItemCard(
                                          name: item,
                                          items: drinkItems,
                                          itemPrices: itemPrices,
                                          onAdd: _increment,
                                          onRemove: _decrement,
                                          type: 'minuman',
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        
                //🍜 Card Makanan
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.0325),
                  child: Card(
                    color: const Color.fromARGB(255, 255, 250, 250),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cornerRadius),
                    ),
                    elevation: 6,
                    child: SizedBox(
                      height: screenHeight * 0.435,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.20,
                          bottom: screenHeight * 0.015,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'MENU MAKANAN',
                              style: GoogleFonts.jockeyOne(
                                fontSize: sectionFontSize,
                              ),
                            ),
                            ...foodItems.keys.map(
                              (item) => ItemCard(
                                name: item,
                                items: foodItems,
                                itemPrices: itemPrices,
                                onAdd: _increment,
                                onRemove: _decrement,
                                type: 'makanan',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        
                //🔝 Header Gradient
                Container(
                  height: screenHeight * 0.225,
                  padding: EdgeInsets.all(paddingMedium),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 226, 199, 164),
                        Color(0xFFFFEBD5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(cornerRadius),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'MENU MIE AYAM\nBHAYANGKARA',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jockeyOne(
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: screenHeight * 0.065,
                  width: double.infinity,
                  margin: EdgeInsets.only(top: screenHeight * 0.85, left: screenWidth * 0.05, right: screenWidth * 0.05),
                  child: ElevatedButton(
                    onPressed: () {
                      final selected = getSelectedItems();
                      if (selected.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Belum ada item yang dipilih!'),
                          ),
                        );
                        return;
                      }
        
                      showDialog(
                        context: context,
                        builder: (_) => OrderSummaryDialog(
                          selectedItems: selected,
                          itemNotes: itemNotes,
                          onNoteSaved: (itemName, note) {
                            setState(() {
                              itemNotes[itemName] = note;
                            });
                          },
                          onConfirm: () {
                            setState(() {
                              foodItems.updateAll((key, value) => 0);
                              drinkItems.updateAll((key, value) => 0);
                              itemNotes.clear(); // Reset catatan
                            });
        
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pesanan dikonfirmasi!'),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          cornerRadius * 0.75,
                        ),
                      ),
                    ),
                    child: Text(
                      'BUAT PESANAN',
                      style: GoogleFonts.khand(
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ✅ Tombol Buat Pesanan
      ],
    );
  }
}
