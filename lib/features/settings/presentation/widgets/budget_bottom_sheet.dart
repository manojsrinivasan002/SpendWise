import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/features/settings/presentation/cubit/settings_cubit.dart';

class BudgetBottomSheet extends StatefulWidget {
  final double currentBudget;
  final String currencySymbol;
  const BudgetBottomSheet({super.key, required this.currentBudget, required this.currencySymbol});

  @override
  State<BudgetBottomSheet> createState() => _BudgetBottomSheetState();
}

class _BudgetBottomSheetState extends State<BudgetBottomSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Set Monthly Budget"),
          SizedBox(height: 16),
          Text("Quick Select: "),
          SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [10000, 25000, 50000, 100000].map((amount) {
              return ActionChip(
                label: Text("${widget.currencySymbol}$amount"),
                onPressed: () {
                  _controller.text = amount.toString();
                },
              );
            }).toList(),
          ),
          SizedBox(height: 24),
          TextField(controller: _controller, keyboardType: TextInputType.number, autofocus: true),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
                final newBudget = double.tryParse(_controller.text);
                if (newBudget != null) {
                  context.read<SettingsCubit>().updateBudgetLimit(newBudget);
                }
                Navigator.pop(context);
              },
              child: Text("Save Budget"),
            ),
          ),
        ],
      ),
    );
  }
}
