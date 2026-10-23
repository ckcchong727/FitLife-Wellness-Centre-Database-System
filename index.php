<?php
require __DIR__ . '/db.php';

/* ---------- helpers ---------- */
class Raw { function __construct(public string $s) {} }
function h($v) { return $v instanceof Raw ? $v->s : htmlspecialchars((string)$v, ENT_QUOTES); }
function chip($s) { return new Raw('<span class="chip ' . h($s) . '">' . h($s) . '</span>'); }
function table(array $head, array $rows, array $num = []) {
    echo '<div class="panel"><table><thead><tr>';
    foreach ($head as $i => $t) echo '<th class="' . (in_array($i, $num) ? 'n' : '') . '">' . h($t) . '</th>';
    echo '</tr></thead><tbody>';
    if (!$rows) echo '<tr><td colspan="' . count($head) . '">No rows.</td></tr>';
    foreach ($rows as $r) {
        echo '<tr>';
        $i = 0;
        foreach ($r as $c) { echo '<td class="' . (in_array($i++, $num) ? 'n' : '') . '">' . h($c) . '</td>'; }
        echo '</tr>';
    }
    echo '</tbody></table></div>';
}
function sqlbox($sql) {
    echo '<details class="sql"><summary>Show the SQL behind this page</summary><pre>' . h(trim($sql)) . '</pre></details>';
}
function heading($t, $l) { echo '<h1>' . h($t) . '</h1><p class="lead">' . h($l) . '</p>'; }
function options($rows, $val, $label) {
    foreach ($rows as $r) echo '<option value="' . h($r[$val]) . '">' . h($r[$label]) . '</option>';
}
function nextId($pdo, $table, $col) {
    return (int)$pdo->query("SELECT COALESCE(MAX($col),0)+1 FROM $table")->fetchColumn();
}

/* ---------- the report's SQL (single source of truth) ---------- */
$Q = [];
$Q['members'] = "SELECT m.member_id, m.member_name, m.member_contact, m.member_email,
  ms.membership_status,
  COALESCE(e.total_programs_enrolled, 0) AS total_programs_enrolled,
  COALESCE(a.total_classes_attended, 0)  AS total_classes_attended,
  COALESCE(p.total_payments_made, 0)     AS total_payments_made
FROM member m
JOIN membership ms ON ms.membership_id = m.membership_id
LEFT JOIN (
  SELECT member_id, COUNT(DISTINCT program_id) AS total_programs_enrolled
  FROM enrolment GROUP BY member_id
) e ON e.member_id = m.member_id
LEFT JOIN (
  SELECT member_id,
         COUNT(DISTINCT CASE WHEN attendance_status='Attended' THEN class_id END) AS total_classes_attended
  FROM class_attendance GROUP BY member_id
) a ON a.member_id = m.member_id
LEFT JOIN (
  SELECT member_id, COUNT(DISTINCT payment_id) AS total_payments_made
  FROM payment GROUP BY member_id
) p ON p.member_id = m.member_id
ORDER BY m.member_id";

$Q['classes'] = "SELECT c.class_id, c.class_date, c.class_start, c.class_end,
  CONCAT(t.first_name, ' ', t.last_name) AS trainer_name,
  c.class_status, pc.program_category_id, pc.program_name AS program_category_name, pr.program_id
FROM class c
JOIN trainer t ON t.trainer_id = c.trainer_id
JOIN program pr ON pr.program_id = c.program_id
JOIN program_category pc ON pc.program_category_id = pr.program_category_id
ORDER BY c.class_date, c.class_start";

$Q['trainers'] = "SELECT t.trainer_id,
  CONCAT(t.first_name, ' ', t.last_name) AS trainer_name,
  COUNT(c.class_id) AS total_classes_taught,
  SUM(CASE WHEN c.class_status = 'Cancelled' THEN 1 ELSE 0 END) AS total_cancelled_classes
FROM trainer t
LEFT JOIN class c ON c.trainer_id = t.trainer_id
GROUP BY t.trainer_id, trainer_name
ORDER BY total_classes_taught DESC, trainer_name";

