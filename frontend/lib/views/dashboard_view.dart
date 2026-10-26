import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ProductoService _service = ProductoService();

  List<Producto> _productos = [];
  bool _cargando = true;
  String? _error;

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

  Future<void> _abrirProductos() async {
    await context.push('/productos');

    if (mounted) {
      await _cargarProductos();
    }
  }

  String _pesos(double valor) {
    return '\$${valor.toStringAsFixed(0)}';
  }

  int get _totalUnidades {
    return _productos.fold(0, (total, producto) => total + producto.cantidad);
  }

  double get _valorInventario {
    return _productos.fold(
      0.0,
      (total, producto) => total + producto.valorTotal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            tooltip: 'Actualizar información',
            onPressed: _cargarProductos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _mostrarError()
            : _mostrarDashboard(),
      ),
    );
  }

  Widget _mostrarError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar el inventario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _cargarProductos,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mostrarDashboard() {
    final recientes = _productos.reversed.take(5).toList();

    return RefreshIndicator(
      onRefresh: _cargarProductos,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Panel principal',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Consulta y administra los productos de tu inventario.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          _tarjetaResumen(
            titulo: 'Productos registrados',
            valor: '${_productos.length}',
            icono: Icons.inventory_2_outlined,
            color: Colors.blue,
          ),

          _tarjetaResumen(
            titulo: 'Unidades disponibles',
            valor: '$_totalUnidades',
            icono: Icons.widgets_outlined,
            color: Colors.green,
          ),

          _tarjetaResumen(
            titulo: 'Valor del inventario',
            valor: _pesos(_valorInventario),
            icono: Icons.payments_outlined,
            color: Colors.orange,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _abrirProductos,
              icon: const Icon(Icons.list_alt),
              label: const Text('Ver todos los productos'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Productos recientes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          if (recientes.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Todavía no hay productos registrados.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...recientes.map(
              (producto) => Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.inventory_2_outlined),
                  ),
                  title: Text(
                    producto.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Código: ${producto.codigo}\n'
                    'Cantidad: ${producto.cantidad}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    _pesos(producto.precio),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: _abrirProductos,
                ),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _tarjetaResumen({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icono, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
