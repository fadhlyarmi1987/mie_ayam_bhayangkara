import 'package:flutter/material.dart';

class DashboardController extends ChangeNotifier {
  final Map<String, int> foodItems = {'Mie Ayam': 0, 'Mie Pangsit': 0};
  final Map<String, int> drinkItems = {
    'Es Teh': 0,
    'Teh Anget': 0,
    'Es Jeruk': 0,
    'Jeruk Anget': 0,
  };

  void increment(String key, Map<String, int> items) {
    items[key] = items[key]! + 1;
    notifyListeners();
  }

  void decrement(String key, Map<String, int> items) {
    if (items[key]! > 0) {
      items[key] = items[key]! - 1;
      notifyListeners();
    }
  }

  void resetItems() {
    foodItems.updateAll((key, value) => 0);
    drinkItems.updateAll((key, value) => 0);
    notifyListeners();
  }

  List<String> getSelectedItems() {
    final selected = <String>[];

    foodItems.forEach((key, value) {
      if (value > 0) selected.add('$key: $value');
    });

    drinkItems.forEach((key, value) {
      if (value > 0) selected.add('$key: $value');
    });

    return selected;
  }

  void showCatatanMieAyamDialog(
    BuildContext context,
    TextEditingController controller,
    VoidCallback onSelesai,
  )
   {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.blue, width: 2),
          ),
          backgroundColor: const Color(
            0xFFFDE7C4,
          ), // Warna background sesuai gambar
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'CATATAN MIE AYAM',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2)],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup modal
                  onSelesai(); // Panggil fungsi callback
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
