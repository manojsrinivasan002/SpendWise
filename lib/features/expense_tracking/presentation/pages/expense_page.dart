import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_category.dart';
import 'package:spend_wise/features/expense_tracking/presentation/cubit/expense_cubit.dart';
import 'package:spend_wise/features/expense_tracking/presentation/cubit/expense_state.dart';
import 'package:spend_wise/features/expense_tracking/presentation/widgets/expense_tile.dart';
import 'package:spend_wise/features/expense_tracking/presentation/widgets/my_sliver_app_bar.dart';
import 'package:spend_wise/features/expense_tracking/presentation/widgets/sticky_date_header_delegate.dart';
import 'package:spend_wise/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:spend_wise/features/settings/presentation/pages/settings_page.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late final FocusNode _inputFocusNode;
  late final TextEditingController _inputController;
  ExpenseCategory? _selectedCategory;
  final String _userCurrency = '₹';
  int _currentHintIndex = 0;
  Timer? _hintTimer;
  final currencyFormat = NumberFormat('#,##0');

  // RULE 1: Hardcoded lists should be const
  final List<String> _dynamicHints = const [
    "150 for coffee",
    "500 for taxi",
    "1200 for groceries",
    "3000 for rent",
    "250 for lunch",
  ];

  void _startHintAnimation() {
    _hintTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        _currentHintIndex = (_currentHintIndex + 1) % _dynamicHints.length;
      });
    });
  }

  @override
  void initState() {
    _inputFocusNode = FocusNode();
    _inputController = TextEditingController();
    _startHintAnimation();
    _inputFocusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _inputController.dispose();
    _hintTimer?.cancel();
    super.dispose();
  }

  void _submitExpense() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select a category first!",
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (_inputController.text.isNotEmpty) {
      context.read<ExpenseCubit>().addExpense(_inputController.text, _selectedCategory!);
    }
    _inputController.clear();
    setState(() => _selectedCategory = null);
    _inputFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: color.surface,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          _inputFocusNode.unfocus();
          _selectedCategory = null;
          _startHintAnimation();
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocConsumer<ExpenseCubit, ExpenseState>(
                  buildWhen: (previous, current) {
                    return current is! ExpenseError;
                  },
                  listener: (BuildContext context, Object? state) {
                    if (state is ExpenseError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: TextStyle(color: Theme.of(context).colorScheme.onError),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is ExpenseLoading) {
                      // RULE 2: Everything inside here is static, so the whole Center is const
                      return const Center(
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      );
                    }
                    if (state is ExpenseLoaded) {
                      final groupedExpenses = state.groupedExpenses;
                      final settingsState = context.watch<SettingsCubit>().state;
                      final double monthlyBudget = settingsState.monthlyBudgetLimit;
                      final int healthScore = state.getHealthScore(monthlyBudget);
                      final totalSpent = state.totalSpentThisMonth;
                      final remaining = state.getRemainingBudget(monthlyBudget);
                      final dailyLimit = state.getDailySafeLimit(monthlyBudget);
                      final daysLeft = state.daysLeftInMonth;
                      final sortedCategories = state.sortedCatPercentages;

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // DASHBOARD
                          MySliverAppBar(
                            moveToSettings: () {
                              HapticFeedback.heavyImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SettingsPage()),
                              );
                            },
                            goBack: () {
                              HapticFeedback.heavyImpact();
                              state.canGoBack;
                            },
                            goForward: () {
                              HapticFeedback.heavyImpact();
                              state.canGoForward;
                            },
                            formattedCurrentMonth: state.formattedCurrentMonth,
                            userCurrency: _userCurrency,
                            healthScore: healthScore,
                            daysLeft: daysLeft,
                            goBackColor: state.canGoBack ? color.onSecondary : color.inversePrimary,
                            goForwardColor: state.canGoForward
                                ? color.onSecondary
                                : color.inversePrimary,
                            totalSpent: totalSpent,
                            monthlyBudget: monthlyBudget,
                            remaining: remaining,
                            dailyLimit: dailyLimit,
                            currencyFormat: currencyFormat,
                          ),

                          // SORTED CATEGORIES
                          if (sortedCategories.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 8),
                                child: SizedBox(
                                  height: 80,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final categoryIcon = sortedCategories[index].key;
                                      final percentage = sortedCategories[index].value;
                                      return Container(
                                        width: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(18),
                                          color: color.secondary,
                                          border: Border.all(
                                            color: color.outlineVariant.withValues(alpha: 0.1),
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(categoryIcon),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              child: Divider(
                                                height: 12,
                                                indent: 10,
                                                endIndent: 10,
                                                color: color.outlineVariant.withValues(alpha: 0.1),
                                              ),
                                            ),
                                            TweenAnimationBuilder<double>(
                                              tween: Tween<double>(begin: 0, end: percentage),
                                              duration: const Duration(milliseconds: 1000),
                                              builder: (context, value, child) => Text(
                                                "${value.toStringAsFixed(0)}%",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: color.onSurface,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                                    itemCount: sortedCategories.length,
                                  ),
                                ),
                              ),
                            ),

                          // THE EXPENSE LIST
                          if (groupedExpenses.isEmpty)
                            SliverToBoxAdapter(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(30),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: color.inverseSurface,
                                      ),
                                      child: Icon(
                                        Icons.receipt_long_rounded,
                                        size: 64,
                                        color: color.inversePrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      "Your ledger is clean.",
                                      style: text.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Type your expenses below to start tracking.",
                                      style: text.titleSmall?.copyWith(color: color.inversePrimary),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...groupedExpenses.entries.map((entry) {
                              return SliverMainAxisGroup(
                                slivers: [
                                  SliverPersistentHeader(
                                    delegate: StickyDateHeaderDelegate(title: entry.key),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        childCount: entry.value.length,
                                        (context, index) {
                                          final expense = entry.value[index];
                                          final isSpikedExpense = context
                                              .read<ExpenseCubit>()
                                              .isSpikedExpense(expense, monthlyBudget);
                                          bool isLast = index == entry.value.length - 1;
                                          final isAnomaly = isSpikedExpense == true;
                                          return ExpenseTile(
                                            expense: expense,
                                            currencyFormat: currencyFormat,
                                            userCurrency: _userCurrency,
                                            isAnomaly: isAnomaly,
                                            isLast: isLast,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // FLOATING INPUT
              _buildFloatingInputField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingInputField() {
    final isFocused = _inputFocusNode.hasFocus;
    final color = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutQuint,
      margin: isFocused
          ? const EdgeInsets.only(left: 16, right: 16, bottom: 16)
          : const EdgeInsets.only(left: 50, right: 50, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: color.secondary,
        borderRadius: isFocused ? BorderRadius.circular(22) : BorderRadius.circular(30),
        border: Border.all(color: color.outline.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: isFocused ? BorderRadius.circular(22) : BorderRadius.circular(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuint,
              child: isFocused
                  ? SizedBox(height: 55, child: _buildCategoriesList())
                  : const SizedBox.shrink(),
            ),
            _buildExpenseInputField(isFocused),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseInputField(bool isFocused) {
    final color = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Positioned(
          left: 16,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[...previousChildren, if (currentChild != null) currentChild],
              );
            },
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _inputController.text.isEmpty && !isFocused
                ? Text(
                    _dynamicHints[_currentHintIndex],
                    key: ValueKey<int>(_currentHintIndex),
                    style: TextStyle(color: color.onSecondary.withValues(alpha: 0.4), fontSize: 16),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        TextField(
          controller: _inputController,
          focusNode: _inputFocusNode,
          onChanged: (_) => setState(() => _hintTimer?.cancel()),
          cursorColor: color.onSecondary,
          onTap: () => _hintTimer?.cancel(),
          decoration: InputDecoration(
            hintText: isFocused && _inputController.text.isEmpty ? "" : "",
            hintStyle: TextStyle(color: color.onSecondary.withValues(alpha: 0.3)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            suffixIcon: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _inputController.text.isNotEmpty ? 1.0 : 0.3,
              child: IconButton(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  if (_inputController.text.isNotEmpty) _submitExpense();
                },
                icon: CircleAvatar(
                  backgroundColor: color.primary,
                  radius: 16,
                  child: Icon(Icons.arrow_upward_rounded, color: color.onPrimary, size: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: ExpenseCategory.values.length,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final category = ExpenseCategory.values[index];
        final isSelected = _selectedCategory == category;
        final color = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(
              category.displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color.onPrimary : color.onSurface,
              ),
            ),
            selected: isSelected,
            selectedColor: color.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide.none,
            backgroundColor: color.inverseSurface,
            showCheckmark: false,
            onSelected: (selected) {
              if (selected) setState(() => _selectedCategory = category);
            },
          ),
        );
      },
    );
  }
}
