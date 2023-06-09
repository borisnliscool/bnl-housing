CREATE TABLE IF NOT EXISTS properties (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    model VARCHAR(16) NOT NULL,
    entrance_location JSON NOT NULL,
    property_type ENUM("house", "warehouse", "office") NOT NULL,
    zipcode VARCHAR(128),
    street_name VARCHAR(128),
    building_number FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_property_address UNIQUE (zipcode, street_name, building_number)
);

CREATE TABLE IF NOT EXISTS property_key (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    property_id INT NOT NULL,
    player VARCHAR(128) NOT NULL,
    permission ENUM("owner", "member", "renter") NOT NULL,
    FOREIGN KEY (property_id) REFERENCES properties(id),
    FOREIGN KEY (player) REFERENCES users(identifier),
    INDEX idx_property_id (property_id),
    INDEX idx_player (player),
    CONSTRAINT uk_property_key UNIQUE (property_id, player)
);

CREATE TABLE IF NOT EXISTS property_prop (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    property_id INT NOT NULL,
    model VARCHAR(32) NOT NULL,
    location JSON NOT NULL,
    rotation JSON NOT NULL,
    metadata JSON NOT NULL DEFAULT "{}",
    FOREIGN KEY (property_id) REFERENCES properties(id),
    INDEX idx_property_id (property_id)
);