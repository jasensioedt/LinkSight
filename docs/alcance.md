# OWASP Top 10

Nuestro programa va a analizar el top 10 de OWASP (Open Web Application Security Project), que lista los diez principales riesgos de seguridad en aplicaciones web.

---

## A01. Broken Access Control

### Descripción

La autenticación comprueba *quién* eres (por ejemplo, iniciar sesión con usuario y contraseña). El control de acceso comprueba *qué* se te permite hacer una vez dentro. Cuando este sistema falla, un usuario común puede acceder a funciones de administrador o ver información privada de otras personas.

### Cómo evitarlo

El control de acceso solo es efectivo cuando se implementa en código confiable del lado del servidor o en APIs *serverless*, donde el atacante no puede modificar la comprobación del control de acceso ni los metadatos.

- A excepción de los recursos públicos, **denegar por defecto**.
- **Implementar los mecanismos de control de acceso una sola vez** y reutilizarlos en toda la aplicación, lo que incluye minimizar el uso del Intercambio de Recursos de Origen Cruzado (CORS).
- Los controles de acceso del modelo deben **garantizar la propiedad de los registros**, en lugar de permitir que los usuarios creen, lean, actualicen o eliminen cualquier registro.
- Los requisitos únicos de **límites del negocio de la aplicación** deben ser aplicados por los modelos de dominio.
- **Desactivar el listado de directorios** del servidor web y asegurarse de que los metadatos de los archivos (por ejemplo, `.git`) y los archivos de respaldo no estén presentes dentro de las raíces web.
- **Registrar (loguear) los fallos de control de acceso** y alertar a los administradores cuando sea apropiado (por ejemplo, ante fallos reiterados).
- **Implementar límites de tasa (rate limits)** en el acceso a las APIs y controladores para minimizar el daño de las herramientas de ataque automatizadas.
- Los identificadores de sesión con estado deben **invalidarse en el servidor después del cierre de sesión**. Los tokens JWT sin estado deben ser de corta duración para minimizar la ventana de oportunidad de un atacante. Para los JWT de mayor duración, considere usar tokens de actualización (*refresh tokens*) y seguir los estándares de OAuth para revocar el acceso.
- **Utilizar herramientas o patrones consolidados** que proporcionen controles de acceso sencillos y declarativos.

---

## A02. Mala configuración de seguridad

### Descripción

La mala configuración de seguridad ocurre cuando un sistema, aplicación o servicio en la nube se configura de manera incorrecta desde una perspectiva de seguridad, lo que genera vulnerabilidades.

**La aplicación podría ser vulnerable si:**

- Carece de un endurecimiento de seguridad (hardening) adecuado en cualquier parte de la pila (stack) de la aplicación, o si los permisos en los servicios en la nube están mal configurados.
- Hay funciones innecesarias habilitadas o instaladas (por ejemplo, puertos, servicios, páginas, cuentas, marcos de prueba o privilegios innecesarios).
- Las cuentas predeterminadas y sus contraseñas siguen habilitadas y no se han cambiado.
- Existe una falta de configuración centralizada para interceptar mensajes de error excesivos. El manejo de errores expone trazas de código (stack traces) u otros mensajes de error demasiado informativos a los usuarios.
- En los sistemas actualizados, las últimas características de seguridad están deshabilitadas o no están configuradas de forma segura.
- Se da una priorización excesiva a la compatibilidad con versiones anteriores, lo que deriva en una configuración insegura.
- Los ajustes de seguridad en los servidores de aplicaciones, marcos de trabajo (por ejemplo, Struts, Spring, ASP.NET), librerías, bases de datos, etc., no están establecidos en valores seguros.
- El servidor no envía cabeceras o directivas de seguridad, o estas no están configuradas con valores seguros.
- Sin un proceso concertado y repetible de endurecimiento de la configuración de seguridad de las aplicaciones, los sistemas corren un mayor riesgo.

### Cómo evitarlo

Deben implementarse procesos de instalación segura que incluyan:

- **Un proceso de endurecimiento (*hardening*) repetible** que permita el despliegue rápido y sencillo de otro entorno debidamente protegido. Los entornos de desarrollo, control de calidad (QA) y producción deben configurarse de manera idéntica, utilizando credenciales diferentes en cada uno. Este proceso debe automatizarse para minimizar el esfuerzo requerido al configurar un nuevo entorno seguro.
- **Una plataforma mínima** sin funciones, componentes, documentación ni ejemplos innecesarios. Elimine o no instale las características y marcos de trabajo (*frameworks*) que no se utilicen.
- **Una tarea para revisar y actualizar las configuraciones** conforme a todas las notas de seguridad, actualizaciones y parches como parte del proceso de gestión de parches (ver *A03 Fallos en la Cadena de Suministro de Software*). Revise los permisos de almacenamiento en la nube (por ejemplo, los permisos de los buckets de S3).
- **Una arquitectura de aplicación segmentada** que proporcione una separación efectiva y segura entre componentes o inquilinos (*tenants*), mediante segmentación, contenedorización o grupos de seguridad en la nube (ACL).
- **El envío de directivas de seguridad a los clientes**, por ejemplo, cabeceras de seguridad (*Security Headers*).
- **Un proceso automatizado para verificar la efectividad** de las configuraciones y ajustes en todos los entornos.
- Añadir de forma proactiva una **configuración centralizada para interceptar mensajes de error excesivos** como medida de respaldo.
- Si estas verificaciones no están automatizadas, deben **verificarse manualmente como mínimo una vez al año**.
- **Utilizar federación de identidades**, credenciales de corta duración o mecanismos de acceso basados en roles provistos por la plataforma subyacente, en lugar de incrustar claves estáticas o secretos en el código, archivos de configuración o canales de despliegue (*pipelines*).

---

## A03. Fallos en la cadena de suministro de software

### Descripción

