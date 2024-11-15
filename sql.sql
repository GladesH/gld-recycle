CREATE TABLE IF NOT EXISTS `recycling_progress` (
   `citizenid` varchar(50) NOT NULL PRIMARY KEY,
   `level` int(11) NOT NULL DEFAULT 0,
   `xp` int(11) NOT NULL DEFAULT 0,
   `daily_recycles` int(11) NOT NULL DEFAULT 0,
   `last_reset` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;