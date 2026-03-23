import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:spend_wise/features/settings/presentation/cubit/settings_state.dart';
import 'package:spend_wise/features/settings/presentation/widgets/budget_bottom_sheet.dart';
import 'package:spend_wise/features/settings/presentation/widgets/settings_card_group.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(children: [_buildFinancialCoreCard(context, state)]);
        },
      ),
    );
  }

  Widget _buildFinancialCoreCard(BuildContext context, SettingsState state) {
    return SettingsCardGroup(
      title: "Financial Core",
      children: [
        ListTile(
          leading: Icon(Icons.account_balance_wallet_rounded, color: Colors.green),
          title: Text("Monthly Budget Limit"),
          subtitle: Text(
            "Currently: ${state.currencySymbol}${state.monthlyBudgetLimit.toStringAsFixed(2)}",
          ),
          trailing: IconButton(
            onPressed: () => _showBudgetBottomSheet(context, state),
            icon: Icon(Icons.edit),
          ),
        ),
        Divider(height: 1, indent: 40),
        ListTile(
          leading: Icon(Icons.currency_exchange_rounded, color: Colors.blue),
          title: Text('Base Currency'),
          subtitle: Text(state.currencySymbol),
          trailing: IconButton(
            onPressed: () {
              showCurrencyPicker(
                context: context,
                showFlag: true,
                showCurrencyName: true,
                showCurrencyCode: true,
                onSelect: (Currency currency) {
                  context.read<SettingsCubit>().updateCurrencySymbol(currency.symbol);
                },
              );
            },
            icon: Icon(Icons.chevron_right_rounded),
          ),
        ),
      ],
    );
  }

  void _showBudgetBottomSheet(BuildContext context, SettingsState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BudgetBottomSheet(
          currentBudget: state.monthlyBudgetLimit,
          currencySymbol: state.currencySymbol,
        );
      },
    );
  }
}
