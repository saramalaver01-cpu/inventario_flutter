import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/producto.dart';
import '../views/dashboard_view.dart';
import '../views/producto_list_view.dart';
import '../views/producto_detail_view.dart';
import '../views/producto_form_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'inicio',
      builder: (context, state) => const DashboardView(),
    ),
    GoRoute(
      path: '/productos',
      name: 'productos',
      builder: (context, state) => const ProductoListView(),
    ),
    GoRoute(
      path: '/productos/nuevo',
      name: 'nuevo-producto',
      builder: (context, state) => const ProductoFormView(),
    ),
    GoRoute(
      path: '/productos/detalle',
      name: 'detalle-producto',
      builder: (context, state) {
        final producto = state.extra;

        if (producto is! Producto) {
          return const Scaffold(
            body: Center(child: Text('No se recibió un producto válido.')),
          );
        }

        return ProductoDetailView(producto: producto);
      },
    ),
    GoRoute(
      path: '/productos/editar',
      name: 'editar-producto',
      builder: (context, state) {
        final producto = state.extra;

        if (producto is! Producto) {
          return const Scaffold(
            body: Center(child: Text('No se recibió un producto válido.')),
          );
        }

        return ProductoFormView(producto: producto);
      },
    ),
  ],
);
