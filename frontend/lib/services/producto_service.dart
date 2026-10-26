import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/producto.dart';

class ProductoService {
  late final Dio _dio;

  ProductoService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['API_URL'] ?? 'http://localhost:3000/api',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  Future<List<Producto>> obtenerProductos() async {
    try {
      final respuesta = await _dio.get('/productos');

      final lista = respuesta.data as List<dynamic>;

      return lista
          .map(
            (item) => Producto.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(_mensajeError(e));
    }
  }

  Future<Producto> obtenerProducto(int id) async {
    try {
      final respuesta = await _dio.get('/productos/$id');

      return Producto.fromJson(
        Map<String, dynamic>.from(respuesta.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(_mensajeError(e));
    }
  }

  Future<Producto> crearProducto(Producto producto) async {
    try {
      final respuesta = await _dio.post('/productos', data: producto.toJson());

      return Producto.fromJson(
        Map<String, dynamic>.from(respuesta.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(_mensajeError(e));
    }
  }

  Future<Producto> actualizarProducto(int id, Producto producto) async {
    try {
      final respuesta = await _dio.put(
        '/productos/$id',
        data: producto.toJson(),
      );

      return Producto.fromJson(
        Map<String, dynamic>.from(respuesta.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(_mensajeError(e));
    }
  }

  Future<void> eliminarProducto(int id) async {
    try {
      await _dio.delete('/productos/$id');
    } on DioException catch (e) {
      throw Exception(_mensajeError(e));
    }
  }

  String _mensajeError(DioException e) {
    final data = e.response?.data;

    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'La conexión con el servidor tardó demasiado.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar con la API. Verifica que el servidor esté activo.';
    }

    return 'Error al comunicarse con la API: ${e.message ?? 'desconocido'}';
  }
}
