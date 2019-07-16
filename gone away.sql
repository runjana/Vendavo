mysql server has gone away

set global net_buffer_length=1000000; 
set global max_allowed_packet=1000000000;
SET @@GLOBAL.wait_timeout=300;


SHOW SESSION VARIABLES LIKE "wait_timeout"; -- 300
SHOW GLOBAL VARIABLES LIKE "wait_timeout"; -- 300

SET @@GLOBAL.wait_timeout=60000
SET @@GLOBAL.innodb_lock_wait_timeout=60000
