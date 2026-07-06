// lib/main.dart
import 'package:flutter/material.dart';
import 'models/burbuja_model.dart';
import 'services/database_service.dart';
import 'widgets/burbujas_inicio_tab.dart';
import 'models/graficos_tab.dart';
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
  
  // Arrancamos con listas vacías y un estado de carga
  List<Burbuja> _misBurbujas = [];
  List<BalanceAnual> _historicoBalances = [];
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosDesdeDisco(); // Ejecuta la carga apenas se enciende la app
  }

  // Función para ir a leer el disco del celu
  Future<void> _cargarDatosDesdeDisco() async {
    final burbujasGuardadas = await DatabaseService.cargarBurbujas();
    final balancesGuardados = await DatabaseService.cargarBalances();
    
    setState(() {
      _misBurbujas = burbujasGuardadas;
      _historicoBalances = balancesGuardados;
      _estaCargando = false; // Apaga la pantalla de espera
    });
  }

  // Función auxiliar para guardar en segundo plano sin trabar la pantalla
  void _dispararGuardado() {
    DatabaseService.guardarBurbujas(_misBurbujas);
    DatabaseService.guardarBalances(_historicoBalances);
  }

  @override
  Widget build(BuildContext context) {
    if (_estaCargando) {
      // Mientras lee el disco, muestra un círculo de carga centrado
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
          _dispararGuardado(); // Guardado automático
        },
        onEliminarBurbuja: (index) {
          setState(() {
            _misBurbujas.removeAt(index);
          });
          _dispararGuardado(); // Guardado automático
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
          _dispararGuardado(); // Guardado automático del cierre
        },
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: BurbujasInicioTabListener(
          onChanged: () => setState(() {
            _dispararGuardado(); // Escucha si se modificó un gasto adentro de la pantalla interna
          }),
          child: pestanas[_tabActual],
        ),
      ),
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

// Un contenedor simple para capturar los refrescos de pantalla cuando volvemos del detalle
class BurbujasInicioTabListener extends InheritedWidget {
  final VoidCallback onChanged;

  const BurbujasInicioTabListener({
    super.key,
    required this.onChanged,
    required super.child,
  });

  static BurbujasInicioTabListener? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BurbujasInicioTabListener>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}