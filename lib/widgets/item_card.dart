import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemCard extends StatelessWidget {
  final String name;
  final Map<String, int> items;
  final Map<String, int> itemPrices;
  final void Function(String, Map<String, int>) onAdd;
  final void Function(String, Map<String, int>) onRemove;
  final String type; // 'makanan' atau 'minuman'

  const ItemCard({
    super.key,
    required this.name,
    required this.items,
    required this.itemPrices,
    required this.onAdd,
    required this.onRemove,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: type == 'makanan' ? const Color(0xFFFFEBD5) : Color.fromARGB(255, 255, 250, 250),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: GoogleFonts.jockeyOne(fontSize: 20)),
              Row(
                children: [
                  _roundButton(
                    icon: Icons.remove,
                    onPressed: () => onRemove(name, items),
                    backgroundColor: const Color.fromARGB(255, 255, 111, 100),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    items[name].toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  _roundButton(
                    icon: Icons.add,
                    onPressed: () => onAdd(name, items),
                    backgroundColor: const Color.fromARGB(255, 106, 182, 109),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}
