import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';
import 'producto_form_view.dart';

class ProductoDetailView extends StatefulWidget {
  final Producto producto;

  const ProductoDetailView({super.key, required this.producto});

  @override
  State<ProductoDetailView> createState() => _ProductoDetailViewState();
}

class _ProductoDetailViewState extends State<ProductoDetailView> {
  final ProductoService _service = ProductoService();

  late Producto _producto;
  bool _eliminando = false;

  @override
  void initState() {
    super.initState();
    _producto = widget.producto;
  }

  String _pesos(double valor) {
    return '\$${valor.toStringAsFixed(0)}';
  }

  Future<void> _editar() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductoFormView(producto: _producto)),
    );

    if (!mounted) return;

    if (resultado == true) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: Text(
            '¿Estás seguro de que deseas eliminar '
            '"${_producto.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      _eliminando = true;
    });

    try {
      await _service.eliminarProducto(_producto.id);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _eliminando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el producto: $e')),
      );
    }
  }

  Widget _dato({
    required String titulo,
    required String valor,
    required IconData icono,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icono, color: Colors.blue, size: 28),
        title: Text(
          titulo,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            valor,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del producto')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 12),
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: Colors.blue.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.blue,
                  size: 46,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _producto.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Código: ${_producto.codigo}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
            const SizedBox(height: 24),
            _dato(
              titulo: 'Descripción',
              valor: _producto.descripcion.isEmpty
                  ? 'Sin descripción'
                  : _producto.descripcion,
              icono: Icons.description_outlined,
            ),
            _dato(
              titulo: 'Categoría',
              valor: _producto.categoria,
              icono: Icons.category_outlined,
            ),
            _dato(
              titulo: 'Precio unitario',
              valor: _pesos(_producto.precio),
              icono: Icons.attach_money,
            ),
            _dato(
              titulo: 'Cantidad disponible',
              valor: '${_producto.cantidad} unidades',
              icono: Icons.inventory_outlined,
            ),
            _dato(
              titulo: 'Valor total del producto',
              valor: _pesos(_producto.valorTotal),
              icono: Icons.payments_outlined,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _eliminando ? null : _editar,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar producto'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _eliminando ? null : _eliminar,
              icon: _eliminando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              label: Text(
                _eliminando ? 'Eliminando producto...' : 'Eliminar producto',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
