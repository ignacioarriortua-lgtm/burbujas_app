// lib/widgets/detalle_burbuja_screen.dart
import 'package:flutter/material.dart';
import '../models/burbuja_model.dart';
import '../main.dart'; // <--- Agregamos el import para poder usar el Listener

class DetalleBurbujaScreen extends StatefulWidget {
  final Burbuja burbuja;
  final VoidCallback onGastoModificado;

  const DetalleBurbujaScreen({
    super.key,
    required this.burbuja,
    required this.onGastoModificado,
  });

  @override
  State<DetalleBurbujaScreen> createState() => _DetalleBurbujaScreenState();
}

class _DetalleBurbujaScreenState extends State<DetalleBurbujaScreen> {
  final _montoController = TextEditingController();
  final _detalleController = TextEditingController();

  void _guardarNuevoGasto() {
    final monto = double.tryParse(_montoController.text);
    final detalle = _detalleController.text;

    if (monto != null && monto > 0 && detalle.isNotEmpty) {
      setState(() {
        widget.burbuja.gastos.add(
          CasillaGasto(monto: monto, detalle: detalle, fecha: DateTime.now()),
        );
      });
      
      widget.onGastoModificado(); // Avisa a la pestaña local
      
      // MANDATORIO V3: Dispara el guardado automático en el almacenamiento interno
      BurbujasInicioTabListener.of(context)?.onChanged();
      
      _montoController.clear();
      _detalleController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  // VENTANA EMERGENTE PARA EDITAR EL GASTO SELECCIONADO
  void _abrirEditorGasto(CasillaGasto gasto) {
    final editMontoController = TextEditingController(text: gasto.monto.toString());
    final editDetalleController = TextEditingController(text: gasto.detalle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.teal),
            SizedBox(width: 10),
            Text('Modificar Registro'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editMontoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monto (\$)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: editDetalleController,
              decoration: const InputDecoration(labelText: 'Detalle'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              final nuevoMonto = double.tryParse(editMontoController.text);
              final nuevoDetalle = editDetalleController.text;

              if (nuevoMonto != null && nuevoMonto > 0 && nuevoDetalle.isNotEmpty) {
                setState(() {
                  gasto.monto = nuevoMonto;
                  gasto.detalle = nuevoDetalle;
                });
                
                widget.onGastoModificado(); // Avisa a la pestaña local
                
                // MANDATORIO V3: Dispara el guardado automático de la modificación en el disco
                BurbujasInicioTabListener.of(context)?.onChanged();
                
                Navigator.pop(context);
              }
            },
            child: const Text('GUARDAR CAMBIOS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.burbuja.nombre),
        backgroundColor: Colors.teal.shade100,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            color: Colors.teal.shade50,
            child: Column(
              children: [
                const Text('TOTAL GASTADO ESTE AÑO', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.teal)),
                const SizedBox(height: 8),
                Text('\$${widget.burbuja.totalAcumulado.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _montoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Monto (\$)', prefixIcon: Icon(Icons.attach_money)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _detalleController,
                      decoration: const InputDecoration(labelText: 'Detalle (ej: cable 4 mm)', prefixIcon: Icon(Icons.edit)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _guardarNuevoGasto,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Registrar Gasto'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 45)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: widget.burbuja.gastos.isEmpty
                ? const Center(child: Text('No hay gastos registrados.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: widget.burbuja.gastos.length,
                    itemBuilder: (context, index) {
                      final gasto = widget.burbuja.gastos[widget.burbuja.gastos.length - 1 - index];
                      return ListTile(
                        onTap: () => _abrirEditorGasto(gasto),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.arrow_downward, color: Colors.white, size: 20),
                        ),
                        title: Text(gasto.detalle, style: const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('-\$${gasto.monto.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent)),
                            const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                          ],
                        ),
                        subtitle: Text('${gasto.fecha.day}/${gasto.fecha.month}/${gasto.fecha.year}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}