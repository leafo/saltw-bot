<?php

require "db.php";

$action = !empty($_GET["action"]) ? $_GET["action"] : "top";

$span = 60*60*24*7;

function dump_query($query) {
	global $db;
	if ($res = $db->query($query)) {
		$out = array();
		while ($row = $res->fetch_assoc() and $out[] = $row);
		exit(json_encode($out));
	} else {
		exit(json_encode(array("error" => $db->error)));
	}
}


header('Content-type: application/json');
switch ($action) {
case "top":
	dump_query("select * from `users` order by message_count desc limit 30");
	break;
case "chart":
	dump_query("
		select
			date_format(time, '%Y-%m-%d-%H') as hour,
			count(*) as num_messages
		from `user_messages`
			where unix_timestamp(time) > unix_timestamp(now()) - $span
		group by hour
		order by time desc
	");
	break;
case "last_updated":
	$out = @file_get_contents("last_updated");
	if ($out) {
		exit(json_encode(array( "seconds_ago" => time() - $out)));
	} else {
		exit(json_encode(array( "error" => "don't know!")));
	}
}

