<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Hello from Slalom and Google</title>
<style>
body {
    background-color: #0C62FB;
    color: #FFFFFF;
    font-family: "Lucida Console", "Courier New", monospace;
}
</style>
</head>
<body>
<h1>👋 Hello</h1>
<p>I'm a web server in the Google Cloud.</p>
<br>
<p><b>My hostname is:</b>    <?php system('hostname -s', $retval); ?></p>
<p><b>My kernel release:</b> <?php system('uname -r', $retval); ?></p>
<p>
<b>I'm online without a reboot since:</b><br>
<?php system('uptime', $retval); ?>
</p>
<br><hr>
<p><i><?php system('date', $retval); ?></i></p>
</body>
</html>