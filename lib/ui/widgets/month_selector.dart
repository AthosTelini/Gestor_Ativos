import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../utils/formatters.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final currentMonth = provider.selectedMonth;

    // Gera lista de 12 meses (6 para trás, 6 para frente)
    final now = DateTime.now();
    final months = List.generate(13, (index) {
      final date = DateTime(now.year, now.month - 6 + index);
      return DateFormat('MM/yyyy').format(date);
    });

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final monthRef = months[index];
          final isSelected = monthRef == currentMonth;
          final date = DateFormat('MM/yyyy').parse(monthRef);
          final monthName = DateFormat('MMM', 'pt_BR').format(date).toUpperCase();

          return GestureDetector(
            onTap: () => provider.changeMonth(monthRef),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: isSelected ? 60 : 45,
              height: isSelected ? 60 : 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                border: isSelected
                    ? Border.all(color: Colors.white.withOpacity(0.5))
                    : null,
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
                    : [],
              ),
              child: Center(
                child: Text(
                  monthName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: isSelected ? 14 : 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}