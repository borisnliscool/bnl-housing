CREATE TABLE `bnl_housing` ( 
    `id` INT NOT NULL AUTO_INCREMENT , 
    `owner` VARCHAR(64) NOT NULL , 
    `key_owners` LONGTEXT NOT NULL DEFAULT '{}' , 
    `entrance` LONGTEXT NOT NULL DEFAULT '{}' , 
    `shell_id` INT NOT NULL DEFAULT '1' , 
    `for_sale` LONGTEXT NOT NULL DEFAULT '{}' , 
    `decoration` LONGTEXT NOT NULL DEFAULT '{}' , 
    `vehicles` LONGTEXT NOT NULL DEFAULT '{}' , 
    PRIMARY KEY (`id`)
) ENGINE = InnoDB;