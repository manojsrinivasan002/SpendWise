import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_category.dart';
import 'package:spend_wise/features/expense_tracking/presentation/cubit/expense_cubit.dart';
import 'package:spend_wise/features/expense_tracking/presentation/cubit/expense_state.dart';
import 'package:spend_wise/features/expense_tracking/presentation/widgets/sticky_date_header_delegate.dart';

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

  final List<String> _dynamicHints = [
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

  void _showAnomalyDetails(List<String> insights) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to size itself properly
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final color = Theme.of(context).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_rounded, color: Colors.red, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Spending Anomaly Detected",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 🚨 Map through our dynamic list of insights!
                ...insights.map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          insight.contains("💡")
                              ? Icons.lightbulb_outline
                              : Icons.analytics_outlined,
                          color: color.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(insight, style: const TextStyle(fontSize: 15, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("I Understand"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                      final double monthlyBudget = 30000;
                      final int healthScore = state.getHealthScore(monthlyBudget);
                      final totalSpent = state.totalSpentThisMonth;
                      final remaining = state.getRemainingBudget(monthlyBudget);
                      final dailyLimit = state.getDailySafeLimit(monthlyBudget);
                      final daysLeft = state.daysLeftInMonth;

                      return CustomScrollView(
                        physics: BouncingScrollPhysics(),
                        slivers: [
                          // DASHBOARD
                          SliverAppBar(
                            expandedHeight: 330,
                            collapsedHeight: 60,
                            pinned: true,
                            stretch: true,
                            backgroundColor: color.surface,
                            scrolledUnderElevation: 0,
                            onStretchTrigger: () async {
                              HapticFeedback.heavyImpact();
                            },
                            title: Text("Spend Wiser", style: text.titleMedium),
                            centerTitle: true,
                            actions: [
                              IconButton(
                                onPressed: () {
                                  //TODO: NEED TO WORK ON SETTINGS BUTTON..
                                },
                                icon: Icon(Icons.settings_outlined),
                              ),
                            ],
                            flexibleSpace: FlexibleSpaceBar(
                              background: Padding(
                                padding: EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: color.secondary,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Time machine and health score
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: state.canGoBack
                                                ? () => context.read<ExpenseCubit>().previousMonth()
                                                : null,
                                            borderRadius: BorderRadius.circular(20),
                                            child: Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(
                                                Icons.chevron_left,
                                                size: 24,
                                                color: state.canGoBack
                                                    ? color.onSecondary
                                                    : color.inversePrimary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            state.formattedCurrentMonth,
                                            style: text.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          InkWell(
                                            onTap: state.canGoForward
                                                ? () => context.read<ExpenseCubit>().nextMonth()
                                                : null,
                                            borderRadius: BorderRadius.circular(20),
                                            child: Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(
                                                Icons.chevron_right,
                                                size: 24,
                                                color: state.canGoForward
                                                    ? color.onSecondary
                                                    : color.inversePrimary,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: healthScore >= 50
                                                  ? Colors.green.withValues(alpha: 0.1)
                                                  : Colors.red.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: healthScore >= 50
                                                    ? Colors.green.withValues(alpha: 0.5)
                                                    : Colors.red.withValues(alpha: 0.5),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.health_and_safety_rounded,
                                                  color: healthScore >= 50
                                                      ? Colors.green
                                                      : Colors.red,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  healthScore.toString(),
                                                  style: TextStyle(
                                                    color: healthScore >= 50
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 24),
                                      // Total spent
                                      Text(
                                        "Total Spent this month",
                                        style: text.titleSmall?.copyWith(
                                          color: color.inversePrimary,
                                        ),
                                      ),

                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          TweenAnimationBuilder(
                                            tween: Tween(begin: 0, end: totalSpent),
                                            duration: Duration(milliseconds: 1000),
                                            curve: Curves.easeOutCubic,
                                            builder: (context, value, child) => Text(
                                              "$_userCurrency${currencyFormat.format(value)}",
                                              style: text.headlineLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -1,
                                                color: color.primary,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          TweenAnimationBuilder(
                                            tween: Tween(begin: 0, end: monthlyBudget),
                                            duration: Duration(milliseconds: 1000),
                                            curve: Curves.easeOutCubic,
                                            builder: (context, value, child) => Text(
                                              "/ $_userCurrency${currencyFormat.format(monthlyBudget)}",
                                              style: text.titleMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      // Remaining, days left, daily limit
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // remaining
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Remaining",
                                                style: text.labelMedium?.copyWith(
                                                  color: color.inversePrimary,
                                                ),
                                              ),
                                              TweenAnimationBuilder<double>(
                                                tween: Tween<double>(begin: 0, end: remaining),
                                                duration: const Duration(milliseconds: 1000),
                                                builder: (context, value, child) => Text(
                                                  "$_userCurrency${currencyFormat.format(value)}",
                                                  style: text.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: 1,
                                            height: 30,
                                            color: color.outlineVariant.withValues(alpha: 0.2),
                                          ),

                                          // days left
                                          Column(
                                            children: [
                                              Text(
                                                "Days Left",
                                                style: text.labelMedium?.copyWith(
                                                  color: color.inversePrimary,
                                                ),
                                              ),
                                              TweenAnimationBuilder<double>(
                                                tween: Tween<double>(
                                                  begin: 0,
                                                  end: daysLeft.toDouble(),
                                                ),
                                                duration: Duration(milliseconds: 1000),

                                                builder: (context, value, child) {
                                                  return Text(
                                                    value.toInt().toString(),
                                                    style: text.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: 1,
                                            height: 30,
                                            color: color.outlineVariant.withValues(alpha: 0.2),
                                          ),

                                          // daily limit
                                          Column(
                                            children: [
                                              Text(
                                                "Daily Limit",
                                                style: text.labelMedium?.copyWith(
                                                  color: color.inversePrimary,
                                                ),
                                              ),
                                              TweenAnimationBuilder<double>(
                                                tween: Tween<double>(begin: 0, end: dailyLimit),
                                                duration: const Duration(milliseconds: 1000),
                                                builder: (context, value, child) => Text(
                                                  "$_userCurrency${currencyFormat.format(value)}",
                                                  style: text.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        childCount: entry.value.length,
                                        (context, index) {
                                          final expense = entry.value[index];
                                          final anomalyInsights = context
                                              .read<ExpenseCubit>()
                                              .getAnomalyInsights(expense);
                                          bool isLast = index == entry.value.length - 1;
                                          final isAnomaly = anomalyInsights != null;
                                          return Column(
                                            children: [
                                              ListTile(
                                                leading: Text(
                                                  expense.expenseCategory.displayIcon,
                                                  style: text.titleMedium,
                                                ),
                                                title: Text(
                                                  expense.title,
                                                  style: text.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "-$_userCurrency${currencyFormat.format(expense.amount)}",
                                                  style: text.titleSmall?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                trailing: isAnomaly
                                                    ? Icon(
                                                        Icons.trending_up_rounded,
                                                        size: 18,
                                                        color: Colors.red.shade900,
                                                      )
                                                    // ? Icon(
                                                    //     // onPressed: () => _showAnomalyDetails(
                                                    //     //   anomalyInsights,
                                                    //     // ), // Pass the list!
                                                    // icon: Icon(
                                                    //   Icons.trending_up_rounded,
                                                    //   color: Colors.red.shade900,
                                                    //   size: 18,
                                                    // ),
                                                    //   )
                                                    : const SizedBox.shrink(),
                                              ),
                                              isLast
                                                  ? SizedBox.shrink()
                                                  : Divider(
                                                      indent: 55,
                                                      height: 0,
                                                      thickness: 0.5,
                                                      color: color.outlineVariant.withValues(
                                                        alpha: 0.2,
                                                      ),
                                                    ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),

              // --- 4. FLOATING INPUT ---
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
          ? const EdgeInsets.only(left: 16, right: 16, bottom: 5)
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
                  : const SizedBox(height: 0),
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
