import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/finance_provider.dart';
import '../../utils/formatters.dart';
import '../../models/wish_model.dart';
import '../styles/app_theme.dart';
import '../widgets/add_wish_modal.dart';
import '../widgets/wish_detail_modal.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final globalTotal = provider.globalTotalAmount;
    final wishesTotal = provider.totalWishesAmount;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Cabeçalho (Branco)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Meus Desejos',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<SortOption>(
                        icon: const Icon(Icons.sort, color: AppTheme.royalBlue, size: 20),
                        onSelected: (SortOption result) {
                          provider.setSortOption(result);
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
                          const PopupMenuItem<SortOption>(
                            value: SortOption.recent,
                            child: Row(
                              children: [
                                Icon(Icons.access_time, size: 18, color: Colors.grey),
                                SizedBox(width: 8),
                                Text('Recentes (Última ed.)'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<SortOption>(
                            value: SortOption.value,
                            child: Row(
                              children: [
                                Icon(Icons.attach_money, size: 18, color: Colors.grey),
                                SizedBox(width: 8),
                                Text('Valor (Menor > Maior)'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<SortOption>(
                            value: SortOption.name,
                            child: Row(
                              children: [
                                Icon(Icons.sort_by_alpha, size: 18, color: Colors.grey),
                                SizedBox(width: 8),
                                Text('Nome (A-Z)'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Caixa Global com Olho
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Caixa Global',
                        style: TextStyle(
                          color: AppTheme.darkBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: provider.toggleObscure,
                        child: Icon(
                          provider.isObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  // Valor Caixa Global
                  provider.isObscure
                      ? const Text(
                    'R\$ •••••',
                    style: TextStyle(
                      color: AppTheme.royalBlue,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : Text(
                    Formatters.currency(globalTotal),
                    style: const TextStyle(
                      color: AppTheme.royalBlue,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().scale(),

                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        builder: (context) => const AddWishModal(),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('NOVO DESEJO'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.royalBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Container Azul (Lista + Rodapé Total)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppTheme.backgroundGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Lista de Desejos
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: provider.wishes.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                          padding: const EdgeInsets.only(top: 30, bottom: 20),
                          itemCount: provider.wishes.length,
                          itemBuilder: (context, index) {
                            final wish = provider.wishes[index];
                            return _buildWishCard(context, wish, globalTotal, provider)
                                .animate()
                                .fadeIn(delay: (50 * index).ms)
                                .slideY(begin: 0.1);
                          },
                        ),
                      ),
                    ),

                    // Rodapé: Total de Desejos (Colado no fundo)
                    Container(
                      // Padding ajustado para não ficar colado demais, mas usar o espaço
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        border: const Border(
                          top: BorderSide(color: Colors.white12, width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total da Lista",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          provider.isObscure
                              ? const Text(
                            'R\$ •••••',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                              : Text(
                            Formatters.currency(wishesTotal),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stars, size: 80, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            "Sua lista de desejos está vazia",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildWishCard(BuildContext context, WishModel wish, double globalTotal, FinanceProvider provider) {
    double difference = globalTotal - wish.value;
    bool canBuy = difference >= 0;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => WishDetailModal(wish: wish),
        );
      },
      onLongPress: () {
        _showOptions(context, wish, provider);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.favorite_border,
                color: AppTheme.royalBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wish.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  Text(
                    wish.category,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  provider.isObscure
                      ? Text(
                    'Valor: R\$ •••••',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  )
                      : Text(
                    'Valor: ${Formatters.currency(wish.value)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  canBuy ? 'Sobra:' : 'Falta:',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                provider.isObscure
                    ? Text(
                  'R\$ •••••',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: canBuy ? AppTheme.mintNeon : Colors.redAccent,
                  ),
                )
                    : Text(
                  canBuy
                      ? '+${Formatters.currency(difference)}'
                      : Formatters.currency(difference),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: canBuy ? AppTheme.mintNeon : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, WishModel wish, FinanceProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: AppTheme.royalBlue),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                    ),
                    builder: (context) => AddWishModal(wishToEdit: wish),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Excluir'),
                onTap: () {
                  provider.deleteWish(wish.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}