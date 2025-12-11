import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../styles/app_theme.dart';

class AddTransactionModal extends StatefulWidget {
  final TransactionModel? transactionToEdit;

  const AddTransactionModal({super.key, this.transactionToEdit});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();

  String _selectedCategoryId = '1';
  bool _isRecurring = false;
  bool _isCustomCategory = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      _isEditing = true;
      _descriptionController.text = widget.transactionToEdit!.description;

      final amountStr = widget.transactionToEdit!.amount.toStringAsFixed(2)
          .replaceAll('.', ',');
      _amountController.text = amountStr;

      // Tenta encontrar a categoria pelo nome para setar o ID correto
      // Isso será feito no build pois precisamos do provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<FinanceProvider>(context, listen: false);
        try {
          final cat = provider.categories.firstWhere(
                  (c) => c.name == widget.transactionToEdit!.category
          );
          setState(() {
            _selectedCategoryId = cat.id;
          });
        } catch (e) {
          // Se não achar, mantém a padrão
        }
      });

      _isRecurring = widget.transactionToEdit!.isRecurring;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Editar Entrada' : 'Nova Entrada',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.royalBlue,
                ),
                decoration: const InputDecoration(
                  prefixText: 'R\$ ',
                  hintText: '0,00',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                ],
              ),
              const Divider(),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (Opcional)',
                  border: InputBorder.none,
                  icon: Icon(Icons.edit_note),
                ),
              ),
              const Divider(),
              DropdownButtonFormField<String>(
                value: _isCustomCategory ? 'outros' : _selectedCategoryId,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.category_outlined),
                ),
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                items: [
                  ...provider.categories.map((CategoryModel category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 18, color: category.color),
                          const SizedBox(width: 10),
                          Text(category.name),
                        ],
                      ),
                    );
                  }),
                  const DropdownMenuItem(
                    value: 'outros',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, size: 18, color: Colors.grey),
                        SizedBox(width: 10),
                        Text('Outros (Criar nova...)'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    if (value == 'outros') {
                      _isCustomCategory = true;
                      _selectedCategoryId = 'outros';
                    } else {
                      _isCustomCategory = false;
                      _selectedCategoryId = value!;
                    }
                  });
                },
              ),

              if (_isCustomCategory)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: TextField(
                    controller: _customCategoryController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Nome da Nova Categoria',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),

              const Divider(),
              // Só mostra opção de recorrência se for criação nova (para simplificar edição)
              if (!_isEditing)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Repetir no próximo mês?'),
                  value: _isRecurring,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (bool value) {
                    setState(() {
                      _isRecurring = value;
                    });
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _saveTransaction,
                child: Text(
                  _isEditing ? 'SALVAR ALTERAÇÕES' : 'ADICIONAR ENTRADA',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (_amountController.text.isEmpty) {
      return;
    }

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    String finalCategoryId = _selectedCategoryId;

    if (_isCustomCategory) {
      if (_customCategoryController.text.isNotEmpty) {
        finalCategoryId = provider.addNewCategory(_customCategoryController.text);
      } else {
        return;
      }
    }

    final amountString = _amountController.text.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(amountString) ?? 0.0;

    // Descrição padrão se estiver vazia
    String description = _descriptionController.text;
    if (description.isEmpty) {
      description = "Entrada sem descrição";
    }

    if (_isEditing) {
      provider.editTransaction(
        id: widget.transactionToEdit!.id,
        description: description,
        amount: amount,
        categoryId: finalCategoryId,
      );
    } else {
      provider.addTransaction(
        description: description,
        amount: amount,
        categoryId: finalCategoryId,
        isRecurring: _isRecurring,
      );
    }

    Navigator.pop(context);
  }
}