Los fallos en la cadena de suministro de software son rupturas u otros tipos de compromisos en el proceso de construcción, distribución o actualización de software. A menudo son causados por vulnerabilidades o cambios maliciosos en código de terceros, herramientas u otras dependencias en las que confía el sistema.

**Es muy probable que seas vulnerable si:**

- **No realizas un seguimiento cuidadoso de las versiones** de todos los componentes que utilizas (tanto en el lado del cliente como en el del servidor). Esto incluye los componentes que usas directamente, así como las dependencias anidadas (transitivas).
- **El software es vulnerable, no tiene soporte o está desactualizado.** Esto incluye el sistema operativo, el servidor web o de aplicaciones, el sistema de gestión de bases de datos (DBMS), las aplicaciones, las APIs y todos los componentes, entornos de ejecución y librerías.
- **No realizas escaneos de vulnerabilidades con regularidad** ni estás suscrito a los boletines de seguridad relacionados con los componentes que utilizas.
- **No cuentas con un proceso de gestión de cambios** o un seguimiento de las modificaciones dentro de tu cadena de suministro. Esto abarca el control sobre los IDEs, sus extensiones y actualizaciones, los cambios en el repositorio de código de tu organización, los entornos de pruebas (*sandboxes*), los repositorios de imágenes y librerías, la forma en que se crean y almacenan los artefactos, etc. Cada parte de tu cadena de suministro debe estar documentada, especialmente los cambios.
- **No has endurecido (*hardened*) cada parte de tu cadena de suministro**, prestando especial atención al control de acceso y a la aplicación del principio de menor privilegio.
- Los sistemas de tu cadena de suministro **carecen de separación de funciones**. Ninguna persona por sí sola debería ser capaz de escribir código y promocionarlo hasta el entorno de producción sin la supervisión de otro ser humano.
- **Se utilizan componentes de fuentes no confiables** en cualquier parte de la pila tecnológica que puedan impactar en los entornos de producción.
- **No corriges ni actualizas la plataforma subyacente**, los marcos de trabajo (*frameworks*) y las dependencias de manera oportuna y basada en el riesgo. Esto ocurre frecuentemente en entornos donde la aplicación de parches es una tarea mensual o trimestral bajo control de cambios, lo que expone a las organizaciones a días o meses de exposición innecesaria antes de solucionar las vulnerabilidades.
- Los desarrolladores de software **no prueban la compatibilidad** de las librerías actualizadas o parcheadas.
- **No proteges las configuraciones** de cada parte de tu sistema.
- **Tu canal de distribución CI/CD tiene una seguridad más débil** que los sistemas que construye y despliega, especialmente si dicho canal es complejo.

### Cómo evitarlo

Debe existir un **proceso de gestión de parches** implementado para:

- **Generar y gestionar de forma centralizada la Lista de Materiales de Software (SBOM)** de todo su software.
- **Realizar un seguimiento** no solo de sus dependencias directas, sino también de sus dependencias (transitivas) anidadas, y así sucesivamente.
- **Reducir la superficie de ataque** eliminando dependencias no utilizadas, características innecesarias, componentes, archivos y documentación.
- **Inventariar continuamente las versiones** de los componentes tanto del lado del cliente como del servidor (por ejemplo, marcos de trabajo, librerías) y sus dependencias utilizando herramientas como *OWASP Dependency Track, OWASP Dependency Check, retire.js*, etc.
- **Monitorear continuamente fuentes** como *Common Vulnerability and Exposures (CVE), National Vulnerability Database (NVD)* y *Open Source Vulnerabilities (OSV)* en busca de vulnerabilidades en los componentes que utiliza. Use herramientas de análisis de composición de software (SCA), de cadena de suministro de software o herramientas SBOM enfocadas en seguridad para automatizar el proceso. Suscríbase a alertas de vulnerabilidades de seguridad relacionadas con los componentes que usa.
- **Obtener componentes únicamente de fuentes oficiales (confiables)** a través de enlaces seguros. Priorice los paquetes firmados para reducir la posibilidad de incluir un componente modificado o malicioso (ver *A08:2025 Fallos en la Integridad de Software y Datos*).
- **Elegir deliberadamente qué versión** de una dependencia utiliza y actualizarla solo cuando sea necesario.
- **Monitorear las librerías y componentes** que no reciben mantenimiento o que no crean parches de seguridad para versiones anteriores. Si no es posible aplicar un parche, considere migrar a una alternativa. Si eso tampoco es posible, considere implementar un parche virtual para monitorear, detectar o protegerse contra el problema descubierto.
- **Actualizar su CI/CD, IDE** y cualquier otra herramienta de desarrollo de forma regular.
- **Evitar el despliegue de actualizaciones** en todos los sistemas simultáneamente. Utilice despliegues escalonados (*staged rollouts*) o despliegues *canary* para limitar la exposición en caso de que un proveedor de confianza se vea comprometido.

Debe existir un **proceso de gestión de cambios** o un sistema de seguimiento implementado para registrar las modificaciones en:

- Ajustes de **CI/CD** (todas las herramientas de construcción y canales de distribución).
- **Repositorios de código**.
- Áreas de pruebas (**sandboxes**).
- **IDEs** de los desarrolladores.
- Herramientas de **SBOM** y los artefactos creados.
- **Sistemas de registro** y sus respectivos *logs*.
- **Integraciones con terceros**, tales como herramientas SaaS.
- **Repositorios de artefactos**.
- **Registros de contenedores**.

**Endurecer (*harden*) los siguientes sistemas**, lo cual incluye habilitar la autenticación de múltiples factores (**MFA**) y restringir la gestión de accesos e identidades (**IAM**):

