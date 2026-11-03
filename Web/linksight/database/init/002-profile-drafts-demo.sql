-- Profile uploads, resumable drafts and administrator-only demo reports.
ALTER TABLE analisis
  ADD COLUMN notas TEXT NULL AFTER finalizado_en;

CREATE TABLE borradores_analisis (
  id_borrador INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_usuario INT UNSIGNED NOT NULL,
  url VARCHAR(2048) NOT NULL,
  tipo ENUM('estatico','dinamico','completo') NOT NULL DEFAULT 'completo',
  modulos JSON NOT NULL,
  hallazgos JSON NOT NULL,
  notas TEXT NULL,
  progreso TINYINT UNSIGNED NOT NULL DEFAULT 0,
  estado ENUM('borrador','convertido') NOT NULL DEFAULT 'borrador',
  id_analisis INT UNSIGNED NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_borrador),
  KEY ix_borradores_usuario_fecha (id_usuario, actualizado_en),
  CONSTRAINT fk_borradores_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario) ON DELETE CASCADE,
  CONSTRAINT fk_borradores_analisis FOREIGN KEY (id_analisis)
    REFERENCES analisis (id_analisis) ON DELETE SET NULL,
  CONSTRAINT ck_borradores_progreso CHECK (progreso BETWEEN 0 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE informes_demo (
  id_informe_demo INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_usuario_generador INT UNSIGNED NOT NULL,
  url VARCHAR(2048) NOT NULL,
  fecha_analisis DATETIME NOT NULL,
  resumen TEXT NOT NULL,
  hallazgos JSON NOT NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_informe_demo),
  KEY ix_informes_demo_fecha (creado_en),
  CONSTRAINT fk_informes_demo_usuario FOREIGN KEY (id_usuario_generador)
    REFERENCES usuarios (id_usuario) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
