-- Datos de demostración para las pantallas del Figma. SOLO entorno de pruebas.
-- El hash es un marcador que no permite iniciar sesión: pon una contraseña real desde la app.
INSERT INTO usuarios (id_rol, nombre, apellidos, email, organizacion, password_hash)
  SELECT id_rol, 'Aleix', 'García', 'aleix@ejemplo.com', 'Proyecto de aula · Planeta FP', 'HASH_DE_PRUEBA'
  FROM roles WHERE nombre = 'administrador';
SET @u := (SELECT id_usuario FROM usuarios WHERE email = 'aleix@ejemplo.com');

INSERT INTO preferencias (id_usuario) VALUES (@u);
INSERT INTO objetivos (id_usuario, url) VALUES (@u, 'https://tienda-demo.local');
SET @o := LAST_INSERT_ID();
INSERT INTO autorizaciones (id_objetivo, id_usuario) VALUES (@o, @u);
SET @au := LAST_INSERT_ID();

INSERT INTO analisis (codigo, id_usuario, id_autorizacion, tipo, estado, finalizado_en)
  VALUES ('A-024', @u, @au, 'completo', 'completado', NOW());
SET @a := LAST_INSERT_ID();

INSERT INTO analisis_modulos (id_analisis, id_modulo) SELECT @a, id_modulo FROM modulos;
INSERT INTO hallazgos (id_analisis, id_tipo, severidad, archivo, linea, evidencia, validado_ia)
  SELECT @a, id_tipo, 'critica', 'app/db.py', 42,
         'cursor.execute("SELECT * FROM users WHERE id=" + uid)', 1
  FROM tipos_vulnerabilidad WHERE nombre = 'Inyección SQL';
INSERT INTO dependencias (id_analisis, paquete, version, cve_id, cvss, fuente)
  VALUES (@a, 'flask', '1.0.2', 'CVE-2023-30861', 7.5, 'osv');
