\# Sistema de Gestión de Inventario



Aplicación de gestión de inventario desarrollada con Flutter y una API REST creada con Node.js, Express y SQLite.



\## Funcionalidades



\- Consultar el listado de productos.

\- Ver los detalles de un producto.

\- Registrar productos nuevos.

\- Editar productos existentes.

\- Eliminar productos.

\- Validar los datos antes de guardarlos.

\- Evitar códigos de producto duplicados.

\- Consultar estadísticas generales del inventario desde el dashboard.

\- Guardar la información en una base de datos SQLite.



\## Tecnologías utilizadas



\### Frontend

\- Flutter

\- Dart

\- Dio para las solicitudes HTTP.

\- go\_router para la navegación.

\- flutter\_dotenv para la configuración de la URL de la API.



\### Backend

\- Node.js

\- Express

\- SQLite mediante better-sqlite3.



\## Estructura del proyecto



```text

inventario\_flutter/

├── backend/

│   ├── data/

│   ├── src/

│   ├── package.json

│   └── sembrar.js

├── frontend/

│   ├── lib/

│   ├── test/

│   ├── pubspec.yaml

│   └── .env.example

├── .gitignore

└── README.md

```



\## Requisitos previos



\- Node.js y npm.

\- Flutter y Dart.

\- Android Studio o un emulador Android, si se ejecuta la aplicación en un emulador.



\## Instalación y ejecución del backend



Desde una terminal, entra en la carpeta del backend:



```bash

cd backend

npm install

npm start

```



La API estará disponible en:



`http://localhost:3000`



Para ejecutar el servidor en modo desarrollo:



```bash

npm run dev

```



\## Endpoints de la API



| Método | Endpoint | Función |

|---|---|---|

| GET | `/api/productos` | Consultar todos los productos |

| GET | `/api/productos/:id` | Consultar un producto por su ID |

| POST | `/api/productos` | Crear un producto |

| PUT | `/api/productos/:id` | Actualizar un producto |

| DELETE | `/api/productos/:id` | Eliminar un producto |



Las solicitudes y respuestas de la API utilizan JSON.



\## Datos de prueba



Para insertar los productos de prueba, ejecuta desde la carpeta `backend`:



```bash

node sembrar.js

```



El script utiliza `INSERT OR IGNORE` para evitar insertar nuevamente productos cuyos códigos ya existen.



\## Instalación y ejecución del frontend



Abre otra terminal y entra en la carpeta del frontend:



```bash

cd frontend

flutter pub get

```



Crea un archivo `.env` a partir de `.env.example` y configura la URL correspondiente al entorno de ejecución.



Para el emulador Android:



```env

API\_URL=http://10.0.2.2:3000/api

```



Con el backend ejecutándose, inicia la aplicación:



```bash

flutter run

```



Si se utiliza un dispositivo físico, configura `API\_URL` con la dirección IP local del computador donde se ejecuta el backend, siempre que ambos dispositivos puedan comunicarse por la red.



\## Validaciones de la API



Se verificaron respuestas HTTP para las siguientes situaciones:



\- `404`: consulta de un producto inexistente.

\- `422`: solicitud de creación con datos obligatorios ausentes.

\- `422`: intento de registrar un código de producto duplicado.



\## Persistencia de datos



La API utiliza SQLite para almacenar los productos. La base de datos se crea localmente cuando el backend la inicializa. El archivo de la base de datos local no se incluye en el repositorio; los datos de prueba pueden generarse mediante `sembrar.js`.



\## Autoría



Proyecto académico de Ingeniería de Sistemas.



