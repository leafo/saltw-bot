<?php

$db_host = "localhost";
$db_user = "root";
$db_pass = "";
$db_name = "saltw";

if (file_exists("db.conf.php")) include_once "db.conf.php";

$db = new mysqli($db_host, $db_user, $db_pass, $db_name);
