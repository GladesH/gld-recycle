CREATE TABLE IF NOT EXISTS `recycling_progress` (
    `identifier` VARCHAR(50) PRIMARY KEY,
    `level` INT DEFAULT 0,
    `xp` INT DEFAULT 0,
    `daily_recycles` INT DEFAULT 0,
    `last_reset` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;