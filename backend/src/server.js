
const express = require('express');
const Database = require('better-sqlite3');
const path = require('path');

const app = express();
const PORT = 3000;

app.use(express.json());

// Conexión con la base de datos SQLite
const dbPath = path.join(__dirname, '..', 'data', 'inventario.db');
const db = new Database(dbPath);

// Crear la tabla de productos
db.exec(`
  CREATE TABLE IF NOT EXISTS productos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    codigo TEXT NOT NULL UNIQUE,
    descripcion TEXT,
    precio REAL NOT NULL CHECK (precio >= 0),
    cantidad INTEGER NOT NULL CHECK (cantidad >= 0),
    categoria TEXT NOT NULL
  )
`);

// Ruta de prueba
app.get('/', (req, res) => {
  res.status(200).json({
    mensaje: 'API de inventario funcionando correctamente'
  });
});

// Listar todos los productos
app.get('/api/productos', (req, res) => {
  const productos = db.prepare(
    'SELECT * FROM productos ORDER BY id DESC'
  ).all();

  res.status(200).json(productos);
});

// Consultar un producto por ID
app.get('/api/productos/:id', (req, res) => {
  const producto = db.prepare(
    'SELECT * FROM productos WHERE id = ?'
  ).get(req.params.id);

  if (!producto) {
    return res.status(404).json({
      error: 'Producto no encontrado'
    });
  }

  res.status(200).json(producto);
});

// Validar los datos recibidos
function validarProducto(datos) {
  const { nombre, codigo, precio, cantidad, categoria } = datos;

  if (
    typeof nombre !== 'string' || !nombre.trim() ||
    typeof codigo !== 'string' || !codigo.trim() ||
    typeof categoria !== 'string' || !categoria.trim() ||
    precio === undefined || precio === null || precio === '' ||
    cantidad === undefined || cantidad === null || cantidad === ''
  ) {
    return 'Nombre, código, precio, cantidad y categoría son obligatorios';
  }

  if (
    !Number.isFinite(Number(precio)) ||
    Number(precio) < 0 ||
    !Number.isInteger(Number(cantidad)) ||
    Number(cantidad) < 0
  ) {
    return 'El precio debe ser no negativo y la cantidad un entero no negativo';
  }

  return null;
}

// Registrar un producto
app.post('/api/productos', (req, res) => {
  const errorValidacion = validarProducto(req.body);

  if (errorValidacion) {
    return res.status(422).json({ error: errorValidacion });
  }

  const {
    nombre,
    codigo,
    descripcion = '',
    precio,
    cantidad,
    categoria
  } = req.body;

  try {
    const resultado = db.prepare(`
      INSERT INTO productos
      (nombre, codigo, descripcion, precio, cantidad, categoria)
      VALUES (?, ?, ?, ?, ?, ?)
    `).run(
      nombre.trim(),
      codigo.trim(),
      descripcion,
      Number(precio),
      Number(cantidad),
      categoria.trim()
    );

    const producto = db.prepare(
      'SELECT * FROM productos WHERE id = ?'
    ).get(resultado.lastInsertRowid);

    res.status(201).json(producto);
  } catch (error) {
    if (error.code === 'SQLITE_CONSTRAINT_UNIQUE') {
      return res.status(422).json({
        error: 'El código del producto ya existe'
      });
    }

    console.error(error);
    res.status(500).json({ error: 'Error al registrar el producto' });
  }
});

// Actualizar un producto
app.put('/api/productos/:id', (req, res) => {
  const existente = db.prepare(
    'SELECT * FROM productos WHERE id = ?'
  ).get(req.params.id);

  if (!existente) {
    return res.status(404).json({
      error: 'Producto no encontrado'
    });
  }

  const errorValidacion = validarProducto(req.body);

  if (errorValidacion) {
    return res.status(422).json({ error: errorValidacion });
  }

  const {
    nombre,
    codigo,
    descripcion = '',
    precio,
    cantidad,
    categoria
  } = req.body;

  try {
    db.prepare(`
      UPDATE productos
      SET nombre = ?, codigo = ?, descripcion = ?,
          precio = ?, cantidad = ?, categoria = ?
      WHERE id = ?
    `).run(
      nombre.trim(),
      codigo.trim(),
      descripcion,
      Number(precio),
      Number(cantidad),
      categoria.trim(),
      req.params.id
    );

    const actualizado = db.prepare(
      'SELECT * FROM productos WHERE id = ?'
    ).get(req.params.id);

    res.status(200).json(actualizado);
  } catch (error) {
    if (error.code === 'SQLITE_CONSTRAINT_UNIQUE') {
      return res.status(422).json({
        error: 'El código del producto ya existe'
      });
    }

    console.error(error);
    res.status(500).json({ error: 'Error al actualizar el producto' });
  }
});

// Eliminar un producto
app.delete('/api/productos/:id', (req, res) => {
  const resultado = db.prepare(
    'DELETE FROM productos WHERE id = ?'
  ).run(req.params.id);

  if (resultado.changes === 0) {
    return res.status(404).json({
      error: 'Producto no encontrado'
    });
  }

  res.status(200).json({
    mensaje: 'Producto eliminado correctamente'
  });
});

// Ruta para direcciones que no existen
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`API de inventario disponible en http://localhost:${PORT}`);
});
