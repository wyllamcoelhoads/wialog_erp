import 'package:flutter/material.dart';

class AppColors {
  // --------------------------------------------------------
  // Marca / Identidade Visual (Baseado na Tela de Login)
  // --------------------------------------------------------
  static const Color primary = Color(0xFF1E3A8A); // Azul escuro corporativo
  static const Color primaryDark = Color(
    0xFF152A6B,
  ); // Tom mais escuro para hover/clique
  static const Color primaryLight = Color(
    0xFF3B5BDB,
  ); // Tom mais claro para destaques

  // --------------------------------------------------------
  // Superfícies e Fundos
  // --------------------------------------------------------
  static const Color background = Color(
    0xFFF4F6F8,
  ); // Fundo cinza bem claro para o sistema

  static const Color surface =
      Colors.white; // Fundo de cartões, modais e formulários
  static const Color sidebar =
      primary; // Pode ser alterado depois se quiser a sidebar diferente

  // --------------------------------------------------------
  // Tipografia (Textos)
  // --------------------------------------------------------
  static const Color textTitle = Color(0xFF2C3E50); // Textos grandes e títulos
  static const Color textBody = Color(0xFF34495E); // Textos normais
  static const Color textMuted =
      Colors.grey; // Textos de dicas ou desabilitados

  // --------------------------------------------------------
  // Cores de Feedback / Status Universais
  // --------------------------------------------------------
  static const Color success = Color(
    0xFF2E7D32,
  ); // Verde: Pago, Concluído, Ativo
  static const Color error = Color(
    0xFFD32F2F,
  ); // Vermelho: Atrasado, Cancelado, Erro
  static const Color warning = Color(
    0xFFF57C00,
  ); // Laranja: Em Manutenção, Pendente
  static const Color info = Color(0xFF1976D2); // Azul claro: Informações gerais
}
