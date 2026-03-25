import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MySliverAppBar extends StatelessWidget {
  final void Function()? moveToSettings, goBack, goForward;
  final String formattedCurrentMonth, userCurrency;
  final int healthScore, daysLeft;
  final Color goBackColor, goForwardColor;
  final double totalSpent, monthlyBudget, remaining, dailyLimit;
  final NumberFormat currencyFormat;

  const MySliverAppBar({
    super.key,
    required this.moveToSettings,
    required this.goBack,
    required this.goForward,
    required this.formattedCurrentMonth,
    required this.userCurrency,
    required this.healthScore,
    required this.daysLeft,
    required this.goBackColor,
    required this.goForwardColor,
    required this.totalSpent,
    required this.monthlyBudget,
    required this.remaining,
    required this.dailyLimit,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return SliverAppBar(
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
        IconButton(onPressed: moveToSettings, icon: const Icon(Icons.settings_outlined, size: 20)),
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
                      onTap: goBack,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.chevron_left, size: 24, color: goBackColor),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedCurrentMonth,
                      style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: goForward,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.chevron_right, size: 24, color: goForwardColor),
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            color: healthScore >= 50 ? Colors.green : Colors.red,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            healthScore.toString(),
                            style: TextStyle(
                              color: healthScore >= 50 ? Colors.green : Colors.red,
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
                  style: text.titleSmall?.copyWith(color: color.inversePrimary),
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
                        "$userCurrency${currencyFormat.format(value)}",
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
                        "/ $userCurrency${currencyFormat.format(monthlyBudget)}",
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
                          style: text.labelMedium?.copyWith(color: color.inversePrimary),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: remaining),
                          duration: const Duration(milliseconds: 1000),
                          builder: (context, value, child) => Text(
                            "$userCurrency${currencyFormat.format(value)}",
                            style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                          style: text.labelMedium?.copyWith(color: color.inversePrimary),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: daysLeft.toDouble()),
                          duration: Duration(milliseconds: 1000),

                          builder: (context, value, child) {
                            return Text(
                              value.toInt().toString(),
                              style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                          style: text.labelMedium?.copyWith(color: color.inversePrimary),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: dailyLimit),
                          duration: const Duration(milliseconds: 1000),
                          builder: (context, value, child) => Text(
                            "$userCurrency${currencyFormat.format(value)}",
                            style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
    );
  }
}