- **Su repositorio de código:** lo que incluye no registrar secretos (*secrets*), proteger las ramas (*branches*) y realizar copias de seguridad.
- **Estaciones de trabajo de los desarrolladores:** aplicación regular de parches, MFA, monitoreo y más.
- **Su servidor de construcción y CI/CD:** separación de funciones, control de acceso, construcciones firmadas, secretos con alcance limitado al entorno (*environment-scoped secrets*), registros a prueba de manipulaciones (*tamper-evident logs*), entre otros.
- **Sus artefactos:** garantizar la integridad a través de la procedencia (*provenance*), firma digital y sellado de tiempo; promocionar los mismos artefactos en lugar de reconstruirlos para cada entorno, y asegurar que las construcciones sean inmutables.
- **Infraestructura como código (IaC):** gestionada como cualquier otro código fuente, incluyendo el uso de solicitudes de extracción (*Pull Requests*) y control de versiones.

Cada organización debe garantizar un **plan continuo para monitorear, clasificar (*triage*) y aplicar actualizaciones** o cambios de configuración durante todo el ciclo de vida de la aplicación o del catálogo de software.

---

## A04. Fallos de criptografía

### Descripción

En términos generales, todos los datos en tránsito deben estar cifrados en la capa de transporte (capa 4 del modelo OSI). Los obstáculos anteriores, como el rendimiento de la CPU y la gestión de claves privadas o certificados, ahora son gestionados por CPUs que cuentan con instrucciones diseñadas para acelerar el cifrado (por ejemplo, soporte AES), y por una gestión de claves privadas y certificados simplificada gracias a servicios como **Let's Encrypt**, junto con los principales proveedores de la nube que ofrecen servicios de gestión de certificados aún más integrados para sus plataformas específicas.

Más allá de proteger la capa de transporte, es importante determinar qué datos necesitan cifrado en reposo, así como qué datos requieren un cifrado adicional en tránsito (en la capa de aplicación, capa 7 del modelo OSI). Por ejemplo, las contraseñas, los números de tarjetas de crédito, los registros médicos, la información personal y los secretos comerciales requieren protección adicional, especialmente si esos datos entran dentro del ámbito de las leyes de privacidad, como el Reglamento General de Protección de Datos (GDPR) de la UE, o de regulaciones como el Estándar de Seguridad de Datos de la Industria de Tarjetas de Pago (PCI DSS). Para todos estos datos, cabe preguntarse:

- ¿Se utiliza algún algoritmo o protocolo criptográfico antiguo o débil, ya sea por defecto o en código heredado?
- ¿Se están usando claves criptográficas predeterminadas, se generan claves criptográficas débiles, se reutilizan las claves o falta una rotación y gestión de claves adecuada?
- ¿Se han subido o expuesto claves criptográficas en los repositorios de código fuente?
- ¿No se está obligando al uso del cifrado? Por ejemplo, ¿falta alguna directiva de seguridad o cabecera en las cabeceras HTTP (del navegador)?
- ¿Se validan correctamente el certificado de servidor recibido y su cadena de confianza?
- ¿Los vectores de inicialización se ignoran, se reutilizan o no se generan con la suficiente seguridad para el modo de operación criptográfica? ¿Se está utilizando un modo de operación inseguro como ECB? ¿Se emplea cifrado simple cuando sería más apropiado un cifrado autenticado?
- ¿Se están utilizando contraseñas como claves criptográficas ante la ausencia de una función de derivación de claves basada en contraseñas?
- ¿Se utiliza una aleatoriedad que no fue diseñada para cumplir con los requisitos criptográficos? Incluso si se elige la función correcta, ¿necesita ser inicializada (*seeded*) por el desarrollador? Y si no es así, ¿ha sobrescrito el desarrollador la sólida funcionalidad de inicialización integrada en ella con una semilla (*seed*) que carece de la suficiente entropía o impredecibilidad?
- ¿Se están utilizando funciones hash obsoletas como MD5 o SHA1, o se usan funciones hash no criptográficas cuando se necesitan funciones hash criptográficas?
- ¿Son explotables los mensajes de error criptográficos o la información de canales laterales, por ejemplo, en forma de ataques de oráculo de relleno (*padding oracle attacks*)?
- ¿Se puede degradar (*downgrade*) o eludir el algoritmo criptográfico?

### Cómo evitarlo

Realice lo siguiente, como mínimo, y consulte las referencias:

