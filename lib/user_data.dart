import 'package:flutter/material.dart';

// Classe simples para gerenciar o XP globalmente no App
class UserData {
  // Valor observável do XP (começa com 0, mas será atualizado pelo banco)
  static ValueNotifier<int> totalXP = ValueNotifier<int>(0);

  static void addXP(int amount) {
    totalXP.value += amount;
  }
}