import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../providers/finance_provider.dart';
import '../../models/category_model.dart';
import '../../models/wish_model.dart';
import '../styles/app_theme.dart';

class AddWishModal extends StatefulWidget {
  final WishModel? wishToEdit;

  const AddWishModal({super.key, this.wishToEdit});

  @override
  State<AddWishModal> createState() => _AddWishModalState();
}

class _AddWishModalState extends State<AddWishModal> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _observationController = TextEditingController();
  final _customCategoryController = TextEditingController();

  String _selectedCategoryId = 'w1';
  bool _isCustomCategory = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.wishToEdit != null) {
      _isEditing = true;
      _nameController.text = widget.wishToEdit!.name;
      _observationController.text = widget.wishToEdit!.observation;

      final valStr = widget.wishToEdit!.value.toStringAsFixed(2)
          .replaceAll('.', ',');
      _valueController.text = valStr;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<FinanceProvider>(context, listen: false);
        try {
          final cat = provider.wishCategories.firstWhere(
                  (c) => c.name == widget.wishToEdit!.category
          );
          setState(() {
            _selectedCategoryId = cat.id;
          });
        } catch (e) {
          // Mantém padrão
        }
      });
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
                    _isEditing ? 'Editar Desejo' : 'Novo Desejo',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Valor
              TextField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.royalBlue,
                ),
                decoration: const InputDecoration(
                  prefixText: 'R\$ ',
                  hintText: '0,00',
                  labelText: 'Valor do Item',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                ],
              ),
              const Divider(),

              // Nome do Produto
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Desejo (Ex: iPhone 15)',
                  border: InputBorder.none,
                  icon: Icon(Icons.shopping_bag_outlined),
                ),
              ),
              const Divider(),

              // Observação (Link)
              TextField(
                controller: _observationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observação / Link (Opcional)',
                  border: InputBorder.none,
                  icon: Icon(Icons.link),
                  hintText: 'Cole o link do produto aqui...',
                ),
              ),
              const Divider(),

              // Categoria
              DropdownButtonFormField<String>(
                value: _isCustomCategory ? 'outros' : _selectedCategoryId,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.category_outlined),
                ),
                items: [
                  ...provider.wishCategories.map((CategoryModel category) {
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

              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _saveWish,
                child: Text(
                  _isEditing ? 'SALVAR ALTERAÇÕES' : 'CADASTRAR DESEJO',
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

  void _saveWish() {
    if (_valueController.text.isEmpty || _nameController.text.isEmpty) {
      return;
    }

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    String finalCategoryId = _selectedCategoryId;

    if (_isCustomCategory) {
      if (_customCategoryController.text.isNotEmpty) {
        finalCategoryId = provider.addNewWishCategory(_customCategoryController.text);
      } else {
        return;
      }
    }

    final valueString = _valueController.text.replaceAll('.', '').replaceAll(',', '.');
    final value = double.tryParse(valueString) ?? 0.0;

    if (_isEditing) {
      provider.editWish(
        id: widget.wishToEdit!.id,
        name: _nameController.text,
        value: value,
        categoryId: finalCategoryId,
        observation: _observationController.text,
      );
    } else {
      provider.addWish(
        name: _nameController.text,
        value: value,
        categoryId: finalCategoryId,
        observation: _observationController.text,
      );
    }

    Navigator.pop(context);
  }
}