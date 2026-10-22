# Arquitectura de Software de LinkSight

## Funcionalidades de la aplicación


| ID | Prioridad | Objetivo | Funcionalidad | Disparador | Fecha Entrega | Estado |
| :--- | :---: | :--- | :--- | :--- | :---: | :---: |
| ID0 | Alta | Registrar usuarios en la plataforma | Sistema de registro con nombre, apellidos, correo electrónico y contraseña almacenada de forma segura mediante hash. | Botón de registro en la esquina superior derecha. | ... | Pendiente |
| ID1 | Alta | Iniciar sesión de forma segura | Inicio de sesión mediante correo y contraseña | Botón de inicio de sesión. | ...| Pendiente |
| ID2 | Media | Gestionar el perfil de usuario | Modificación de datos personales, cambio de contraseña y gestión de la cuenta. | Menú de perfil del usuario. | ... | Pendiente |
| ID3 | Baja | Seleccionar idioma de la interfaz | Permitir cambiar el idioma de la aplicación y guardar la preferencia del usuario. | Selector de idioma de la interfaz. | ... | Pendiente |
| ID4 | Alta | Crear un nuevo análisis | Permitir al usuario introducir una URL para iniciar un análisis de seguridad. | Botón «Nuevo análisis». | ... | Pendiente |
| ID5 | Alta | Verificar el uso autorizado de la herramienta | Confirmar que el usuario dispone de autorización para analizar el objetivo indicado. | Envío del formulario de nuevo análisis. | ... | Pendiente |
| ID6 | Alta | Ejecutar análisis mediante Nuclei | Integración con Nuclei para detectar vulnerabilidades, exposiciones de información y errores de configuración. | Inicio de un nuevo análisis. | ... | Pendiente |
| ID7 | Alta | Analizar hallazgos mediante IA | Procesar los resultados obtenidos por Nuclei utilizando Ollama para generar explicaciones y recomendaciones. | Finalización del análisis. | ... | Pendiente |
| ID8 | Alta | Consultar resultados de análisis | Mostrar vulnerabilidades detectadas ordenadas por severidad con filtros y búsqueda. | Acceso a un informe finalizado. | ... | Pendiente |
| ID9 | Media | Revisar el historial de análisis | Almacenar y consultar análisis anteriores realizados por cada usuario. | Menú «Historial». | ... | Pendiente |
| ID10 | Media | Descargar informes | Exportación de informes en formato PDF y Markdown. | Botón «Descargar informe». | ... | Pendiente |
| ID11 | Baja | Panel resumen | Dashboard con estadísticas de análisis realizados y distribución de vulnerabilidades por severidad. | Pantalla principal tras iniciar sesión. | ... | Pendiente |
| ID12 | Alta | Gestión de copias de seguridad | Copias de seguridad automáticas de la base de datos, informes y configuración. | Tarea programada diaria. | ... | Pendiente |
| ID13 | Media | Administración de usuarios | Gestión de cuentas y roles mediante un panel de administración. | Menú de administración. | ... | Pendiente |
| ID14 | Media | Gestión de vulnerabilidades detectadas | Mostrar información detallada del hallazgo, impacto, severidad y recomendación generada por IA. | Selección de una vulnerabilidad dentro de un informe. | ... | Pendiente |
| ID15 | Media | Monitorización de análisis | Mostrar el estado de ejecución de los análisis (Pendiente, En ejecución, Completado o Error). | Página de historial o detalle del análisis. | ... | Pendiente |
| ID16 | Baja | Auditoría de acciones | Registrar accesos, creación de análisis, descargas de informes y acciones administrativas. | Acciones realizadas por los usuarios. | ... | Pendiente |