- **Clasifique y etiquete los datos** procesados, almacenados o transmitidos por una aplicación. Identifique qué datos son sensibles de acuerdo con las leyes de privacidad, los requisitos normativos o las necesidades del negocio.
- **Almacene sus claves más sensibles** en un HSM (Módulo de Seguridad de Hardware) físico o basado en la nube.
- **Utilice implementaciones consolidadas y confiables** de algoritmos criptográficos siempre que sea posible.
- **No almacene datos sensibles innecesariamente.** Descártelos lo antes posible o utilice técnicas de tokenización que cumplan con la norma PCI DSS, o incluso el truncamiento de datos. Los datos que no se conservan no pueden ser robados.
- Asegúrese de **cifrar todos los datos sensibles en reposo**.
- Garantice la implementación de **algoritmos estándar, protocolos y claves que sean fuertes y estén actualizados**; implemente una gestión de claves adecuada.
- **Cifre todos los datos en tránsito** utilizando únicamente protocolos **TLS >= 1.2**, con cifrados que ofrezcan secreto perfecto hacia adelante (*Forward Secrecy - FS*), elimine el soporte para cifrados basados en encadenamiento de bloques (*Cipher Block Chaining - CBC*) y añada soporte para algoritmos de intercambio de claves post-cuánticos. Para HTTPS, obligue al uso del cifrado mediante la cabecera **HSTS** (*HTTP Strict Transport Security*). Verifique todo el entorno con una herramienta de análisis.
- **Desactive el almacenamiento en caché** para las respuestas que contengan datos sensibles. Esto incluye la caché en su CDN, servidor web y cualquier almacenamiento en caché de la aplicación (por ejemplo, *Redis*).
- **Aplique los controles de seguridad requeridos** según la clasificación de los datos establecida.
- **No utilice protocolos no cifrados** como FTP o STARTTLS. Evite el uso de SMTP para la transmisión de datos confidenciales.
- **Almacene las contraseñas** utilizando funciones hash adaptativas y con sal (*salted*) que cuenten con un factor de trabajo o retardo (*work factor*), tales como **Argon2, yescrypt, scrypt o PBKDF2-HMAC-SHA-512**. Para sistemas heredados (*legacy*) que utilicen *bcrypt*, consulte más consejos en la guía *OWASP Cheat Sheet: Password Storage*.
- Los **vectores de inicialización (IV)** deben elegirse de forma adecuada según el modo de operación. Esto podría implicar el uso de un CSPRNG (generador de números pseudoaleatorios criptográficamente seguro). Para los modos que requieren un número de un solo uso (*nonce*), el vector de inicialización no necesita obligatoriamente un CSPRNG. En cualquier caso, **el IV nunca debe utilizarse dos veces** para una misma clave fija.
- **Utilice siempre cifrado autenticado** (como AES-GCM o ChaCha20-Poly1305) en lugar de solo cifrado simple.
- Las claves deben **generarse de forma criptográficamente aleatoria** y almacenarse en memoria como arreglos de bytes (*byte arrays*). Si se utiliza una contraseña, esta debe convertirse en una clave mediante una función de derivación de claves basada en contraseñas adecuada.
- Asegúrese de emplear **aleatoriedad criptográfica** donde sea apropiado y cerciórese de que no haya sido inicializada con una semilla (*seed*) de forma predecible o con baja entropía. La mayoría de las APIs modernas no requieren que el desarrollador inicialice el CSPRNG para ser seguras.
- **Evite funciones criptográficas obsoletas**, métodos de construcción de bloques y esquemas de relleno (*padding*) de la vieja escuela, tales como MD5, SHA1, el modo de encadenamiento de bloques de cifrado (CBC) y PKCS #1 v1.5.
- Asegúrese de que los ajustes y las configuraciones cumplan con los requisitos de seguridad mediante la **revisión por parte de especialistas en seguridad**, herramientas diseñadas para este propósito, o ambos.
- Debe **prepararse desde ahora para la criptografía post-cuántica (PQC)** (consulte la referencia de ENISA), de modo que los sistemas de alto riesgo estén completamente protegidos **a más tardar a finales de 2030**.

---

## A05. SQL Injection

### Descripción

Una vulnerabilidad de inyección es un fallo de la aplicación que permite enviar datos de usuario no confiables a un intérprete (por ejemplo, un navegador, una base de datos o la línea de comandos) y provoca que dicho intérprete ejecute partes de esa entrada como comandos.

**Una aplicación es vulnerable a ataques cuando:**

- La aplicación no valida, filtra ni higieniza los datos proporcionados por el usuario.
- Se utilizan directamente en el intérprete consultas dinámicas o llamadas no parametrizadas sin aplicar escapes adecuados al contexto.
- Se utilizan datos no higienizados en parámetros de búsqueda de mapeo objeto-relacional (ORM) para extraer registros adicionales o confidenciales.
- Se utilizan o concatenan directamente datos potencialmente hostiles; la sentencia SQL o el comando combinan la estructura y los datos maliciosos en consultas dinámicas, comandos o procedimientos almacenados.

Algunas de las inyecciones más comunes son SQL, NoSQL, comandos del sistema operativo (OS command), mapeo objeto-relacional (ORM), LDAP e inyecciones de Expression Language (EL) u Object Graph Navigation Library (OGNL). El concepto es idéntico para todos los intérpretes. La mejor forma de detectarlas es mediante una combinación de revisión del código fuente y pruebas automatizadas (incluyendo *fuzzing*) de todos los parámetros, encabezados, URL, cookies y entradas de datos en formatos JSON, SOAP y XML. La incorporación de herramientas de pruebas de seguridad de aplicaciones estáticas (SAST), dinámicas (DAST) e interactivas (IAST) en la canalización de CI/CD también puede resultar útil para identificar fallos de inyección antes del despliegue en producción.

### Cómo evitarlo

La mejor manera de prevenir la inyección consiste en mantener los datos separados de los comandos y las consultas:

- La opción preferida es utilizar una API segura, que evita por completo el uso del intérprete, proporciona una interfaz parametrizada o permite migrar a herramientas de mapeo objeto-relacional (ORM). **Nota:** Incluso cuando están parametrizados, los procedimientos almacenados pueden introducir inyección SQL si PL/SQL o T-SQL concatena consultas y datos, o ejecuta datos maliciosos con `EXECUTE IMMEDIATE` o `exec()`.

Cuando no sea posible separar los datos de los comandos, puede reducir las amenazas mediante las siguientes técnicas:

- Utilice una validación positiva de las entradas en el servidor. Esta no constituye una defensa completa, ya que muchas aplicaciones requieren caracteres especiales, como las áreas de texto o las API para aplicaciones móviles.
- En las consultas dinámicas que queden, escape los caracteres especiales utilizando la sintaxis de escape específica del intérprete. **Nota:** Las estructuras SQL, como los nombres de tablas, los nombres de columnas, etc., no se pueden escapar y, por tanto, los nombres de estructuras proporcionados por el usuario son peligrosos. Este es un problema común en el software de generación de informes.

> **Advertencia:** estas técnicas implican analizar y escapar cadenas complejas, por lo que son propensas a errores y no son robustas frente a cambios menores en el sistema subyacente.

---

## A06. Diseño inseguro

### Descripción

