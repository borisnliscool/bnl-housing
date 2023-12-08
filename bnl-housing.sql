CREATE TABLE IF NOT EXISTS properties (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    model VARCHAR(16) NOT NULL,
    entrance_location JSON NOT NULL,
    property_type ENUM("house", "warehouse", "office", "garage") NOT NULL,
    zipcode VARCHAR(128),
    street_name VARCHAR(128),
    building_number VARCHAR(16),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_property_address UNIQUE (zipcode, street_name, building_number)
);

CREATE TABLE IF NOT EXISTS property_key (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    property_id INT NOT NULL,
    player VARCHAR(128) NOT NULL,
    permission ENUM("owner", "member", "renter") NOT NULL,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
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
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id)
);

CREATE TABLE IF NOT EXISTS property_player (
    property_id INT NOT NULL,
    player VARCHAR(128) NOT NULL UNIQUE,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id),
    INDEX idx_player (player)
);

CREATE TABLE IF NOT EXISTS property_link (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    property_id INT NOT NULL,
    linked_property_id INT NOT NULL,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY (linked_property_id) REFERENCES properties(id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id),
    INDEX idx_linked_property_id (linked_property_id)
);

CREATE TABLE IF NOT EXISTS property_vehicle (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    property_id INT NOT NULL,
    slot INT NOT NULL,
    props JSON NOT NULL,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id),
    CONSTRAINT uk_property_vehicle UNIQUE (property_id, slot)
);

CREATE TABLE IF NOT EXISTS property_transaction (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    property_id INT NOT NULL,
    transaction_type ENUM("sale", "rental") NOT NULL,
    customer VARCHAR(128),
    price INT NOT NULL,
    start_date TIMESTAMP,
    status ENUM("completed", "uncompleted") DEFAULT 'uncompleted' NOT NULL,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id),
    INDEX idx_customer (customer)
);

CREATE TABLE IF NOT EXISTS property_payments (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    player VARCHAR(128) NOT NULL,
    property_id INT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount INT NOT NULL,
    payment_type ENUM("sale", "rental") NOT NULL,
    payment_interval VARCHAR(16),
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id),
    INDEX idx_payment_date (payment_date)
);