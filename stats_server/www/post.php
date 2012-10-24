<?php

$password = "";

require "db.php";

function dump($msg) {
	file_put_contents("php://stdout", "$msg\n");
}

class MessageAggregator {
	function __construct($db) {
		$this->db = $db;
		$this->base_counts = array();
		$this->changes = array();
	}

	function base_count($name) {
		if (isset($this->base_counts[$name])) {
			return $this->base_counts[$name];
		} else {
			return 0;
		}
	}

	function user_changeset($name) {
		if (!isset($this->changes[$name])) {
			$user = new stdclass;
			$user->message_count = 0;
			$this->changes[$name] = $user;
		}

		return $this->changes[$name];
	}

	// fill the base counts
	function seed_names($names) {
		$escaped_names = array();
		foreach ($names as $name) {
			$escaped_names[] = $this->db->real_escape_string($name);
		}

		if ($res = $this->db->query("select name, message_count from `users` where name in (".implode(",", $escaped_names).")")) {
			while ($row = $res->fetch_assoc()) {
				$this->base_counts[$row["name"]] = intval($row["message_count"]);
			}
		}
	}

	function handle_message($item) {
		$user = $this->user_changeset($item->name);
		$user->message_count += 1;
		$total = $this->base_count($item->name) + $user->message_count;

		if ($total <= 1 || rand()/getrandmax() < 1.0/$total) {
			$user->random_message = $item->msg;
		}

		if (empty($user->last_seen)) {
			$user->last_seen = $item->time;
		} else {
			if (strtotime($item->time) > strtotime($user->last_seen)) {
				$user->last_seen = $item->time;
			}
		}
	}

	function save_changes() {
		foreach ($this->changes as $name => $changes) {
			$stm = $this->db->prepare("select name from `users` where name = ?");
			$stm->bind_param("s", $name);
			$stm->execute();
			$stm->store_result();

			$safe_name = $this->db->real_escape_string($name);
			$safe_last = $this->db->real_escape_string($changes->last_seen);
			if (isset($changes->random_message)) {
				$safe_random = $this->db->real_escape_string($changes->random_message);
			}

			// create new entry
			if ($stm->num_rows == 0) {
				$this->db->query("insert into `users` set
					`name` = '$safe_name',
					`message_count` = $changes->message_count,
					`last_seen` = '$safe_last',
					`random_message` = '$safe_random'
				");
			} else {
				$this->db->query("update `users` set
						message_count = message_count + $changes->message_count,
						".(isset($changes->random_message) ? "random_message = '$safe_random'," : "")."
						last_seen = '$safe_last'
					where name = '$safe_name'");
			}
		}
	}
}

$post = file_get_contents("php://input");
if ($post) {
	if (!isset($_GET["password"]) || $_GET["password"] != $password) {
		exit("failed to auth");
	}

	@file_put_contents("last_post", $post);

	$data = json_decode(utf8_encode($post)); // quick hack to get around invalid characters, I think...

	$stm = $db->prepare("insert into `user_messages`
		(`name`, `time`) values (?, ?)");
	
	$stm->bind_param("ss", $_name, $_time);
	foreach ($data as $item) {
		$_name = $item->name;
		$_time = $item->time;
		$stm->execute();
	}

	$names = array();
	foreach ($data as $item) {
		$names[] = $item->name;
	}

	$m = new MessageAggregator($db);
	$m->seed_names(array_unique($names));
	foreach ($data as $item) {
		$m->handle_message($item);
	}

	$m->save_changes();

	@file_put_contents("last_updated", time());
	echo "ok";
}