El **diseño inseguro** es una categoría amplia que representa diferentes debilidades, expresadas como "diseño de control ausente o ineficaz". El diseño inseguro no es el origen de todas las demás categorías de riesgo del **OWASP Top Ten**. Ten en cuenta que existe una diferencia entre un diseño inseguro y una implementación insegura. Diferenciamos entre fallos de diseño y defectos de implementación por una razón: tienen diferentes causas raíz, ocurren en momentos distintos del proceso de desarrollo y tienen diferentes formas de remediación. Un diseño seguro puede seguir teniendo defectos de implementación que den lugar a vulnerabilidades que puedan ser explotadas. Un diseño inseguro no se puede solucionar con una implementación perfecta, ya que los controles de seguridad necesarios nunca se crearon para defenderse de ataques específicos. Uno de los factores que contribuye al diseño inseguro es la falta de un perfil de riesgo empresarial intrínseco en el software o sistema que se está desarrollando y, por lo tanto, la imposibilidad de determinar qué nivel de diseño de seguridad se requiere.

Tres partes clave para contar con un diseño seguro son:

- Recopilación de requisitos y gestión de recursos
- Creación de un diseño seguro
- Contar con un ciclo de vida de desarrollo seguro

#### Requisitos y gestión de recursos

Recopila y negocia con el negocio los requisitos empresariales para una aplicación, incluidos los requisitos de protección relativos a la confidencialidad, integridad, disponibilidad y autenticidad de todos los activos de datos y la lógica empresarial esperada. Ten en cuenta qué tan expuesta estará tu aplicación y si necesitas segregación de inquilinos (más allá de los necesarios para el control de acceso). Compila los requisitos técnicos, incluidos los requisitos de seguridad funcionales y no funcionales. Planifica y negocia el presupuesto que cubra todo el diseño, construcción, pruebas y operación, incluyendo las actividades de seguridad.

#### Diseño seguro

El diseño seguro es una cultura y una metodología que evalúa constantemente las amenazas y garantiza que el código esté diseñado y probado de forma robusta para evitar métodos de ataque conocidos. El modelado de amenazas debe integrarse en las sesiones de refinamiento (*refinement sessions*) o actividades similares; busca cambios en los flujos de datos y en el control de acceso u otros controles de seguridad. En el desarrollo de las historias (*stories*), determina el flujo correcto y los estados de fallo, y asegúrate de que sean bien comprendidos y acordados por las partes responsables y afectadas. Analiza las suposiciones y condiciones para los flujos esperados y de fallo para garantizar que sigan siendo precisos y deseables. Determina cómo validar las suposiciones y hacer cumplir las condiciones necesarias para los comportamientos adecuados. Asegúrate de que los resultados queden documentados en la historia. Aprende de los errores y ofrece incentivos positivos para promover mejoras. El diseño seguro no es un complemento ni una herramienta que puedas añadir al software.

#### Ciclo de vida de desarrollo seguro (*Secure Development Lifecycle*)

El software seguro requiere un **ciclo de vida de desarrollo seguro** (*Secure Development Lifecycle - SDLC*), un patrón de diseño seguro, una metodología de camino pavimentado (*paved road methodology*), una biblioteca de componentes seguros, herramientas adecuadas, modelado de amenazas y análisis post-mortem de incidentes que se utilicen para mejorar el proceso. Ponte en contacto con tus especialistas en seguridad al principio de un proyecto de software, a lo largo de todo el proyecto y durante el mantenimiento continuo del mismo. Considera la posibilidad de aprovechar el **Modelo de Madurez de Aseguramiento de Software de OWASP (SAMM)** para ayudarte a estructurar tus esfuerzos de desarrollo de software seguro.

A menudo, no se valora lo suficiente la autorresponsabilidad de los desarrolladores. Fomenta una cultura de concienciación, responsabilidad y mitigación proactiva del riesgo. Los intercambios regulares sobre seguridad (por ejemplo, durante las sesiones de modelado de amenazas) pueden generar una mentalidad propicia para incluir la seguridad en todas las decisiones de diseño importantes.

### Cómo evitarlo

- **Establecer y utilizar un ciclo de vida de desarrollo seguro** junto con profesionales de Seguridad de Aplicaciones (*AppSec*) para ayudar a evaluar y diseñar controles relacionados con la seguridad y la privacidad.
- **Establecer y utilizar una biblioteca de patrones de diseño seguros** o componentes de "camino pavimentado" (*paved-road components*).
- **Utilizar el modelado de amenazas** en las partes críticas de la aplicación, tales como la autenticación, el control de acceso, la lógica empresarial y los flujos clave.
- **Utilizar el modelado de amenazas como una herramienta educativa** para generar una mentalidad enfocada en la seguridad.
- **Integrar lenguaje y controles de seguridad** directamente en las historias de usuario (*user stories*).
- **Integrar verificaciones de plausibilidad** en cada capa de la aplicación (desde el *frontend* hasta el *backend*).
- **Escribir pruebas unitarias y de integración** para validar que todos los flujos críticos sean resistentes al modelo de amenazas. Compilar casos de uso y casos de mal uso (*misuse-cases*) para cada capa de la aplicación.
- **Segregar las capas del sistema** a nivel de infraestructura y de red, dependiendo de su nivel de exposición y de las necesidades de protección.
- **Segregar a los inquilinos** (*tenants*) de forma robusta por diseño en todas las capas de la aplicación.

---

## A07. Fallos de autenticación

### Descripción

Esta vulnerabilidad está presente cuando un atacante es capaz de engañar a un sistema para que reconozca como legítimo a un usuario inválido o incorrecto. Pueden existir debilidades de autenticación si la aplicación:

