import 'package:flutter/material.dart';

import 'package:mie_ayam_bhayangkara/pages/Dashboard.dart';
import 'package:mie_ayam_bhayangkara/pages/laporanPage.dart';
import 'package:mie_ayam_bhayangkara/pages/pesanan.dart';
// import 'pages/dashboard_page.dart';
// import 'pages/pesanan_page.dart';
// import 'pages/pengaturan_page.dart';

class ControlPage extends StatefulWidget {
  final int initialIndex;

  const ControlPage({super.key, this.initialIndex = 0});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  late int _selectedIndex;

  final List<Widget> _pages = const [
    DashboardCard(),
    AntreanPage(),
    LaporanPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
         items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Beranda',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.fastfood),
        label: 'Pesanan',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart),
        label: 'Laporan',
      ),
    ],
      ),
    );
  }
}
