import 'package:flutter/material.dart';
import 'inventario_tab.dart';
import 'prestamos_tab.dart';
import 'bitacora_tab.dart';
import 'perfil_tab.dart';

class DashboardPanolScreen extends StatefulWidget {
  const DashboardPanolScreen({super.key});

  @override
  State<DashboardPanolScreen> createState() => _DashboardPanolScreenState();
}

class _DashboardPanolScreenState extends State<DashboardPanolScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const InventarioTab(),
    const PrestamosTab(),
    const SizedBox(), 
    const BitacoraTab(),
    const PerfilTab(),
  ];

  void _mostrarModalEscaneo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF111622),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.qr_code_scanner, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Escáner Óptico de Código QR / Barras\n(RF34)",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.white10),
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Spacer(),
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFB300), width: 3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    const Center(child: Icon(Icons.camera_alt_outlined, color: Color(0xFFFFB300), size: 40)),
                    Center(child: Container(width: double.infinity, height: 2, color: Colors.red)),
                    const Positioned(
                      bottom: 20, left: 0, right: 0,
                      child: Text("APUNTE AL RÓTULO QR", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    )
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(backgroundColor: Color(0xFF0D47A1), child: Text("MD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ),
        title: const Text("SGSRA-MD", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF0D47A1),
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              if (index == 2) {
                _mostrarModalEscaneo(context);
              } else {
                setState(() => _currentIndex = index);
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.build_outlined), label: "Inventario"),
              BottomNavigationBarItem(icon: Icon(Icons.history_toggle_off), label: "Préstamos"),
              BottomNavigationBarItem(icon: Icon(Icons.circle, color: Colors.transparent), label: "Escanear QR"),
              BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), label: "Bitácora"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Perfil"),
            ],
          ),
          Positioned(
            top: -16,
            child: GestureDetector(
              onTap: () => _mostrarModalEscaneo(context),
              child: const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFF0D47A1),
                child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
              ),
            ),
          )
        ],
      ),
    );
  }
}