- **Permite ataques automatizados** como el relleno de credenciales (*credential stuffing*), donde el atacante dispone de una lista filtrada de nombres de usuario y contraseñas válidas. Recientemente, este tipo de ataque se ha expandido para incluir ataques híbridos de contraseñas mediante relleno de credenciales (también conocidos como ataques de pulverización de contraseñas o *password spray*), donde el atacante utiliza variaciones o incrementos de credenciales filtradas para ganar acceso; por ejemplo, probando *Password1!*, *Password2!*, *Password3!*, y así sucesivamente.
- **Permite ataques de fuerza bruta** u otros ataques automatizados basados en scripts que no se bloquean con rapidez.
- **Permite contraseñas predeterminadas (por defecto), débiles o muy conocidas**, como "Password1" o el nombre de usuario "admin" con la contraseña "admin".
- **Permite a los usuarios crear cuentas nuevas** utilizando credenciales que ya se sabe que han sido vulneradas o filtradas.
- **Permite el uso de procesos débiles o ineficaces** para la recuperación de credenciales y el olvido de contraseñas, tales como las "respuestas basadas en el conocimiento", las cuales no se pueden hacer seguras.
- **Utiliza almacenes de datos de contraseñas en texto plano**, cifrados o con funciones hash débiles (consulte A04:2025 Cryptographic Failures).
- **Carece de autenticación multifactor** (MFA) o esta es ineficaz.
- **Permite el uso de mecanismos de contingencia** (*fallbacks*) débiles o ineficaces si la autenticación multifactor no está disponible.
- **Expone el identificador de sesión en la URL**, en un campo oculto o en otra ubicación insegura que sea accesible para el cliente.
- **Reutiliza el mismo identificador de sesión** después de un inicio de sesión exitoso.
- **No invalida correctamente las sesiones de usuario** o los tokens de autenticación (principalmente tokens de inicio de sesión único o *SSO*) durante el cierre de sesión o tras un periodo de inactividad.
- **No valida correctamente el alcance** (*scope*) y la audiencia prevista de las credenciales proporcionadas.

### Cómo evitarlo

- **Implementar y hacer obligatorio el uso de la autenticación multifactor** siempre que sea posible para evitar ataques automatizados de relleno de credenciales (*credential stuffing*), fuerza bruta y la reutilización de credenciales robadas.
- **Fomentar y habilitar el uso de gestores de contraseñas** siempre que sea posible para ayudar a los usuarios a tomar mejores decisiones.
- **No enviar ni desplegar el software con ninguna credencial predeterminada (por defecto)**, especialmente para los usuarios administradores.
- **Implementar verificaciones de contraseñas débiles**, tales como contrastar las contraseñas nuevas o modificadas con la lista de las 10,000 peores contraseñas.
- **Validar los datos contra listas de credenciales que ya se sabe que han sido vulneradas** durante la creación de cuentas nuevas y los cambios de contraseña; por ejemplo, utilizando herramientas como el validador de **Have I Been Pwned**.
- **Alinear las políticas de longitud, complejidad y rotación de contraseñas** con las directrices de la sección 5.1.1 para "Secretos Memorizados" del Instituto Nacional de Estándares y Tecnología (*NIST*) 800-63b, o con otras políticas de contraseñas modernas basadas en la evidencia.
- **No obligar a los seres humanos a rotar sus contraseñas** a menos que se sospeche de una brecha de seguridad. Si se sospecha de una brecha, fuerce el restablecimiento inmediato de las contraseñas.
- **Garantizar que los flujos de registro, recuperación de credenciales y rutas de API estén protegidos** contra ataques de enumeración de cuentas utilizando los mismos mensajes para todos los resultados posibles ("Nombre de usuario o contraseña inválidos.").
- **Limitar o retrasar progresivamente los intentos fallidos de inicio de sesión**, teniendo cuidado de no crear un escenario de denegación de servicio (*DoS*). Registrar todos los fallos y alertar a los administradores cuando se detecten o sospechen ataques de fuerza bruta, relleno de credenciales u otros vectores.
- **Utilizar un gestor de sesiones integrado, seguro y del lado del servidor** que genere un nuevo ID de sesión aleatorio con alta entropía después del inicio de sesión. Los identificadores de sesión no deben estar en la URL, deben almacenarse de forma segura en una cookie segura y deben invalidarse tras el cierre de sesión, por inactividad y al cumplir tiempos de expiración absolutos.
- **Utilizar de forma ideal un sistema prefabricado y de alta confianza** para manejar la autenticación, la identidad y la gestión de sesiones. Transfiera este riesgo siempre que sea posible mediante la compra y utilización de un sistema endurecido (*hardened*) y bien probado.
- **Verificar el uso previsto de las credenciales proporcionadas**, por ejemplo, para los tokens *JWT*, validar los *scopes* y las propiedades de control de origen y destinatario como los *claims* `aud` (*audience*) e `iss` (*issuer*).

---

## A08. Fallos de integridad en el software y los datos

### Descripción

Los fallos de integridad en el software y los datos se relacionan con el código y la infraestructura que no protegen contra la posibilidad de que código o datos inválidos o no confiables sean tratados como confiables y válidos. Un ejemplo de esto ocurre cuando una aplicación depende de complementos (*plugins*), bibliotecas o módulos provenientes de fuentes, repositorios y redes de entrega de contenido (*CDNs*) que no son de confianza.

Una canalización (*pipeline*) de CI/CD insegura que no consuma ni proporcione verificaciones de integridad del software puede introducir el riesgo de accesos no autorizados, código inseguro o malicioso, o el compromiso total del sistema. Otro ejemplo de esto es un flujo de CI/CD que extrae código o artefactos de lugares no confiables y/o no los verifica antes de su uso (mediante la comprobación de firmas o mecanismos similares).

Por último, muchas aplicaciones incluyen hoy en día funciones de actualización automática, donde las actualizaciones se descargan sin una verificación de integridad suficiente y se aplican sobre la aplicación que previamente era confiable. Los atacantes podrían potencialmente cargar sus propias actualizaciones para que se distribuyan y ejecuten en todas las instalaciones. Otro ejemplo ocurre cuando los objetos o datos se codifican o serializan en una estructura que un atacante puede ver y modificar, lo cual vuelve al sistema vulnerable a la deserialización insegura.

### Cómo evitarlo

