import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductoFormView extends StatefulWidget {
  final Producto? producto;

  const ProductoFormView({super.key, this.producto});

  @override
  State<ProductoFormView> createState() => _ProductoFormViewState();
}

class _ProductoFormViewState extends State<ProductoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProductoService();

  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _categoriaController = TextEditingController();

  bool _guardando = false;

  bool get _editando => widget.producto != null;

  @override
  void initState() {
    super.initState();

    final producto = widget.producto;

    if (producto != null) {
      _nombreController.text = producto.nombre;
      _codigoController.text = producto.codigo;
      _descripcionController.text = producto.descripcion;
      _precioController.text = producto.precio.toString();
      _cantidadController.text = producto.cantidad.toString();
      _categoriaController.text = producto.categoria;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  String? _validarTexto(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa $campo';
    }
    return null;
  }

  String? _validarPrecio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el precio';
    }

    final precio = double.tryParse(valor.replaceAll(',', '.'));

    if (precio == null || precio < 0) {
      return 'Ingresa un precio válido';
    }

    return null;
  }

  String? _validarCantidad(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa la cantidad';
    }

    final cantidad = int.tryParse(valor);

    if (cantidad == null || cantidad < 0) {
      return 'Ingresa una cantidad entera válida';
    }

    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final producto = Producto(
      id: widget.producto?.id ?? 0,
      nombre: _nombreController.text.trim(),
      codigo: _codigoController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      precio: double.parse(_precioController.text.trim().replaceAll(',', '.')),
      cantidad: int.parse(_cantidadController.text.trim()),
      categoria: _categoriaController.text.trim(),
    );

    try {
      if (_editando) {
        await _service.actualizarProducto(producto.id, producto);
      } else {
        await _service.crearProducto(producto);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editando
                ? 'Producto actualizado correctamente'
                : 'Producto registrado correctamente',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Widget _campo({
    required String etiqueta,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Información del producto',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _campo(
                etiqueta: 'Nombre',
                controller: _nombreController,
                validator: (v) => _validarTexto(v, 'el nombre'),
              ),
              _campo(
                etiqueta: 'Código',
                controller: _codigoController,
                validator: (v) => _validarTexto(v, 'el código'),
              ),
              _campo(
                etiqueta: 'Descripción',
                controller: _descripcionController,
                validator: (v) => _validarTexto(v, 'la descripción'),
                maxLines: 3,
              ),
              _campo(
                etiqueta: 'Precio',
                controller: _precioController,
                validator: _validarPrecio,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              _campo(
                etiqueta: 'Cantidad disponible',
                controller: _cantidadController,
                validator: _validarCantidad,
                keyboardType: TextInputType.number,
              ),
              _campo(
                etiqueta: 'Categoría',
                controller: _categoriaController,
                validator: (v) => _validarTexto(v, 'la categoría'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_guardando ? 'Guardando...' : 'Guardar producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