$Q['quarter'] = "SELECT YEAR(p.payment_date) AS pay_year, QUARTER(p.payment_date) AS pay_quarter,
  SUM(mpplan.membership_fee) AS total_membership_fees
FROM payment p
JOIN membership_payment mp ON mp.payment_id = p.payment_id
JOIN membership m ON m.membership_id = mp.membership_id
JOIN membership_plan mpplan ON mpplan.membership_type = m.membership_type
GROUP BY YEAR(p.payment_date), QUARTER(p.payment_date)
ORDER BY pay_year, pay_quarter";

$Q['annual'] = "SELECT YEAR(p.payment_date) AS pay_year,
  SUM(mpplan.membership_fee) AS total_membership_fees
FROM payment p
JOIN membership_payment mp ON mp.payment_id = p.payment_id
JOIN membership m ON m.membership_id = mp.membership_id
JOIN membership_plan mpplan ON mpplan.membership_type = m.membership_type
GROUP BY YEAR(p.payment_date)
ORDER BY pay_year";

$Q['top'] = "SELECT pr.program_id,
  COUNT(DISTINCT e.member_id) AS total_enrolled_members,
  CONCAT(t.first_name, ' ', t.last_name) AS assigned_trainer,
  pc.program_name AS program_category_name
FROM program pr
JOIN enrolment e ON e.program_id = pr.program_id
JOIN trainer t ON t.trainer_id = pr.trainer_id
JOIN program_category pc ON pc.program_category_id = pr.program_category_id
GROUP BY pr.program_id, assigned_trainer, program_category_name
ORDER BY total_enrolled_members DESC, pr.program_id
LIMIT 5";

/* ---------- CRUD handler (POST, then redirect) ---------- */
$pages = [
    'members' => 'Members', 'classes' => 'Class schedule', 'trainers' => 'Trainer report',
    'fees' => 'Membership fees', 'top' => 'Top programs', 'manage' => 'Manage (CRUD)',
];
$page = $_GET['page'] ?? 'members';
if (!isset($pages[$page])) $page = 'members';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $ok = true;
    try {
        switch ($_POST['action'] ?? '') {
            case 'add_member':
                $pdo->beginTransaction();
                $ms = nextId($pdo, 'membership', 'membership_id');
                $id = nextId($pdo, 'member', 'member_id');
                $pdo->prepare("INSERT INTO membership VALUES (?, 6, 'Active', ?)")->execute([$ms, $_POST['type']]);
                $pdo->prepare("INSERT INTO member (member_id, membership_id, member_name, member_email) VALUES (?, ?, ?, ?)")
                    ->execute([$id, $ms, trim($_POST['name']), trim($_POST['email'])]);
                $pdo->prepare("INSERT INTO membership_enrolment VALUES (?, CURDATE(), ?)")->execute([$id, $ms]);
                $pdo->commit();
                $msg = "Member $id added with membership $ms.";
                break;
            case 'enrol':
                $id = nextId($pdo, 'enrolment', 'enrolment_id');
                $pdo->prepare("INSERT INTO enrolment VALUES (?, ?, ?, CURDATE())")
                    ->execute([$id, $_POST['member'], $_POST['program']]);
                $msg = "Enrolment $id created.";
                break;
            case 'update_class':
                $st = $pdo->prepare("UPDATE class SET class_status = ? WHERE class_id = ?");
                $st->execute([$_POST['status'], $_POST['class']]);
                $msg = "Class {$_POST['class']} is now {$_POST['status']} (" . $st->rowCount() . " row changed).";
                break;
            case 'delete_enrolment':
                $st = $pdo->prepare("DELETE FROM enrolment WHERE enrolment_id = ?");
                $st->execute([$_POST['enrolment']]);
                $msg = "Enrolment {$_POST['enrolment']} deleted (" . $st->rowCount() . " row).";
                break;
            default:
                $msg = 'Unknown action.'; $ok = false;
        }
    } catch (PDOException $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        $ok = false;
        $msg = $e->getCode() === '23000'
            ? 'That record already exists or is still in use. ' . $e->errorInfo[2]
            : 'Database error: ' . $e->getMessage();
    }
    header('Location: index.php?page=manage&ok=' . (int)$ok . '&msg=' . urlencode($msg));
    exit;
}
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>FitLife Wellness Centre</title>
<link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@600;700&family=Figtree:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="style.css">
</head>
<body>
<div class="app">
<aside>
  <div class="logo">Fit<i>Life</i></div>
  <div class="tag">Wellness Centre · fitlife_db</div>
  <nav>
    <?php foreach ($pages as $k => $label): ?>
      <a href="?page=<?= $k ?>" <?= $k === $page ? 'aria-current="page"' : '' ?>><?= h($label) ?></a>
    <?php endforeach; ?>
  </nav>
