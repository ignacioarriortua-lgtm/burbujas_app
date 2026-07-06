// lib/main.dart
import 'package:flutter/material.dart';
import 'models/burbuja_model.dart';
import 'services/database_service.dart';
import 'widgets/burbujas_inicio_tab.dart';
import 'models/graficos_tab.dart'; // Tu import corregido a models
import 'widgets/balances_tab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BURBUJAS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _tabActual = 0;
  List<Burbuja> _misBurbujas = [];
  List<BalanceAnual> _historicoBalances = [];
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosDesdeDisco();
  }

  Future<void> _cargarDatosDesdeDisco() async {
    final burbujasGuardadas = await DatabaseService.cargarBurbujas();
    final balancesGuardados = await DatabaseService.cargarBalances();
    
    setState(() {
      _misBurbujas = burbujasGuardadas;
      _historicoBalances = balancesGuardados;
      _estaCargando = false;
    });
  }

  // Esta función la van a usar todas las pantallas para forzar el guardado inmediato
  void _guardarDatosEnDisco() {
    setState(() {}); // Refresca las pantallas de main
    DatabaseService.guardarBurbujas(_misBurbujas);
    DatabaseService.guardarBalances(_historicoBalances);
  }

  @override
  Widget build(BuildContext context) {
    if (_estaCargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> pestanas = [
      BurbujasInicioTab(
        burbujas: _misBurbujas,
        onNuevaBurbuja: (nombre) {
          setState(() {
            _misBurbujas.add(Burbuja(nombre: nombre, gastos: []));
          });
          _guardarDatosEnDisco();
        },
        onEliminarBurbuja: (index) {
          setState(() {
            _misBurbujas.removeAt(index);
          });
          _guardarDatosEnDisco();
        },
      ),
      GraficosTab(burbujas: _misBurbujas), 
      BalancesTab(
        burbujas: _misBurbujas,
        historicoBalances: _historicoBalances,
        onCerrarBalance: () {
          setState(() {
            int anoActual = DateTime.now().year;
            double totalGlobalGasto = 0;
            Map<String, double> desglose = {};

            for (var b in _misBurbujas) {
              desglose[b.nombre] = b.totalAcumulado;
              totalGlobalGasto += b.totalAcumulado;
            }

            _historicoBalances.add(
              BalanceAnual(
                ano: anoActual,
                totalGastado: totalGlobalGasto,
                desglosePorBurbuja: desglose,
              ),
            );

            for (var b in _misBurbujas) {
              b.gastos.clear();
            }
          });
          _guardarDatosEnDisco();
        },
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pestanas[_tabActual]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabActual,
        onDestinationSelected: (indice) {
          setState(() {
            _tabActual = indice;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.bubble_chart), label: 'Burbujas'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Gráficos'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Balances'),
        ],
      ),
    );
  }
}