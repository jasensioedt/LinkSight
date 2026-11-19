-- 003 · Mantenimiento automático: purga de sesiones caducadas cada hora.
-- Requiere event_scheduler=ON (docker-compose ya lo activa; en una VM añade
-- "event_scheduler=ON" en [mysqld] de my.cnf). Si está apagado, el evento se crea igualmente.
DROP EVENT IF EXISTS ev_purgar_sesiones;
CREATE EVENT ev_purgar_sesiones
  ON SCHEDULE EVERY 1 HOUR
  DO DELETE FROM sesiones WHERE expira_en < NOW();
