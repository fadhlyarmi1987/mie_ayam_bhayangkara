// lib/pages/dashboard.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/item_card.dart';
import '../widgets/order_summary_dialog.dart';
import '../utils/item_data.dart';
//coba

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
  final Map<String, String> itemNotes = {}; // ⬅️ Catatan per item

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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 310),
                  child: Card(
                    color: const Color(0xFFFFEBD5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    child: SizedBox(
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            Text(
                              'MENU MINUMAN',
                              style: GoogleFonts.jockeyOne(fontSize: 20),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                child: ListView(
                                  padding: const EdgeInsets.only(
                                    bottom: 5,
                                    top: 5,
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
                                      )// cobaaa
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

                Padding(
                  padding: const EdgeInsets.only(top: 140),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40, bottom: 10),
                      child: Column(
                        children: [
                          Text(
                            'MENU MAKANAN',
                            style: GoogleFonts.jockeyOne(fontSize: 20),
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
                Container(
                  height: 180,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBD5),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4), // arah bayangan: bawah
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'MENU MIE AYAM\nBHAYANGKARA',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jockeyOne(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 45,
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              final selected = getSelectedItems();
              if (selected.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Belum ada item yang dipilih!')),
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
                      const SnackBar(content: Text('Pesanan dikonfirmasi!')),
                    );
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'BUAT PESANAN',
              style: GoogleFonts.khand(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
