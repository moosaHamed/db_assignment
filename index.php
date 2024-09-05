<!--HomePage, Run Here-->
<?php
$conn = new mysqli('localhost', 'username', 'password', 'database');
if ($conn->connect_error) die('Connection failed: ' . $conn->connect_error); ?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="02_style.css">
    <title>bestSpa</title>
</head>
<body>
<h2>bestSpa</h2>
<div class="card-background"><?php include 'list.php'; ?></div>
<div class="card-background"><?php include 'insert.php'; ?></div>
</body>
</html>