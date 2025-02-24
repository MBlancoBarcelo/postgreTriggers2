CREATE TABLE Product(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    stock INT
)

CREATE TABLE Order(
    id SERIAL PRIMARY KEY,
    data DATETIME DEFAULT CURRENT_TIMESTAMP
)

CREATE TABLE OrderDetail(
    id_Order INT REFERENCES ON Order(id),
    id_Product INT REFERENCES ON Product(id),
    quantity INT CHECK(quantity >= 0)
)

--FUNCTIONS

CREATE FUNCTION moreOrderDetail() RETURNS TRIGGER AS $$ BEGIN
    IF (SELECT stock FROM Product WHERE id = NEW.id_Product < NEW.quantity) THEN
        RAISE EXCEPTION 'Not enough stock';
        END IF;
    UPDATE Product SET stock = stock - NEW.quantity WHERE id = NEW.id_Product
    RETURN NEW;
    END; $$ LANGUAGE plpgsql;

CREATE FUNCTION lessOrderDetail() RETURNS TRIGGER AS $$ BEGIN
    UPDATE Product SET stock = stock + OLD.quantity WHERE id = OLD.id_Product
    RETURN OLD;
    END; $$ LANGUAGE plpgsql;

CREATE FUNCTION updateOrderDetail() RETURNS TRIGGER AS $$ BEGIN
    UPDATE Product SET stock = stock + OLD.quantity WHERE id = OLD.id_Product
    UPDATE Product SET stock = stock - NEW.quantity WHERE id = NEW.id_Product
    RETURN NEW;
    END; $$ LANGUAGE plpgsql;

--TRIGGERS



