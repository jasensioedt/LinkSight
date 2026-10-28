-- =====================================================================
--  LinkSight · Base de datos de la aplicación web
--  Motor: MySQL 5.7+ / 8.x o MariaDB 10.4+ (InnoDB, utf8mb4)
--  Ejecutar en VM-BD (192.168.50.20) como administrador de MySQL:
--      mysql -u root -p < linksight.sql
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Base de datos
-- ---------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS linksight
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE linksight;

-- ---------------------------------------------------------------------
-- El usuario de aplicacion se crea con MYSQL_USER y MYSQL_PASSWORD en el despliegue.

-- 3. Personas y acceso
-- ---------------------------------------------------------------------
CREATE TABLE roles (
  id_rol   TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre   VARCHAR(30)      NOT NULL,
  PRIMARY KEY (id_rol),
  UNIQUE KEY uq_roles_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE usuarios (
  id_usuario            INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  id_rol                TINYINT UNSIGNED NOT NULL,
  nombre                VARCHAR(60)      NOT NULL,
  apellidos             VARCHAR(100)     NOT NULL,
  email                 VARCHAR(255)     NOT NULL,
  organizacion          VARCHAR(120)     NULL,
  idioma                CHAR(2)          NOT NULL DEFAULT 'es',
  zona_horaria          VARCHAR(40)      NOT NULL DEFAULT 'Europe/Madrid',
  avatar_ruta           VARCHAR(255)     NULL,
  password_hash         VARCHAR(255)     NOT NULL,   -- Argon2 / bcrypt, nunca la contraseña
  password_cambiada_en  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  totp_activo           TINYINT(1)       NOT NULL DEFAULT 0,
  totp_secreto          VARCHAR(64)      NULL,
  activo                TINYINT(1)       NOT NULL DEFAULT 1,
  creado_en             DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ultimo_acceso         DATETIME         NULL,
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_usuarios_email (email),
  KEY ix_usuarios_rol (id_rol),
  CONSTRAINT fk_usuarios_rol FOREIGN KEY (id_rol) REFERENCES roles (id_rol),
  CONSTRAINT ck_usuarios_idioma CHECK (idioma IN ('es','ca','en')),
  CONSTRAINT ck_usuarios_totp CHECK (totp_activo = 0 OR totp_secreto IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE preferencias (
  id_usuario               INT UNSIGNED NOT NULL,
  formato_informe          ENUM('md_pdf','md','pdf') NOT NULL DEFAULT 'md_pdf',
  incluir_correcciones_ia  TINYINT(1) NOT NULL DEFAULT 1,
  incluir_resumen          TINYINT(1) NOT NULL DEFAULT 1,
  avisar_fin_analisis      TINYINT(1) NOT NULL DEFAULT 1,
  avisar_criticas          TINYINT(1) NOT NULL DEFAULT 1,
  resumen_semanal          TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_usuario),
  CONSTRAINT fk_preferencias_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE sesiones (
  id_sesion    CHAR(64)     NOT NULL,                -- token aleatorio (se guarda su hash)
  id_usuario   INT UNSIGNED NOT NULL,
  navegador    VARCHAR(60)  NOT NULL,
  sistema      VARCHAR(60)  NOT NULL,
  ciudad       VARCHAR(60)  NULL,
  ip           VARCHAR(45)  NOT NULL,
  creada_en    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ultimo_uso   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expira_en    DATETIME     NOT NULL,
  PRIMARY KEY (id_sesion),
  KEY ix_sesiones_usuario (id_usuario),
  KEY ix_sesiones_expira (expira_en),
  CONSTRAINT fk_sesiones_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 4. Qué se audita y cómo
-- ---------------------------------------------------------------------
CREATE TABLE objetivos (
  id_objetivo  INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_usuario   INT UNSIGNED  NOT NULL,
  url          VARCHAR(2048) NOT NULL,
  creado_en    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_objetivo),
  KEY ix_objetivos_usuario (id_usuario),
  KEY ix_objetivos_url (url(191)),
  CONSTRAINT fk_objetivos_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE autorizaciones (
  id_autorizacion  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_objetivo      INT UNSIGNED NOT NULL,
  id_usuario       INT UNSIGNED NOT NULL,             -- quien declara tener permiso
  confirmada_en    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fichero_auth     VARCHAR(255) NULL,                 -- auth.json firmado (opcional)
  hash_sha256      CHAR(64)     NULL,
  valido_hasta     DATE         NULL,
  PRIMARY KEY (id_autorizacion),
  KEY ix_autorizaciones_objetivo (id_objetivo),
  KEY ix_autorizaciones_usuario (id_usuario),
  CONSTRAINT fk_autorizaciones_objetivo FOREIGN KEY (id_objetivo)
    REFERENCES objetivos (id_objetivo),
  CONSTRAINT fk_autorizaciones_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE analisis (
  id_analisis      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo           VARCHAR(10)  NOT NULL,             -- el que se ve en pantalla: A-024
  id_usuario       INT UNSIGNED NOT NULL,
  id_autorizacion  INT UNSIGNED NOT NULL,             -- sin permiso no hay análisis
  tipo             ENUM('estatico','dinamico','completo') NOT NULL,
  estado           ENUM('pendiente','en_curso','completado','fallido') NOT NULL DEFAULT 'pendiente',
  validar_con_ia   TINYINT(1)   NOT NULL DEFAULT 1,
  formato_informe  ENUM('md_pdf','md','pdf') NOT NULL DEFAULT 'md_pdf',
  origen_codigo    ENUM('ninguno','zip','git') NOT NULL DEFAULT 'ninguno',
  ruta_codigo      VARCHAR(255) NULL,
  creado_en        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  finalizado_en    DATETIME     NULL,
  PRIMARY KEY (id_analisis),
  UNIQUE KEY uq_analisis_codigo (codigo),
  KEY ix_analisis_usuario_fecha (id_usuario, creado_en),
  KEY ix_analisis_autorizacion (id_autorizacion),
  KEY ix_analisis_estado (estado),
  CONSTRAINT fk_analisis_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario),
  CONSTRAINT fk_analisis_autorizacion FOREIGN KEY (id_autorizacion)
    REFERENCES autorizaciones (id_autorizacion),
  CONSTRAINT ck_analisis_codigo_fuente CHECK (origen_codigo = 'ninguno' OR ruta_codigo IS NOT NULL),
  CONSTRAINT ck_analisis_fechas CHECK (finalizado_en IS NULL OR finalizado_en >= creado_en)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE modulos (
  id_modulo  TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre     VARCHAR(50)      NOT NULL,
  PRIMARY KEY (id_modulo),
  UNIQUE KEY uq_modulos_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE analisis_modulos (
  id_analisis  INT UNSIGNED     NOT NULL,
  id_modulo    TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_analisis, id_modulo),
  KEY ix_analisis_modulos_modulo (id_modulo),
  CONSTRAINT fk_am_analisis FOREIGN KEY (id_analisis)
    REFERENCES analisis (id_analisis) ON DELETE CASCADE,
  CONSTRAINT fk_am_modulo FOREIGN KEY (id_modulo)
    REFERENCES modulos (id_modulo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 5. Resultados
-- ---------------------------------------------------------------------
CREATE TABLE tipos_vulnerabilidad (
  id_tipo    SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre     VARCHAR(60)       NOT NULL,
  categoria  VARCHAR(40)       NOT NULL,
  PRIMARY KEY (id_tipo),
  UNIQUE KEY uq_tipos_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE hallazgos (
  id_hallazgo    INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  id_analisis    INT UNSIGNED      NOT NULL,
  id_tipo        SMALLINT UNSIGNED NOT NULL,
  severidad      ENUM('critica','alta','media','baja') NOT NULL,
  archivo        VARCHAR(255)      NULL,
  linea          INT UNSIGNED      NULL,
  evidencia      TEXT              NOT NULL,
  estado         ENUM('abierto','corregido','falso_positivo') NOT NULL DEFAULT 'abierto',
  validado_ia    TINYINT(1)        NOT NULL DEFAULT 0,
  explicacion_ia TEXT              NULL,
  correccion_ia  TEXT              NULL,
  PRIMARY KEY (id_hallazgo),
  KEY ix_hallazgos_analisis (id_analisis),
  KEY ix_hallazgos_tipo (id_tipo),
  KEY ix_hallazgos_sev_estado (severidad, estado),
  CONSTRAINT fk_hallazgos_analisis FOREIGN KEY (id_analisis)
    REFERENCES analisis (id_analisis) ON DELETE CASCADE,
  CONSTRAINT fk_hallazgos_tipo FOREIGN KEY (id_tipo)
    REFERENCES tipos_vulnerabilidad (id_tipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dependencias (
  id_dependencia  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_analisis     INT UNSIGNED NOT NULL,
  paquete         VARCHAR(100) NOT NULL,
  version         VARCHAR(30)  NOT NULL,
  cve_id          VARCHAR(20)  NOT NULL,
  cvss            DECIMAL(3,1) NOT NULL,
  fuente          ENUM('osv','nvd') NOT NULL,
  PRIMARY KEY (id_dependencia),
  UNIQUE KEY uq_dependencias (id_analisis, paquete, version, cve_id),
  KEY ix_dependencias_cve (cve_id),
  CONSTRAINT fk_dependencias_analisis FOREIGN KEY (id_analisis)
    REFERENCES analisis (id_analisis) ON DELETE CASCADE,
  CONSTRAINT ck_dependencias_cvss CHECK (cvss BETWEEN 0.0 AND 10.0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE informes (
  id_informe         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_analisis        INT UNSIGNED NOT NULL,
  formato            ENUM('pdf','md') NOT NULL,
  resumen_ejecutivo  TEXT         NOT NULL,
  ruta               VARCHAR(255) NOT NULL,
  generado_en        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_informe),
  UNIQUE KEY uq_informes_formato (id_analisis, formato),
  CONSTRAINT fk_informes_analisis FOREIGN KEY (id_analisis)
    REFERENCES analisis (id_analisis) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 6. Trazabilidad
-- ---------------------------------------------------------------------
CREATE TABLE auditoria (
  id_evento    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_usuario   INT UNSIGNED    NOT NULL,
  id_analisis  INT UNSIGNED    NULL,
  accion       VARCHAR(60)     NOT NULL,   -- login, logout, lanzar_analisis, descargar_informe...
  ip           VARCHAR(45)     NOT NULL,
  fecha        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_evento),
  KEY ix_auditoria_usuario_fecha (id_usuario, fecha),
  KEY ix_auditoria_analisis (id_analisis),
  CONSTRAINT fk_auditoria_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario),
  CONSTRAINT fk_auditoria_analisis FOREIGN KEY (id_analisis)
    REFERENCES analisis (id_analisis) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- La auditoría es un diario: solo se pueden añadir eventos, nunca modificarlos ni borrarlos.
DELIMITER //
CREATE TRIGGER tr_auditoria_no_update BEFORE UPDATE ON auditoria
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La tabla auditoria es de solo lectura/inserción';
END//
CREATE TRIGGER tr_auditoria_no_delete BEFORE DELETE ON auditoria
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La tabla auditoria es de solo lectura/inserción';
END//
DELIMITER ;

-- ---------------------------------------------------------------------
-- 7. Vistas para el Panel, el Historial y los Informes
-- ---------------------------------------------------------------------

-- Historial: una fila por análisis con nº de hallazgos y severidad máxima
CREATE OR REPLACE VIEW v_historial AS
SELECT a.id_analisis,
       a.codigo,
       a.id_usuario,
       o.url                      AS objetivo,
       a.tipo,
       a.estado,
       a.creado_en                AS fecha,
       COUNT(h.id_hallazgo)       AS hallazgos,
       ELT(MIN(h.severidad + 0), 'critica', 'alta', 'media', 'baja') AS severidad_max
FROM analisis a
JOIN autorizaciones au ON au.id_autorizacion = a.id_autorizacion
JOIN objetivos o       ON o.id_objetivo      = au.id_objetivo
LEFT JOIN hallazgos h  ON h.id_analisis      = a.id_analisis
GROUP BY a.id_analisis, a.codigo, a.id_usuario, o.url, a.tipo, a.estado, a.creado_en;

-- Panel: tarjetas superiores
CREATE OR REPLACE VIEW v_panel_contadores AS
SELECT
  (SELECT COUNT(*) FROM analisis WHERE estado = 'completado')                        AS analisis_realizados,
  (SELECT COUNT(*) FROM analisis WHERE creado_en >= NOW() - INTERVAL 7 DAY)           AS analisis_esta_semana,
  (SELECT COUNT(*) FROM hallazgos WHERE severidad = 'critica')                       AS criticas,
  (SELECT COUNT(*) FROM hallazgos WHERE severidad = 'critica' AND estado = 'abierto') AS criticas_sin_corregir,
  (SELECT COUNT(*) FROM dependencias)                                                 AS dependencias_vulnerables;

-- Panel: hallazgos por severidad, últimos 30 días
CREATE OR REPLACE VIEW v_hallazgos_por_severidad_30d AS
SELECT h.severidad, COUNT(*) AS total
FROM hallazgos h
JOIN analisis a ON a.id_analisis = h.id_analisis
WHERE a.creado_en >= NOW() - INTERVAL 30 DAY
GROUP BY h.severidad;

-- Panel: tipos de vulnerabilidad
CREATE OR REPLACE VIEW v_tipos_vulnerabilidad AS
SELECT t.nombre, COUNT(h.id_hallazgo) AS total
FROM tipos_vulnerabilidad t
LEFT JOIN hallazgos h ON h.id_tipo = t.id_tipo
GROUP BY t.id_tipo, t.nombre
ORDER BY total DESC;

-- Perfil: estadísticas del usuario
CREATE OR REPLACE VIEW v_perfil_estadisticas AS
SELECT u.id_usuario,
       (SELECT COUNT(*) FROM analisis a WHERE a.id_usuario = u.id_usuario AND a.estado = 'completado') AS analisis_realizados,
       (SELECT COUNT(*) FROM informes i JOIN analisis a ON a.id_analisis = i.id_analisis
         WHERE a.id_usuario = u.id_usuario) AS informes_generados,
       (SELECT COUNT(*) FROM hallazgos h JOIN analisis a ON a.id_analisis = h.id_analisis
         WHERE a.id_usuario = u.id_usuario AND h.severidad = 'critica' AND h.estado = 'corregido') AS criticos_corregidos,
       u.ultimo_acceso
FROM usuarios u;

-- ---------------------------------------------------------------------
-- 8. Datos iniciales (catálogos)
-- ---------------------------------------------------------------------
INSERT INTO roles (nombre) VALUES ('administrador'), ('auditor');

INSERT INTO modulos (nombre) VALUES
  ('Inyección SQL'), ('XSS (Cross-Site Scripting)'), ('Path traversal'),
  ('Open redirect'), ('Dependencias (OSV y NVD)'), ('Cabeceras de seguridad HTTP');

INSERT INTO tipos_vulnerabilidad (nombre, categoria) VALUES
  ('Inyección SQL',                 'inyeccion'),
  ('XSS reflejado',                 'xss'),
  ('Path traversal',                'archivos'),
  ('Open redirect',                 'redireccion'),
  ('Dependencia vulnerable',        'dependencias'),
  ('Cabecera de seguridad ausente', 'configuracion');

-- ---------------------------------------------------------------------
-- 9. (Opcional) Datos de demostración para las pantallas del Figma.
--    Quitar los comentarios solo en el entorno de pruebas.
--    El hash es un marcador: genera uno real con la app (Argon2/bcrypt).
-- ---------------------------------------------------------------------
-- INSERT INTO usuarios (id_rol, nombre, apellidos, email, organizacion, password_hash)
--   VALUES (1, 'Aleix', 'García', 'aleix@ejemplo.com', 'Proyecto de aula · Planeta FP', 'HASH_DE_PRUEBA');
-- INSERT INTO preferencias (id_usuario) VALUES (1);
-- INSERT INTO objetivos (id_usuario, url) VALUES (1, 'https://tienda-demo.local');
-- INSERT INTO autorizaciones (id_objetivo, id_usuario) VALUES (1, 1);
-- INSERT INTO analisis (codigo, id_usuario, id_autorizacion, tipo, estado, finalizado_en)
--   VALUES ('A-024', 1, 1, 'completo', 'completado', NOW());
-- INSERT INTO analisis_modulos (id_analisis, id_modulo) VALUES (1,1),(1,2),(1,3),(1,4),(1,5),(1,6);
-- INSERT INTO hallazgos (id_analisis, id_tipo, severidad, archivo, linea, evidencia, validado_ia)
--   VALUES (1, 1, 'critica', 'app/db.py', 42, 'cursor.execute("SELECT * FROM users WHERE id=" + uid)', 1);
-- INSERT INTO dependencias (id_analisis, paquete, version, cve_id, cvss, fuente)
--   VALUES (1, 'flask', '1.0.2', 'CVE-2023-30861', 7.5, 'osv');
