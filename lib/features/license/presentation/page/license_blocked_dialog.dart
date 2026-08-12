import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/license/presentation/bloc/license_event.dart';
import 'package:wialog_erp/core/theme/app_colors.dart';
import '../../domain/entities/license_entity.dart';
import '../bloc/license_bloc.dart';

class LicenseBlockedDialog extends StatelessWidget {
  final LicenseEntity license;

  const LicenseBlockedDialog({super.key, required this.license});

  @override
  Widget build(BuildContext context) {
    // Impede que o usuário feche clicando fora da caixa
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: context.appColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.all(32),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 100,
                color: context.appColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'LICENÇA BLOQUEADA POR CONTRATO',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.appColors.primary,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CNPJ: ${license.documentNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Empresa: ${license.companyName}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Seu CNPJ não está ativo no sistema de contratos da WiaLog ou existem pendências financeiras. '
                'Verifique com seu gestor de relacionamento ou entre em contato conosco para regularização imediata.',
                style: TextStyle(fontSize: 14, height: 1.5),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),
              const Text(
                'Telefone: (01) 99999-9999 - Financeiro',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!license.trustUnlockUsed)
                    OutlinedButton(
                      onPressed: () {
                        _showTrustUnlockConfirmation(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'Desbloqueio em Confiança',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: () {
                      // Ao clicar em OK sem desbloquear, desloga o usuário e volta pro Login
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: context.appColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTrustUnlockConfirmation(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(Icons.info, color: parentContext.appColors.primary),
            SizedBox(width: 8),
            Text('Informação do Sistema'),
          ],
        ),
        content: const Text(
          'O Desbloqueio em Confiança liberará o sistema por 4 dias. '
          'Regularize a situação financeira neste período para evitar um novo bloqueio definitivo da operação.\n\nDeseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Fecha o confirm
              // Dispara o evento de desbloqueio para o BLoC
              parentContext.read<LicenseBloc>().add(ApplyTrustUnlock());
            },
            child: const Text('Confirmar Desbloqueio'),
          ),
        ],
      ),
    );
  }
}
