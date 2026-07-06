// lib/widgets/graficos_tab.dart
import 'package:flutter/material.dart';
import '../models/burbuja_model.dart';

class GraficosTab extends StatelessWidget {
  final List<Burbuja> burbujas;

  const GraficosTab({super.key, required this.burbujas});

  // Calculamos el total de dinero gastado entre todas las burbujas juntas
  double get _totalGlobal {
    double suma = 0;
    for (var b in burbujas) {
      suma += b.totalAcumulado;
    }
    return suma;
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalGlobal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTÓRICO GLOBAL', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.teal.shade100,
      ),
      body: total == 0
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Cargá algún gasto en tus burbujas para empezar a ver el gráfico histórico.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TARJETA DEL TOTAL GLOBAL ---
                  Card(
                    elevation: 3,
                    color: Colors.teal.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Gasto Total\nAcumulado:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'DISTRIBUCIÓN DEL GASTO POR BURBUJA',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 16),
                  
                  // --- LISTA DE BARRAS DINÁMICAS ---
                  Expanded(
                    child: ListView.builder(
                      itemCount: burbujas.length,
                      itemBuilder: (context, index) {
                        final burbuja = burbujas[index];
                        // Sacamos el porcentaje que representa esta burbuja
                        final porcentaje = total > 0 ? (burbuja.totalAcumulado / total) : 0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nombre de la burbuja y su gasto
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    burbuja.nombre,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    '\$${burbuja.totalAcumulado.toStringAsFixed(2)} (${(porcentaje * 100).toStringAsFixed(1)}%)',
                                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // La barra visual del gráfico
                            // La barra visual del gráfico
Stack(
  children: [
    // Fondo gris de la barra (el 100%)
    Container(
      height: 16,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8), // Ahora sí, adentro de BoxDecoration
      ),
    ),
    // Barra de color que crece según el porcentaje
    FractionallySizedBox(
      widthFactor: porcentaje, // Va de 0.0 a 1.0
      child: Container(
        height: 16,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), // Corregido acá también
          // Le ponemos el degradé lindo para que parezca de nivel profesional
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.teal.shade600],
          ),
        ),
      ),
    ),
  ],
)
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}