- **Utilizar firmas digitales** o mecanismos similares para verificar que el software o los datos provienen de la fuente esperada y no han sido alterados.
- **Garantizar que las bibliotecas y dependencias**, tales como las de *npm* o *Maven*, solo se consuman desde repositorios de confianza. Si tu perfil de riesgo es más alto, considera alojar un repositorio interno aprobado y previamente auditado.
- **Asegurar que exista un proceso de revisión** para los cambios de código y de configuración, con el fin de minimizar la probabilidad de que se introduzca código o configuraciones maliciosas en tu flujo (*pipeline*) de software.
- **Garantizar que tu canalización de CI/CD** cuente con una segregación, configuración y control de acceso adecuados para asegurar la integridad del código que fluye a través de los procesos de compilación (*build*) y despliegue (*deploy*).
- **Asegurar que no se reciban datos serializados** sin firmar o sin cifrar desde clientes no confiables, y que no se utilicen posteriormente sin algún tipo de verificación de integridad o firma digital que detecte la manipulación o la repetición de dichos datos serializados.

---

## A09. Fallos en el registro y alerta de seguridad

### Descripción

Sin el registro y el monitoreo, los ataques y las brechas de seguridad no se pueden detectar; y sin un sistema de alertas, es muy difícil responder de manera rápida y eficaz durante un incidente de seguridad. El registro, el monitoreo continuo, la detección y el envío de alertas insuficientes para iniciar respuestas activas ocurren siempre que:

- **Los eventos auditables**, tales como inicios de sesión, intentos fallidos de inicio de sesión y transacciones de alto valor, no se registran o se registran de forma inconsistente (por ejemplo, registrar solo los inicios de sesión exitosos, pero no los intentos fallidos).
- **Las advertencias y los errores** no generan mensajes de registro (*logs*), o bien estos son inadecuados o poco claros.
- **La integridad de los registros** no está protegida adecuadamente contra manipulaciones o alteraciones.
- **Los registros de las aplicaciones y las APIs** no se monitorean en busca de actividades sospechosas.
- **Los registros se almacenan únicamente de forma local** y no se respaldan de manera adecuada.
- **Los umbrales de alerta** y los procesos de escalada de respuesta adecuados no están implementados o no son efectivos. Las alertas no se reciben ni se revisan dentro de un periodo de tiempo razonable.
- **Las pruebas de penetración (*pentesting*)** y los escaneos realizados por herramientas de pruebas dinámicas de seguridad de aplicaciones (*DAST*, como Burp o ZAP) no activan alertas.
- **La aplicación no puede detectar**, escalar o alertar sobre ataques activos en tiempo real o casi en tiempo real.
- **Existe vulnerabilidad a la filtración de información sensible** al hacer que los eventos de registro y alerta sean visibles para un usuario o un atacante (consulte A01:2025 Broken Access Control), o al registrar información confidencial que no debería registrarse (como información de identificación personal [PII] o información de salud protegida [PHI]).
- **Existe vulnerabilidad a inyecciones** o ataques en los propios sistemas de registro o monitoreo si los datos de los *logs* no se codifican correctamente.
- **La aplicación carece de control de errores** o los maneja de forma incorrecta ante condiciones excepcionales, de modo que el sistema no se percata de que hubo un error y, por lo tanto, es incapaz de registrar que existió un problema.
- **Los "casos de uso" adecuados** para emitir alertas no existen o están desactualizados para reconocer una situación especial.
- **El exceso de alertas por falsos positivos** hace imposible distinguir las alertas importantes de las que no lo son, lo que provoca que se reconozcan demasiado tarde o que no se reconozcan en absoluto (sobrecarga física del equipo del SOC).
- **Las alertas detectadas no se pueden procesar** correctamente porque el libro de jugadas (*playbook*) para ese caso de uso está incompleto, desactualizado o no existe.

### Cómo evitarlo

Los desarrolladores deben implementar algunos o todos los siguientes controles, dependiendo del nivel de riesgo de la aplicación:

- **Garantizar que todos los fallos** de inicio de sesión, de control de acceso y de validación de entradas del lado del servidor se puedan registrar con el contexto de usuario suficiente para identificar cuentas sospechosas o maliciosas, y que se conserven durante el tiempo necesario para permitir un análisis forense posterior.
- **Asegurar que se registre cada parte de la aplicación** que contenga un control de seguridad, tanto si la operación tiene éxito como si falla.
- **Garantizar que los registros se generen en un formato** que las soluciones de gestión de *logs* puedan consumir fácilmente.
- **Asegurar que los datos de los registros se codifiquen correctamente** para prevenir inyecciones o ataques contra los propios sistemas de registro o monitoreo.
- **Garantizar que todas las transacciones tengan una pista de auditoría** con controles de integridad para evitar la manipulación o eliminación, utilizando por ejemplo tablas de bases de datos de tipo solo-adición (*append-only*) o mecanismos similares.
- **Asegurar que todas las transacciones que lancen un error** se reviertan (*rollback*) y comiencen de nuevo. Diseñar siempre para fallar de forma segura (*fail closed*).
- **Emitir una alerta** si la aplicación o sus usuarios se comportan de manera sospechosa. Crear guías para los desarrolladores sobre este tema para que puedan programar en consecuencia, o bien adquirir un sistema diseñado para este fin.
- **Establecer casos de uso eficaces de monitoreo y alerta** por parte de los equipos de DevSecOps y seguridad, incluyendo libros de jugadas (*playbooks*), de modo que el equipo del Centro de Operaciones de Seguridad (SOC) pueda detectar y responder rápidamente a las actividades sospechosas.
- **Añadir *honeytokens*** como trampas para atacantes dentro de la aplicación (por ejemplo, en la base de datos, en los datos o como identidades de usuario reales y/o técnicas). Dado que no se utilizan en la operación normal del negocio, cualquier acceso a ellos genera datos de registro que pueden activar alertas prácticamente sin falsos positivos.
- **Utilizar el análisis de comportamiento** y el soporte de Inteligencia Artificial de forma opcional como una técnica adicional para mantener bajas las tasas de falsos positivos en las alertas.
- **Establecer o adoptar un plan de respuesta y recuperación ante incidentes**, como el del Instituto Nacional de Estándares y Tecnología (*NIST*) 800-61r2 o posterior. Capacitar a los desarrolladores de software sobre cómo lucen los ataques e incidentes en las aplicaciones para que puedan reportarlos.
- **Utilizar productos comerciales y de código abierto** para la protección de aplicaciones, como el conjunto de reglas básicas *OWASP ModSecurity Core Rule Set*, o software de correlación de registros de código abierto, como la suite *ELK* (Elasticsearch, Logstash, Kibana), que cuentan con tableros personalizados y alertas que pueden ayudarte a combatir estos problemas. También existen herramientas comerciales de observabilidad que pueden ayudarte a responder o bloquear ataques casi en tiempo real.

