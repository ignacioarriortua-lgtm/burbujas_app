// lib/widgets/balances_tab.dart
import 'package:flutter/material.dart';
import '../models/burbuja_model.dart';

class BalancesTab extends StatelessWidget {
  final List<Burbuja> burbujas;
  final List<BalanceAnual> historicoBalances;
  final VoidCallback onCerrarBalance;

  const BalancesTab({
    super.key,
    required this.burbujas,
    required this.historicoBalances,
    required this.onCerrarBalance,
  });

  @override
  Widget build(BuildContext context) {
    // Calculamos el año actual dinámicamente
    final anoActual = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BALANCES ANUALES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.teal.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TARJETA DE CIERRE DEL AÑO ACTIVO ---
            Card(
              elevation: 4,
              color: Colors.orange.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Cierre de Ejercicio $anoActual',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Al cerrar el balance, se calculará el informe final del año y se guardará en el histórico. Las burbujas actuales volverán a 0 para arrancar el año nuevo.",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _mostrarAlertaCierre(context),
                      icon: const Icon(Icons.lock_clock),
                      label: Text('Cerrar Balance $anoActual'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'HISTORIAL DE BALANCES ANTERIORES',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
            ),
            const SizedBox(height: 12),

            // --- LISTA DE BALANCES ARCHIVADOS ---
            Expanded(
              child: historicoBalances.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay balances archivados todavía.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: historicoBalances.length,
                      itemBuilder: (context, index) {
                        final balance = historicoBalances[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ExpansionTile(
                            leading: const Icon(Icons.folder_shared, color: Colors.teal),
                            title: Text(
                              'Balance Anual ${balance.ano}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              '\$${balance.totalGastado.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                            ),
                            children: balance.desglosePorBurbuja.entries.map((burbujaInfo) {
                              return ListTile(
                                title: Text(burbujaInfo.key),
                                trailing: Text('\$${burbujaInfo.value.toStringAsFixed(2)}'),
                                dense: true,
                              );
                            }).toList(),
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

  // --- CARTEL DE SEGURIDAD (ALERTA) ---
  void _mostrarAlertaCierre(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text('¿Confirmar Cierre?'),
          ],
        ),
        content: const Text(
          'Esta acción es irreversible. Se archivarán los números y las burbujas actuales quedarán limpias en cero para el nuevo ciclo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el cartel
              onCerrarBalance(); // Ejecuta la matemática del cierre
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Balance Anual cerrado con éxito y archivado!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('SÍ, CERRAR AÑO'),
          ),
        ],
      ),
    );
  }
}