</aside>
<main>
<?php
switch ($page) {

case 'members':
    heading('Members', 'Every member with membership status, programs enrolled, classes attended and payments made. (Query i)');
    $rows = [];
    foreach ($pdo->query($Q['members']) as $r) {
        $r['membership_status'] = chip($r['membership_status']);
        $rows[] = array_values($r);
    }
    table(['ID', 'Name', 'Contact', 'Email', 'Membership', 'Programs', 'Classes attended', 'Payments'], $rows, [5, 6, 7]);
    sqlbox($Q['members']);
    break;

case 'classes':
    heading('Class schedule', 'All scheduled classes by date and time, with trainer, status and program category. (Query ii)');
    $rows = [];
    foreach ($pdo->query($Q['classes']) as $r) {
        $rows[] = [$r['class_id'], $r['class_date'], substr($r['class_start'], 0, 5) . ' – ' . substr($r['class_end'], 0, 5),
                   $r['trainer_name'], chip($r['class_status']), $r['program_category_name'], $r['program_id']];
    }
    table(['Class', 'Date', 'Time', 'Trainer', 'Status', 'Category', 'Program'], $rows);
    sqlbox($Q['classes']);
    break;

case 'trainers':
    heading('Trainer report', 'Classes taught and classes cancelled for each trainer. (Query iii)');
    $data = $pdo->query($Q['trainers'])->fetchAll();
    $max = max(1, ...array_map(fn($r) => (int)$r['total_classes_taught'], $data ?: [['total_classes_taught' => 1]]));
    $rows = [];
    foreach ($data as $r) {
        $w = $r['total_classes_taught'] / $max * 160;
        $rows[] = [$r['trainer_id'], $r['trainer_name'],
                   new Raw('<div class="bar"><b style="width:' . $w . 'px"></b>' . (int)$r['total_classes_taught'] . '</div>'),
                   (int)$r['total_cancelled_classes']];
    }
    table(['ID', 'Trainer', 'Classes taught', 'Cancelled'], $rows, [3]);
    sqlbox($Q['trainers']);
    break;

case 'fees':
    heading('Membership fees', 'Fees collected per quarter and per year, based on each member’s plan. (Query iv)');
    $q = $pdo->query($Q['quarter'])->fetchAll();
    $max = max(1, ...array_map(fn($r) => (float)$r['total_membership_fees'], $q ?: [['total_membership_fees' => 1]]));
    $qr = [];
    foreach ($q as $r) {
        $w = $r['total_membership_fees'] / $max * 140;
        $qr[] = [$r['pay_year'] . ' Q' . $r['pay_quarter'],
                 new Raw('<div class="bar q"><b style="width:' . $w . 'px"></b>' . number_format($r['total_membership_fees'], 2) . '</div>')];
    }
    $ar = [];
    foreach ($pdo->query($Q['annual']) as $r) $ar[] = [$r['pay_year'], number_format($r['total_membership_fees'], 2)];
    echo '<div class="grid"><div><h2 style="margin:0 0 8px;font-size:17px">By quarter</h2>';
    table(['Quarter', 'Total (RM)'], $qr);
    echo '</div><div><h2 style="margin:0 0 8px;font-size:17px">By year</h2>';
    table(['Year', 'Total (RM)'], $ar, [1]);
    echo '</div></div>';
    sqlbox($Q['quarter'] . ";\n\n" . $Q['annual']);
    break;

case 'top':
    heading('Top 5 programs', 'The most popular programs by number of enrolled members. (Query v)');
    $data = $pdo->query($Q['top'])->fetchAll();
    $max = max(1, ...array_map(fn($r) => (int)$r['total_enrolled_members'], $data ?: [['total_enrolled_members' => 1]]));
    $rows = [];
    foreach ($data as $r) {
        $w = $r['total_enrolled_members'] / $max * 140;
        $rows[] = [$r['program_id'],
                   new Raw('<div class="bar"><b style="width:' . $w . 'px"></b>' . (int)$r['total_enrolled_members'] . '</div>'),
                   $r['assigned_trainer'], $r['program_category_name']];
    }
    table(['Program', 'Enrolled members', 'Trainer', 'Category'], $rows);
    sqlbox($Q['top']);
    break;

case 'manage':
    heading('Manage', 'Add, update and delete records in fitlife_db.');
    if (isset($_GET['msg'])) {
        echo '<div class="flash ' . (($_GET['ok'] ?? '0') === '1' ? 'ok' : 'err') . '">' . h($_GET['msg']) . '</div>';
    }
    $plans    = $pdo->query("SELECT membership_type FROM membership_plan ORDER BY membership_type")->fetchAll();
    $members  = $pdo->query("SELECT member_id, member_name FROM member ORDER BY member_id")->fetchAll();
    $programs = $pdo->query("SELECT p.program_id, CONCAT(p.program_id, ' · ', pc.program_name, ' (RM ', p.program_fee, ')') AS label
                             FROM program p JOIN program_category pc ON pc.program_category_id = p.program_category_id ORDER BY p.program_id")->fetchAll();
    $classes  = $pdo->query("SELECT class_id, CONCAT(class_id, ' · ', class_date, ' (', class_status, ')') AS label FROM class ORDER BY class_id")->fetchAll();
    $enrols   = $pdo->query("SELECT e.enrolment_id, CONCAT(e.enrolment_id, ' · ', m.member_name, ' → ', e.program_id) AS label
                             FROM enrolment e JOIN member m ON m.member_id = e.member_id ORDER BY e.enrolment_id")->fetchAll();
?>
<div class="grid">
  <form class="card" method="post">
    <input type="hidden" name="action" value="add_member">
    <h2>Add member</h2><p>Creates a membership, the member and the join record.</p>
    <label>Full name<input name="name" required maxlength="80"></label>
    <label>Email<input name="email" type="email" required maxlength="80"></label>
    <label>Plan<select name="type"><?php options($plans, 'membership_type', 'membership_type'); ?></select></label>
    <button class="btn">Add member</button>
  </form>

  <form class="card" method="post">
    <input type="hidden" name="action" value="enrol">
    <h2>Enrol in a program</h2><p>A member can join each program once.</p>
    <label>Member<select name="member"><?php options($members, 'member_id', 'member_name'); ?></select></label>
    <label>Program<select name="program"><?php options($programs, 'program_id', 'label'); ?></select></label>
    <button class="btn">Enrol member</button>
  </form>

  <form class="card" method="post">
    <input type="hidden" name="action" value="update_class">
    <h2>Update class status</h2><p>Mark a class active, completed or cancelled.</p>
    <label>Class<select name="class"><?php options($classes, 'class_id', 'label'); ?></select></label>
    <label>New status<select name="status"><option>Active</option><option>Completed</option><option>Cancelled</option></select></label>
    <button class="btn">Update class</button>
  </form>

  <form class="card" method="post" onsubmit="return confirm('Delete this enrolment?')">
    <input type="hidden" name="action" value="delete_enrolment">
    <h2>Delete enrolment</h2><p>Removes the member from a program.</p>
    <label>Enrolment<select name="enrolment"><?php options($enrols, 'enrolment_id', 'label'); ?></select></label>
    <button class="btn del">Delete enrolment</button>
  </form>
</div>
<?php
    break;
}
?>
</main>
</div>
</body>
</html>