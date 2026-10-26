\# Frontend - Sistema de Gestión de Inventario



Aplicación móvil desarrollada con Flutter para administrar los productos del inventario mediante una API REST.



\## Funcionalidades



\- Visualización del dashboard con estadísticas del inventario.

\- Consulta del listado de productos.

\- Visualización del detalle de cada producto.

\- Registro de productos.

\- Edición de productos existentes.

\- Eliminación de productos.

\- Navegación entre pantallas mediante `go\_router`.

\- Comunicación con el backend mediante `Dio`.

\- Configuración de la URL de la API mediante `flutter\_dotenv`.



\## Requisitos



\- Flutter y Dart instalados.

\- Un emulador Android o dispositivo compatible.

\- El backend ejecutándose y accesible desde el dispositivo.



\## Instalación



Desde la carpeta `frontend`, ejecuta:



```bash

flutter pub get

```



Crea un archivo `.env` a partir de `.env.example` y configura la URL de la API.



Para el emulador Android:



```env

API\_URL=http://10.0.2.2:3000/api

```



Para un dispositivo físico, utiliza la dirección IP local del computador donde se ejecuta el backend.



\## Ejecutar la aplicación



Con el backend iniciado, ejecuta:



```bash

flutter run

```



\## Verificar el código



Para analizar el proyecto:



```bash

flutter analyze

```



Para ejecutar las pruebas automatizadas:



```bash

flutter test

```



\## Estructura



El código fuente se encuentra en `lib/`, organizado en modelos, servicios, vistas y configuración de navegación.



\## Backend



La aplicación consume la API REST del proyecto, ubicada en la carpeta `../backend`.



