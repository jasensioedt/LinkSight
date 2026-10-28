<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');
header('Cache-Control: no-store');

$isHttps = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off');
$isHttps = $isHttps || strtolower((string)(getenv('APP_FORCE_HTTPS') ?: 'false')) === 'true';
date_default_timezone_set('UTC');
ini_set('session.use_strict_mode', '1');
ini_set('session.use_only_cookies', '1');
ini_set('session.use_trans_sid', '0');
session_set_cookie_params([
    'lifetime' => 0,
    'path' => '/',
    'secure' => $isHttps,
    'httponly' => true,
    'samesite' => 'Strict',
]);
session_start();

function respond(array $body, int $status = 200): never {
    http_response_code($status);
    echo json_encode($body, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function fail(string $message, int $status = 400): never {
    respond(['ok' => false, 'error' => $message], $status);
}

function input(): array {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw ?: '{}', true);
    return is_array($data) ? $data : [];
}

function utf8Length(string $value): int {
    $result = preg_match_all('/./us', $value, $matches);
    return $result === false ? PHP_INT_MAX : $result;
}

function clientIp(): string {
    $ip = (string)($_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR'] ?? '');
    return filter_var($ip, FILTER_VALIDATE_IP) ? $ip : '0.0.0.0';
}

function db(): PDO {
    static $pdo = null;
    if ($pdo instanceof PDO) return $pdo;
    $host = getenv('DB_HOST') ?: '127.0.0.1';
    $port = getenv('DB_PORT') ?: '3306';
    $name = getenv('DB_NAME') ?: 'linksight';
    $user = getenv('DB_USER') ?: 'linksight_app';
    $pass = getenv('DB_PASSWORD') ?: '';
    if ($pass === '') fail('Falta configurar DB_PASSWORD en el entorno.', 503);
    try {
        $pdo = new PDO("mysql:host={$host};port={$port};dbname={$name};charset=utf8mb4", $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
        return $pdo;
    } catch (PDOException $e) {
        error_log('LinkSight database connection failed: ' . $e->getMessage());
        fail('No se pudo conectar con la base de datos. Revisa la configuración del servidor.', 503);
    }
}

function requireUser(): int {
    if (empty($_SESSION['user_id'])) fail('Inicia sesión para continuar.', 401);
    return (int)$_SESSION['user_id'];
}

function requireCsrf(): void {
    $token = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
    if (!isset($_SESSION['csrf']) || !is_string($token) || !hash_equals($_SESSION['csrf'], $token)) {
        fail('La sesión ha caducado. Recarga la página e inténtalo de nuevo.', 419);
    }
}

function csrf(): string {
    if (empty($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(32));
    return $_SESSION['csrf'];
}

function throttle(string $key, int $limit, int $window, bool $increment = false, bool $clear = false): void {
    $directory = '/var/lib/linksight/throttle';
    if (!is_dir($directory) && !mkdir($directory, 0700, true) && !is_dir($directory)) {
        fail('No se pudo comprobar el límite de intentos. Inténtalo más tarde.', 503);
    }
    if (random_int(1, 64) === 1) {
        foreach (glob($directory . '/*.json') ?: [] as $oldFile) {
            $cleanupFile = fopen($oldFile, 'c+');
            if (!$cleanupFile || !flock($cleanupFile, LOCK_EX)) { if ($cleanupFile) fclose($cleanupFile); continue; }
            clearstatcache(true, $oldFile);
            if (filemtime($oldFile) !== false && filemtime($oldFile) < time() - 3600) unlink($oldFile);
            flock($cleanupFile, LOCK_UN); fclose($cleanupFile);
        }
    }
    $path = $directory . '/' . hash('sha256', $key) . '.json';
    $oldMask = umask(0077);
    $file = fopen($path, 'c+');
    umask($oldMask);
    if (!$file || !flock($file, LOCK_EX)) fail('No se pudo comprobar el límite de intentos.', 503);
    $raw = stream_get_contents($file);
    $times = json_decode($raw ?: '[]', true);
    if (!is_array($times)) $times = [];
    $cutoff = time() - $window;
    $times = array_values(array_filter($times, static fn($at) => is_int($at) && $at > $cutoff));
    if (!$clear && count($times) >= $limit) {
        flock($file, LOCK_UN); fclose($file);
        fail('Demasiados intentos. Espera un rato antes de volver a probar.', 429);
    }
    if ($clear) $times = [];
    elseif ($increment) $times[] = time();
    ftruncate($file, 0); rewind($file);
    fwrite($file, json_encode($times)); fflush($file);
    flock($file, LOCK_UN); fclose($file);
}

function loginThrottle(string $email, string $mode = 'check'): void {
    $ip = clientIp();
    $increment = $mode === 'failure'; $clear = $mode === 'success';
    throttle('login-ip:' . $ip, 30, 900, $increment, $clear);
    throttle('login-account:' . $ip . ':' . strtolower($email), 8, 900, $increment, $clear);
}

function audit(PDO $pdo, int $userId, string $action, ?int $analysisId = null): void {
    $stmt = $pdo->prepare('INSERT INTO auditoria (id_usuario,id_analisis,accion,ip) VALUES (?,?,?,?)');
    $stmt->execute([$userId, $analysisId, $action, substr(clientIp(), 0, 45)]);
}

function sessionRow(PDO $pdo, int $userId): void {
    $sessionKey = hash('sha256', session_id());
    $stmt = $pdo->prepare('INSERT INTO sesiones (id_sesion,id_usuario,navegador,sistema,ciudad,ip,expira_en) VALUES (?,?,?,?,?,?,?)');
    $stmt->execute([$sessionKey, $userId, substr($_SERVER['HTTP_USER_AGENT'] ?? 'Navegador', 0, 60), 'Web', null, substr(clientIp(), 0, 45), date('Y-m-d H:i:s', time() + 60 * 60 * 24 * 14)]);
}

function currentUser(PDO $pdo, int $userId): array {
    $stmt = $pdo->prepare('SELECT u.id_usuario,u.nombre,u.apellidos,u.email,u.organizacion,u.idioma,u.zona_horaria,u.avatar_ruta,u.creado_en,u.ultimo_acceso,r.nombre rol FROM usuarios u JOIN roles r ON r.id_rol=u.id_rol WHERE u.id_usuario=? AND u.activo=1');
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    if (!$user) fail('La cuenta no está disponible.', 401);
    return $user;
}

$action = $_GET['action'] ?? '';
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($action === 'csrf' && $method === 'GET') respond(['ok' => true, 'csrf' => csrf()]);

if ($action === 'register' && $method === 'POST') {
    requireCsrf();
    $data = input();
    $name = trim((string)($data['name'] ?? ''));
    $surname = trim((string)($data['surname'] ?? ''));
    $email = strtolower(trim((string)($data['email'] ?? '')));
    $password = (string)($data['password'] ?? '');
    if ($name === '' || $surname === '' || utf8Length($name)>60 || utf8Length($surname)>100 || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email)>255) fail('Completa un nombre, apellidos y correo válidos.');
    if (strlen($password) < 10 || strlen($password) > 72) fail('La contraseña debe tener entre 10 y 72 bytes.');
    throttle('register-ip:' . clientIp(), 5, 3600, true);
    $pdo = db();
    try {
        $pdo->beginTransaction();
        $role = $pdo->query("SELECT id_rol FROM roles WHERE nombre='auditor' LIMIT 1")->fetchColumn();
        if (!$role) fail('No se han cargado los roles iniciales de la base de datos.', 503);
        $stmt = $pdo->prepare('INSERT INTO usuarios (id_rol,nombre,apellidos,email,password_hash) VALUES (?,?,?,?,?)');
        $stmt->execute([(int)$role, $name, $surname, $email, password_hash($password, PASSWORD_DEFAULT)]);
        $userId = (int)$pdo->lastInsertId();
        $pdo->prepare('INSERT INTO preferencias (id_usuario) VALUES (?)')->execute([$userId]);
        $pdo->commit();
        session_regenerate_id(true);
        $_SESSION['user_id'] = $userId;
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
        sessionRow($pdo, $userId);
        $pdo->prepare('UPDATE usuarios SET ultimo_acceso=NOW() WHERE id_usuario=?')->execute([$userId]);
        audit($pdo, $userId, 'registro');
        respond(['ok' => true, 'user' => currentUser($pdo, $userId), 'csrf' => csrf()], 201);
    } catch (PDOException $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        if ($e->getCode() === '23000') fail('Ya existe una cuenta con ese correo electrónico.', 409);
        error_log('LinkSight registration failed: ' . $e->getMessage());
        fail('No se pudo crear la cuenta.', 500);
    }
}

if ($action === 'login' && $method === 'POST') {
    requireCsrf();
    $data = input();
    $email = strtolower(trim((string)($data['email'] ?? '')));
    $password = (string)($data['password'] ?? '');
    if (strlen($email)>255 || strlen($password)>72) fail('Correo o contraseña incorrectos.', 401);
    loginThrottle($email);
    $stmt = db()->prepare('SELECT id_usuario,password_hash FROM usuarios WHERE email=? AND activo=1');
    $stmt->execute([$email]);
    $row = $stmt->fetch();
    if (!$row || !password_verify($password, $row['password_hash'])) { loginThrottle($email, 'failure'); fail('Correo o contraseña incorrectos.', 401); }
    loginThrottle($email, 'success');
    session_regenerate_id(true);
    $_SESSION['user_id'] = (int)$row['id_usuario'];
    $_SESSION['csrf'] = bin2hex(random_bytes(32));
    $pdo = db();
    $pdo->prepare('UPDATE usuarios SET ultimo_acceso=NOW() WHERE id_usuario=?')->execute([$_SESSION['user_id']]);
    sessionRow($pdo, $_SESSION['user_id']);
    audit($pdo, $_SESSION['user_id'], 'login');
    respond(['ok' => true, 'user' => currentUser($pdo, $_SESSION['user_id']), 'csrf' => csrf()]);
}

if ($action === 'me' && $method === 'GET') {
    $userId = requireUser();
    respond(['ok' => true, 'user' => currentUser(db(), $userId), 'csrf' => csrf()]);
}

if ($action === 'logout' && $method === 'POST') {
    requireUser(); requireCsrf();
    $pdo = db(); $userId = (int)$_SESSION['user_id'];
    audit($pdo, $userId, 'logout');
    $pdo->prepare('DELETE FROM sesiones WHERE id_sesion=?')->execute([hash('sha256', session_id())]);
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000, $params['path'], '', (bool)$params['secure'], (bool)$params['httponly']);
    }
    session_destroy();
    respond(['ok' => true]);
}

$userId = requireUser();
$pdo = db();
$pdo->prepare('UPDATE sesiones SET ultimo_uso=NOW(),expira_en=DATE_ADD(NOW(),INTERVAL 14 DAY) WHERE id_sesion=? AND id_usuario=?')->execute([hash('sha256', session_id()), $userId]);

if ($action === 'dashboard' && $method === 'GET') {
    $q = $pdo->prepare("SELECT COUNT(*) total, SUM(estado='completado') completed, SUM(creado_en >= NOW()-INTERVAL 7 DAY) week_count, (SELECT COUNT(*) FROM hallazgos h JOIN analisis ah ON ah.id_analisis=h.id_analisis WHERE ah.id_usuario=? AND h.severidad='critica' AND h.estado='abierto') critical FROM analisis WHERE id_usuario=?");
    $q->execute([$userId,$userId]); $counts = $q->fetch();
    $q = $pdo->prepare("SELECT h.severidad,COUNT(*) total FROM hallazgos h JOIN analisis a ON a.id_analisis=h.id_analisis WHERE a.id_usuario=? AND a.creado_en>=NOW()-INTERVAL 30 DAY GROUP BY h.severidad");
    $q->execute([$userId]); $severity = $q->fetchAll();
    $q = $pdo->prepare("SELECT t.nombre,COUNT(*) total FROM hallazgos h JOIN analisis a ON a.id_analisis=h.id_analisis JOIN tipos_vulnerabilidad t ON t.id_tipo=h.id_tipo WHERE a.id_usuario=? GROUP BY t.id_tipo,t.nombre ORDER BY total DESC LIMIT 6");
    $q->execute([$userId]); $types = $q->fetchAll();
    $q = $pdo->prepare("SELECT a.id_analisis,a.codigo,o.url objetivo,a.tipo,a.estado,a.creado_en fecha,COUNT(h.id_hallazgo) hallazgos FROM analisis a JOIN autorizaciones au ON au.id_autorizacion=a.id_autorizacion JOIN objetivos o ON o.id_objetivo=au.id_objetivo LEFT JOIN hallazgos h ON h.id_analisis=a.id_analisis WHERE a.id_usuario=? GROUP BY a.id_analisis,a.codigo,o.url,a.tipo,a.estado,a.creado_en ORDER BY a.creado_en DESC LIMIT 5");
    $q->execute([$userId]); $recent = $q->fetchAll();
    $q = $pdo->prepare('SELECT COUNT(*) FROM dependencias d JOIN analisis a ON a.id_analisis=d.id_analisis WHERE a.id_usuario=?');
    $q->execute([$userId]); $dependencyCount=(int)$q->fetchColumn();
    respond(['ok'=>true,'counts'=>['completed'=>(int)$counts['completed'],'week'=>(int)$counts['week_count'],'critical'=>(int)$counts['critical'],'dependencies'=>$dependencyCount],'severity'=>$severity,'types'=>$types,'recent'=>$recent]);
}

if ($action === 'history' && $method === 'GET') {
    $sql = "SELECT a.id_analisis,a.codigo,o.url objetivo,a.tipo,a.estado,a.creado_en fecha,COUNT(h.id_hallazgo) hallazgos,CASE MIN(FIELD(h.severidad,'critica','alta','media','baja')) WHEN 1 THEN 'critica' WHEN 2 THEN 'alta' WHEN 3 THEN 'media' WHEN 4 THEN 'baja' ELSE NULL END severidad_max FROM analisis a JOIN autorizaciones au ON au.id_autorizacion=a.id_autorizacion JOIN objetivos o ON o.id_objetivo=au.id_objetivo LEFT JOIN hallazgos h ON h.id_analisis=a.id_analisis WHERE a.id_usuario=? GROUP BY a.id_analisis,a.codigo,o.url,a.tipo,a.estado,a.creado_en ORDER BY a.creado_en DESC";
    $stmt=$pdo->prepare($sql);$stmt->execute([$userId]);respond(['ok'=>true,'items'=>$stmt->fetchAll()]);
}

if ($action === 'analysis' && $method === 'POST') {
    requireCsrf(); $data=input();
    $url=trim((string)($data['url']??'')); $type=(string)($data['type']??'completo');
    $allowedTypes=['estatico','dinamico','completo'];
    if (strlen($url)>2048 || !filter_var($url,FILTER_VALIDATE_URL)) fail('Introduce una URL válida con http o https.');
    try { $parts=parse_url($url); } catch (ValueError $e) { fail('Introduce una URL válida con http o https.'); }
    if (!is_array($parts) || !in_array(strtolower((string)($parts['scheme']??'')),['http','https'],true) || isset($parts['user']) || isset($parts['pass'])) fail('Introduce una URL válida con http o https.');
    if (!in_array($type,$allowedTypes,true)) fail('El tipo de análisis no es válido.');
    if (empty($data['authorized'])) fail('Confirma que tienes autorización para analizar el sitio.');
    $allowedModules=['Inyección SQL','XSS (Cross-Site Scripting)','Path traversal','Open redirect','Dependencias (OSV y NVD)','Cabeceras de seguridad HTTP'];
    $moduleNames=is_array($data['modules']??null)?$data['modules']:[];
    if(count($moduleNames)>6 || count(array_filter($moduleNames,static fn($name)=>!is_string($name)||!in_array($name,$allowedModules,true)))>0) fail('La selección de módulos no es válida.');
    $moduleNames=array_values(array_unique($moduleNames));
    $pdo->beginTransaction();
    try {
        $stmt=$pdo->prepare('INSERT INTO objetivos (id_usuario,url) VALUES (?,?)');$stmt->execute([$userId,$url]);$targetId=(int)$pdo->lastInsertId();
        $stmt=$pdo->prepare('INSERT INTO autorizaciones (id_objetivo,id_usuario) VALUES (?,?)');$stmt->execute([$targetId,$userId]);$authId=(int)$pdo->lastInsertId();
        $code='A'.str_pad(substr((string)hrtime(true),-9),9,'0',STR_PAD_LEFT);
        $stmt=$pdo->prepare("INSERT INTO analisis (codigo,id_usuario,id_autorizacion,tipo,estado,validar_con_ia,formato_informe) VALUES (?,?,?,?,'pendiente',?,?)");
        $stmt->execute([$code,$userId,$authId,$type,!empty($data['ai'])?1:0,'md_pdf']);$analysisId=(int)$pdo->lastInsertId();
        if ($moduleNames) {
            $marks=implode(',',array_fill(0,count($moduleNames),'?'));
            $stmt=$pdo->prepare("SELECT id_modulo FROM modulos WHERE nombre IN ($marks)");$stmt->execute($moduleNames);
            $insert=$pdo->prepare('INSERT IGNORE INTO analisis_modulos (id_analisis,id_modulo) VALUES (?,?)');
            foreach($stmt->fetchAll(PDO::FETCH_COLUMN) as $moduleId)$insert->execute([$analysisId,$moduleId]);
        }
        audit($pdo,$userId,'lanzar_analisis',$analysisId);$pdo->commit();
        respond(['ok'=>true,'analysis'=>['id'=>$analysisId,'code'=>$code,'state'=>'pendiente'] ],201);
    } catch(Throwable $e) { if($pdo->inTransaction())$pdo->rollBack();error_log('LinkSight analysis creation failed: '.$e->getMessage());fail('No se pudo guardar el análisis.',500); }
}

if ($action === 'report' && $method === 'GET') {
    $id=(int)($_GET['id']??0);
    $stmt=$pdo->prepare('SELECT a.id_analisis,a.codigo,o.url objetivo,a.tipo,a.estado,a.creado_en,a.finalizado_en FROM analisis a JOIN autorizaciones au ON au.id_autorizacion=a.id_autorizacion JOIN objetivos o ON o.id_objetivo=au.id_objetivo WHERE a.id_analisis=? AND a.id_usuario=?');
    $stmt->execute([$id,$userId]);$analysis=$stmt->fetch();if(!$analysis)fail('No se encontró ese informe.',404);
    $stmt=$pdo->prepare('SELECT h.id_hallazgo,h.severidad,h.archivo,h.linea,h.evidencia,h.estado,h.explicacion_ia,h.correccion_ia,t.nombre tipo,t.categoria FROM hallazgos h JOIN tipos_vulnerabilidad t ON t.id_tipo=h.id_tipo WHERE h.id_analisis=? ORDER BY FIELD(h.severidad,"critica","alta","media","baja"),h.id_hallazgo');$stmt->execute([$id]);$findings=$stmt->fetchAll();
    respond(['ok'=>true,'analysis'=>$analysis,'findings'=>$findings]);
}

if ($action === 'settings' && $method === 'GET') {
    $stmt=$pdo->prepare('SELECT u.nombre,u.apellidos,u.email,u.organizacion,u.idioma,u.zona_horaria,p.formato_informe,p.incluir_correcciones_ia,p.incluir_resumen,p.avisar_fin_analisis,p.avisar_criticas,p.resumen_semanal FROM usuarios u LEFT JOIN preferencias p ON p.id_usuario=u.id_usuario WHERE u.id_usuario=?');$stmt->execute([$userId]);respond(['ok'=>true,'settings'=>$stmt->fetch()]);
}

if ($action === 'settings' && $method === 'POST') {
    requireCsrf();$data=input();
    $name=trim((string)($data['name']??''));$surname=trim((string)($data['surname']??''));$email=strtolower(trim((string)($data['email']??'')));$timezone=(string)($data['timezone']??'Europe/Madrid');$format=(string)($data['format']??'md_pdf');
    if($name===''||$surname===''||utf8Length($name)>60||utf8Length($surname)>100)fail('Nombre y apellidos son obligatorios y deben respetar el límite de longitud.');if(!filter_var($email,FILTER_VALIDATE_EMAIL)||strlen($email)>255)fail('El correo electrónico no es válido.');if(!in_array($timezone,DateTimeZone::listIdentifiers(DateTimeZone::ALL_WITH_BC),true)&&$timezone!=='UTC')fail('La zona horaria no es válida.');if(!in_array($format,['md_pdf','md','pdf'],true))fail('Formato de informe no válido.');
    $pdo->beginTransaction();
    try{$pdo->prepare('UPDATE usuarios SET nombre=?,apellidos=?,email=?,zona_horaria=? WHERE id_usuario=?')->execute([$name,$surname,$email,$timezone,$userId]);$stmt=$pdo->prepare('INSERT INTO preferencias (id_usuario,formato_informe,incluir_correcciones_ia,incluir_resumen,avisar_fin_analisis,avisar_criticas,resumen_semanal) VALUES (?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE formato_informe=VALUES(formato_informe),incluir_correcciones_ia=VALUES(incluir_correcciones_ia),incluir_resumen=VALUES(incluir_resumen),avisar_fin_analisis=VALUES(avisar_fin_analisis),avisar_criticas=VALUES(avisar_criticas),resumen_semanal=VALUES(resumen_semanal)');$stmt->execute([$userId,$format,(int)!empty($data['ai']), (int)!empty($data['summary']),(int)!empty($data['notify']), (int)!empty($data['critical']), (int)!empty($data['weekly'])]);$pdo->commit();respond(['ok'=>true]);}catch(PDOException $e){$pdo->rollBack();if($e->getCode()==='23000')fail('Ese correo ya está asociado a otra cuenta.',409);error_log('LinkSight settings failed: '.$e->getMessage());fail('No se pudieron guardar los ajustes.',500);}catch(Throwable $e){$pdo->rollBack();error_log('LinkSight settings failed: '.$e->getMessage());fail('No se pudieron guardar los ajustes.',500);}
}

if ($action === 'profile' && $method === 'GET') {
    $user=currentUser($pdo,$userId);$stmt=$pdo->prepare('SELECT analisis_realizados,informes_generados,criticos_corregidos,ultimo_acceso FROM v_perfil_estadisticas WHERE id_usuario=?');$stmt->execute([$userId]);$stats=$stmt->fetch()?:[];$stmt=$pdo->prepare('SELECT COUNT(DISTINCT au.id_objetivo) FROM autorizaciones au JOIN analisis a ON a.id_autorizacion=au.id_autorizacion WHERE a.id_usuario=?');$stmt->execute([$userId]);$stats['proyectos']=(int)$stmt->fetchColumn();$stmt=$pdo->prepare('SELECT navegador,sistema,ciudad,creada_en,ultimo_uso,expira_en FROM sesiones WHERE id_usuario=? AND expira_en>NOW() ORDER BY ultimo_uso DESC');$stmt->execute([$userId]);respond(['ok'=>true,'user'=>$user,'stats'=>$stats,'sessions'=>$stmt->fetchAll()]);
}

fail('Acción no encontrada.',404);
