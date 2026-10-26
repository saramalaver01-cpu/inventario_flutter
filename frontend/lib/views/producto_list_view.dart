import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductoListView extends StatefulWidget {
  const ProductoListView({super.key});

  @override
  State<ProductoListView> createState() => _ProductoListViewState();
}

class _ProductoListViewState extends State<ProductoListView> {
  final ProductoService _service = ProductoService();

  List<Producto> _productos = [];
  bool _cargando = true;
  String? _error;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final productos = await _service.obtenerProductos();

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  List<Producto> get _productosFiltrados {
    final consulta = _busqueda.trim().toLowerCase();

    if (consulta.isEmpty) return _productos;

    return _productos.where((producto) {
      return producto.nombre.toLowerCase().contains(consulta) ||
          producto.codigo.toLowerCase().contains(consulta) ||
          producto.categoria.toLowerCase().contains(consulta);
    }).toList();
  }

  Future<void> _nuevoProducto() async {
    final resultado = await context.push<bool>('/productos/nuevo');

    if (resultado == true && mounted) {
      await _cargarProductos();
    }
  }

  Future<void> _abrirDetalle(Producto producto) async {
    final resultado = await context.push<bool>(
      '/productos/detalle',
      extra: producto,
    );

    if (resultado == true && mounted) {
      await _cargarProductos();
    }
  }

  String _pesos(double valor) {
    return '\$${valor.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final productos = _productosFiltrados;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Volver al dashboard',
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoProducto,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (valor) {
                setState(() {
                  _busqueda = valor;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, código o categoría',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _cargarProductos,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                : productos.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _productos.isEmpty
                            ? 'Todavía no hay productos registrados.'
                            : 'No se encontraron productos.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarProductos,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        final producto = productos[index];

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.withValues(
                                alpha: 0.12,
                              ),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            title: Text(
                              producto.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Código: ${producto.codigo}\n'
                              'Categoría: ${producto.categoria}\n'
                              'Cantidad: ${producto.cantidad}',
                            ),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _pesos(producto.precio),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.chevron_right, size: 20),
                              ],
                            ),
                            onTap: () => _abrirDetalle(producto),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
