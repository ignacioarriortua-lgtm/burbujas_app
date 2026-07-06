// lib/services/database_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/burbuja_model.dart';

class DatabaseService {
  static const String _keyBurbujas = 'mis_burbujas_data';
  static const String _keyBalances = 'mis_balances_data';

  // --- GUARDAR BURBUJAS ---
  static Future<void> guardarBurbujas(List<Burbuja> burbujas) async {
    final prefs = await SharedPreferences.getInstance();
    final String dataCodificada = jsonEncode(burbujas.map((b) => b.toMap()).toList());
    await prefs.setString(_keyBurbujas, dataCodificada);
  }

  // --- LEER BURBUJAS ---
  static Future<List<Burbuja>> cargarBurbujas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataCodificada = prefs.getString(_keyBurbujas);
    
    if (dataCodificada == null) {
      // Si la app se abre por primera vez y no hay nada guardado, devolvemos tus 3 burbujas iniciales
      return [
        Burbuja(nombre: "Obra Corrientes", gastos: []),
        Burbuja(nombre: "Gastos Personales", gastos: []),
        Burbuja(nombre: "Tarjetas Banco", gastos: []),
      ];
    }

    final List<dynamic> dataDecodificada = jsonDecode(dataCodificada);
    return dataDecodificada.map((b) => Burbuja.fromMap(b)).toList();
  }

  // --- GUARDAR HISTORIAL DE BALANCES ---
  static Future<void> guardarBalances(List<BalanceAnual> balances) async {
    final prefs = await SharedPreferences.getInstance();
    final String dataCodificada = jsonEncode(balances.map((b) => b.toMap()).toList());
    await prefs.setString(_keyBalances, dataCodificada);
  }

  // --- LEER HISTORIAL DE BALANCES ---
  static Future<List<BalanceAnual>> cargarBalances() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataCodificada = prefs.getString(_keyBalances);
    
    if (dataCodificada == null) return [];

    final List<dynamic> dataDecodificada = jsonDecode(dataCodificada);
    return dataDecodificada.map((b) => BalanceAnual.fromMap(b)).toList();
  }
}