
const Database = require('better-sqlite3');
const path = require('path');

const dbPath = path.join(__dirname, 'data', 'inventario.db');
const db = new Database(dbPath);

const productos = [
  ['Laptop Lenovo', 'INV001', 'Portátil para trabajo y estudio', 2500000, 5, 'Tecnología'],
  ['Mouse inalámbrico', 'INV002', 'Mouse USB inalámbrico', 45000, 20, 'Accesorios'],
  ['Teclado mecánico', 'INV003', 'Teclado mecánico USB', 180000, 10, 'Accesorios'],
  ['Monitor Samsung', 'INV004', 'Monitor de 24 pulgadas', 650000, 7, 'Tecnología'],
  ['Memoria USB 32GB', 'INV005', 'Memoria USB de 32 GB', 25000, 30, 'Almacenamiento'],
  ['Disco SSD 1TB', 'INV006', 'Unidad de estado sólido de 1 TB', 320000, 8, 'Almacenamiento'],
  ['Impresora HP', 'INV007', 'Impresora multifuncional', 750000, 4, 'Oficina'],
  ['Audífonos', 'INV008', 'Audífonos con micrófono', 90000, 15, 'Accesorios'],
  ['Webcam HD', 'INV009', 'Cámara web para videollamadas', 120000, 6, 'Tecnología'],
  ['Regulador eléctrico', 'INV010', 'Protector de voltaje', 85000, 12, 'Oficina']
];

const insertar = db.prepare(`
  INSERT OR IGNORE INTO productos
  (nombre, codigo, descripcion, precio, cantidad, categoria)
  VALUES (?, ?, ?, ?, ?, ?)
`);

const insertarTodos = db.transaction((lista) => {
  for (const producto of lista) {
    insertar.run(...producto);
  }
});

insertarTodos(productos);

const total = db.prepare(
  'SELECT COUNT(*) AS total FROM productos'
).get();

console.log(`Productos registrados en la base de datos: ${total.total}`);

db.close();
