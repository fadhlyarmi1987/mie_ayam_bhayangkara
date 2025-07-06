// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';

// class ConnectionBanner extends StatefulWidget {
//   final Widget child;

//   const ConnectionBanner({super.key, required this.child});

//   @override
//   State<ConnectionBanner> createState() => _ConnectionBannerState();
// }

// class _ConnectionBannerState extends State<ConnectionBanner> {
//   bool _isOffline = false;

//   @override
//   void initState() {
//     super.initState();
//     Connectivity().onConnectivityChanged.listen((result) {
//       setState(() {
//         _isOffline = result == ConnectivityResult.none;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         widget.child,
//         if (_isOffline)
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               color: Colors.red,
//               padding: const EdgeInsets.all(8),
//               child: const SafeArea(
//                 child: Text(
//                   'Tidak terhubung ke internet',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
