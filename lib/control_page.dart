import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:mie_ayam_bhayangkara/pages/Dashboard.dart';
import 'package:mie_ayam_bhayangkara/pages/laporanPage.dart';
import 'package:mie_ayam_bhayangkara/pages/antrean_views.dart';

class ControlPage extends StatefulWidget {
  final int initialIndex;

  const ControlPage({super.key, this.initialIndex = 0});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  late int _selectedIndex;
  bool _wasOffline = false;
  String? _bottomMessage;
  bool _showNotification = false;
  Color _bottomColor = Colors.red;

  final List<Widget> _pages = const [
    DashboardCard(),
    AntreanView(),
    LaporanPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _startMonitoringConnection();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _startMonitoringConnection() async {
  // Cek status awal koneksi (jangan munculkan notifikasi apapun di sini)
  final initialStatus = await InternetConnectionChecker.instance.hasConnection;
  _wasOffline = !initialStatus;

  Connectivity().onConnectivityChanged.listen((_) async {
    final hasInternet = await InternetConnectionChecker.instance.hasConnection;

    if (!hasInternet) {
      // Offline
      setState(() {
        _bottomMessage = 'Tidak terhubung ke internet';
        _bottomColor = Colors.red;
        _showNotification = true;
        _wasOffline = true;
      });
    } else {
      // Online, hanya tampilkan jika sebelumnya offline
      if (_wasOffline) {
        setState(() {
          _bottomMessage = 'Anda kembali online';
          _bottomColor = Colors.green;
          _showNotification = true;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showNotification = false;
            });
          }
        });

        _wasOffline = false; // update status
      }
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Halaman utama
          Positioned.fill(
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),

          // BottomNavigationBar di dalam Stack
          // Di dalam Stack, pada bagian Positioned bottom:
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  offset: _showNotification ? Offset.zero : const Offset(0, 1),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showNotification ? 1 : 0,
                    child: Container(
                      width: double.infinity,
                      color: _bottomColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: SafeArea(
                        top: false,
                        child: Text(
                          _bottomMessage ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  backgroundColor: const Color(0xFFFFEBD5),
                  selectedItemColor: Colors.green[800],
                  unselectedItemColor: Colors.black54,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
