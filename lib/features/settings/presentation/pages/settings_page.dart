import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spend_wise/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:spend_wise/features/settings/presentation/cubit/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _budgetController = TextEditingController();
  final currencyFormat = NumberFormat('#,##0');

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text("Settings", style: text.titleMedium), centerTitle: true),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              Container(margin: const EdgeInsets.all(30), child: _buildFinancialCard(state)),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: _buildAppearanceCard(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFinancialCard(SettingsState state) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Financials", style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: color.secondary,
            border: Border.all(
              color: color.outline.withValues(alpha: 0.1),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(35),
          ),
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined, size: 20),
            title: Text("Set Target Limit", style: text.titleMedium),
            subtitle: Text("Current: ₹${currencyFormat.format(state.monthlyBudgetLimit)}"),
            trailing: TextButton(
              onPressed: () => _showBudgetDialog(context, state),
              child: const Text("Edit"),
            ),
          ),
        ),
      ],
    );
  }

  // APPEARANCE
  Widget _buildAppearanceCard(SettingsState state) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Appearance", style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: color.secondary,
            border: Border.all(
              color: color.outline.withValues(alpha: 0.1),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: SwitchListTile(
            secondary: Icon(
              state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: color.onSecondary,
              size: 20,
            ),
            title: Text("Dark Mode", style: text.titleMedium),
            value: state.isDarkMode,
            activeColor: color.onSecondary,
            onChanged: (bool value) {
              HapticFeedback.heavyImpact();
              context.read<SettingsCubit>().toggleTheme(value);
            },
            splashRadius: 30,
          ),
        ),
      ],
    );
  }

  void _showBudgetDialog(BuildContext context, SettingsState state) {
    _budgetController.text = state.monthlyBudgetLimit.toStringAsFixed(0);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          "Update Limit",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          cursorColor: Theme.of(context).colorScheme.onSecondary,
          decoration: InputDecoration(
            labelText: "Monthly Limit",
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
            prefixText: "₹ ",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Cancel",
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final newBudget = double.tryParse(_budgetController.text);
              if (newBudget != null && newBudget > 0) {
                context.read<SettingsCubit>().updateBudget(newBudget);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
