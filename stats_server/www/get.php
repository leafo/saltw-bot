<?php

require "db.php";



$res = $db->query("
	select count(*) from `user_messages`
	")