---

## A10. Manejo inadecuado de condiciones excepcionales

### Descripción

El manejo inadecuado de condiciones excepcionales en el software ocurre cuando los programas no logran prevenir, detectar y responder a situaciones inusuales e impredecibles, lo que provoca caídas del sistema (*crashes*), comportamientos inesperados y, en ocasiones, vulnerabilidades. Esto puede involucrar uno o más de los siguientes tres fallos: la aplicación no evita que ocurra una situación inusual, no identifica la situación mientras está ocurriendo y/o responde de forma deficiente o no responde en absoluto ante la situación posteriormente.

Las condiciones excepcionales pueden ser causadas por una validación de entradas ausente, deficiente o incompleta; por un manejo de errores tardío y de alto nivel en lugar de realizarse en las funciones donde ocurren; por estados del entorno inesperados (como problemas de memoria, privilegios o de red); por un manejo de excepciones inconsistente; o por excepciones que no se gestionan en absoluto, lo que permite que el sistema caiga en un estado desconocido e impredecible. Cada vez que una aplicación no está segura de cuál es su siguiente instrucción, se ha manejado de forma inadecuada una condición excepcional. Los errores y excepciones difíciles de encontrar pueden amenazar la seguridad de toda la aplicación durante mucho tiempo.

Pueden ocurrir muchas vulnerabilidades de seguridad diferentes cuando manejamos de forma inadecuada las condiciones excepcionales, tales como errores de lógica (*logic bugs*), desbordamientos (*overflows*), condiciones de carrera (*race conditions*), transacciones fraudulentas o problemas relacionados con la memoria, el estado, los recursos, los tiempos (*timing*), la autenticación y la autorización. Estos tipos de vulnerabilidades pueden afectar negativamente la confidencialidad, disponibilidad y/o integridad de un sistema o de sus datos. Los atacantes manipulan el manejo de errores defectuoso de una aplicación para explotar esta vulnerabilidad.

### Cómo evitarlo

Para poder manejar una condición excepcional de forma adecuada, debemos planificar para tales situaciones (esperar lo peor). Debemos "capturar" (*catch*) cada posible error del sistema directamente en el lugar donde ocurra y luego gestionarlo (lo que significa hacer algo significativo para resolver el problema y asegurar que nos recuperamos de la incidencia). Como parte de esta gestión, deberíamos incluir el lanzamiento de un error (para informar al usuario de una manera comprensible), el registro del evento (*logging*), así como la emisión de una alerta si consideramos que está justificado. También deberíamos contar con un manejador global de excepciones (*global exception handler*) en caso de que alguna vez se nos escape algo. Idealmente, también tendríamos herramientas o funcionalidades de monitoreo y/u observabilidad que vigilen errores repetidos o patrones que indiquen un ataque en curso, las cuales podrían emitir una respuesta, defensa o algún tipo de bloqueo. Esto nos puede ayudar a bloquear y responder a scripts y bots que se enfocan en nuestras debilidades en el manejo de errores.

Capturar y manejar las condiciones excepcionales garantiza que la infraestructura subyacente de nuestros programas no se quede lidiando con situaciones impredecibles. Si te encuentras a mitad de camino en cualquier tipo de transacción, es sumamente importante que reviertas (*roll back*) cada parte de la transacción y comiences de nuevo (lo que también se conoce como fallar de forma segura o *failing closed*). Intentar recuperar una transacción a mitad de su proceso es a menudo donde generamos errores irrecuperables.

Siempre que sea posible, añade limitación de tasa (*rate limiting*), cuotas de recursos, regulación de tráfico (*throttling*) y otros límites para prevenir las condiciones excepcionales en primer lugar. Nada en la tecnología de la información debería ser ilimitado, ya que esto conduce a una falta de resiliencia en la aplicación, denegación de servicio, ataques de fuerza bruta exitosos y facturas extraordinarias en la nube.

Considera si los errores idénticos y repetidos, por encima de una tasa determinada, deberían mostrarse únicamente como estadísticas que indiquen la frecuencia con la que han ocurrido y en qué periodo de tiempo. Esta información debería adjuntarse al mensaje original para no interferir con el registro y monitoreo automatizados (consulte **A09:2025 Security Logging & Alerting Failures**).

Además de esto, querremos incluir una validación estricta de entradas (con sanitización o escape para caracteres potencialmente peligrosos que obligatoriamente debamos aceptar), así como un manejo de errores, registro, monitoreo y alertas centralizados, junto con un manejador global de excepciones. Una aplicación no debería tener múltiples funciones para manejar condiciones excepcionales; esto debe realizarse en un solo lugar y de la misma manera cada vez. También deberíamos crear requisitos de seguridad del proyecto para todos los consejos de esta sección, realizar modelado de amenazas y/o actividades de revisión de diseño seguro en la fase de diseño de nuestros proyectos, llevar a cabo revisiones de código o análisis estáticos, así como ejecutar pruebas de estrés, rendimiento y de penetración (*pentesting*) en el sistema final.

Si es posible, toda tu organización debería manejar las condiciones excepcionales de la misma manera, ya que esto facilita la revisión y auditoría del código en busca de errores en este control de seguridad tan importante.
