import 'package:flutter/material.dart';

// Classe simples para gerenciar o XP globalmente no App
class UserData {
  // Começa com algum XP para animar o usuário
  static ValueNotifier<int> totalXP = ValueNotifier<int>(1250);

  static void addXP(int amount) {
    totalXP.value += amount;
  }
}