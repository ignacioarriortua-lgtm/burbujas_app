// lib/models/burbuja_model.dart
import 'dart:convert';

class CasillaGasto {
  double monto;
  String detalle;
  final DateTime fecha;

  CasillaGasto({
    required this.monto,
    required this.detalle,
    required this.fecha,
  });

  // Convierte un gasto a un mapa de texto
  Map<String, dynamic> toMap() {
    return {
      'monto': monto,
      'detalle': detalle,
      'fecha': fecha.toIso8601String(),
    };
  }

  // Crea un gasto desde un mapa de texto
  factory CasillaGasto.fromMap(Map<String, dynamic> map) {
    return CasillaGasto(
      monto: map['monto']?.toDouble() ?? 0.0,
      detalle: map['detalle'] ?? '',
      fecha: DateTime.parse(map['fecha']),
    );
  }
}

class Burbuja {
  final String nombre;
  final List<CasillaGasto> gastos;

  Burbuja({
    required this.nombre,
    required this.gastos,
  });

  double get totalAcumulado {
    double suma = 0;
    for (var gasto in gastos) {
      suma += gasto.monto;
    }
    return suma;
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'gastos': gastos.map((g) => g.toMap()).toList(),
    };
  }

  factory Burbuja.fromMap(Map<String, dynamic> map) {
    return Burbuja(
      nombre: map['nombre'] ?? '',
      gastos: List<CasillaGasto>.from(
        (map['gastos'] ?? []).map((g) => CasillaGasto.fromMap(g)),
      ),
    );
  }
}

class BalanceAnual {
  final int ano;
  final double totalGastado;
  final Map<String, double> desglosePorBurbuja;

  BalanceAnual({
    required this.ano,
    required this.totalGastado,
    required this.desglosePorBurbuja,
  });

  Map<String, dynamic> toMap() {
    return {
      'ano': ano,
      'totalGastado': totalGastado,
      'desglosePorBurbuja': desglosePorBurbuja,
    };
  }

  factory BalanceAnual.fromMap(Map<String, dynamic> map) {
    // Conversión segura del mapa interno de dobles
    Map<String, double> desglose = {};
    if (map['desglosePorBurbuja'] != null) {
      (map['desglosePorBurbuja'] as Map<String, dynamic>).forEach((key, value) {
        desglose[key] = value.toDouble();
      });
    }
    return BalanceAnual(
      ano: map['ano'] ?? DateTime.now().year,
      totalGastado: map['totalGastado']?.toDouble() ?? 0.0,
      desglosePorBurbuja: desglose,
    );
  }
}