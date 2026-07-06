// lib/widgets/burbujas_inicio_tab.dart
import 'package:flutter/material.dart';
import '../models/burbuja_model.dart';
import 'detalle_burbuja_screen.dart';
import '../services/database_service.dart'; // Para asegurar el guardado al volver

class BurbujasInicioTab extends StatefulWidget {
  final List<Burbuja> burbujas;
  final Function(String) onNuevaBurbuja;
  final Function(int) onEliminarBurbuja;

  const BurbujasInicioTab({
    super.key,
    required this.burbujas,
    required this.onNuevaBurbuja,
    required this.onEliminarBurbuja,
  });

  @override
  State<BurbujasInicioTab> createState() => _BurbujasInicioTabState();
}

class _BurbujasInicioTabState extends State<BurbujasInicioTab> {
  void _confirmarEliminar(BuildContext context, int index, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 10),
            Text('¿Eliminar Espacio?'),
          ],
        ),
        content: Text('¿Estás seguro de que querés borrar la burbuja "$nombre" y todos sus gastos cargados?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              widget.onEliminarBurbuja(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Burbuja "$nombre" eliminada.')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('SÍ, BORRAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BURBUJAS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.teal.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: widget.burbujas.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final burbuja = widget.burbujas[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.teal.shade50,
              child: Stack(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      // Esperamos a que el usuario vuelva de la pantalla de detalles
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleBurbujaScreen(
                            burbuja: burbuja,
                            onGastoModificado: () {
                              // Al modificar un gasto guardamos la lista completa en caliente
                              DatabaseService.guardarBurbujas(widget.burbujas);
                            },
                          ),
                        ),
                      );
                      // Cuando regresa a la pantalla principal, fuerza el redibujado de los totales
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.circle_outlined, size: 36, color: Colors.teal),
                          const SizedBox(height: 8),
                          Text(burbuja.nombre, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('\$${burbuja.totalAcumulado.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                      onPressed: () => _confirmarEliminar(context, index, burbuja.nombre),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Crear Nueva Burbuja'),
              content: TextField(
                controller: textController,
                decoration: const InputDecoration(hintText: 'Ej: Tarjetas Banco'),
                autofocus: true,
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                TextButton(
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      widget.onNuevaBurbuja(textController.text);
                      textController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Crear'),
                ),
              ],
            ),
          );
        },
        label: const Text('Nueva Burbuja'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal.shade200,
      ),
    );
  }
}