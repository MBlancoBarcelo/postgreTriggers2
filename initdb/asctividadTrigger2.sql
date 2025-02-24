CREATE TABLE producte(
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255),
    stock INT
);

CREATE TABLE comanda(
    id SERIAL PRIMARY KEY,
    data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE linea_comanda(
    id_producte INT REFERENCES producte(id),
    id_comanda INT REFERENCES comanda(id),
    quantitat INT CHECK(quantitat >= 0)
);

--INSERTS

INSERT INTO producte(nom, stock) VALUES('X', 10);
INSERT INTO producte(nom, stock) VALUES('Y', 8);

INSERT INTO comanda DEFAULT VALUES;
INSERT INTO comanda DEFAULT VALUES;


--FUNCTIONS

CREATE FUNCTION nueva_linea_comanda() RETURNS TRIGGER AS $$ BEGIN
    IF (SELECT stock FROM producte WHERE id = NEW.id_producte) < NEW.quantitat THEN
        RAISE EXCEPTION 'Not enough stock';
        END IF;
    UPDATE producte SET stock = stock - NEW.quantitat WHERE id = NEW.id_producte;
    RETURN NEW;
    END; $$ LANGUAGE plpgsql;

CREATE FUNCTION quitar_linea_comanda() RETURNS TRIGGER AS $$ BEGIN
    UPDATE producte SET stock = stock + OLD.quantitat WHERE id = OLD.id_producte;
    RETURN OLD;
    END; $$ LANGUAGE plpgsql;

CREATE FUNCTION cambiar_linea_comanda() RETURNS TRIGGER AS $$ BEGIN
    UPDATE producte SET stock = stock + OLD.quantitat WHERE id = OLD.id_producte;
    UPDATE producte SET stock = stock - NEW.quantitat WHERE id = NEW.id_producte;
    RETURN NEW;
    END; $$ LANGUAGE plpgsql;

--TRIGGERS

CREATE TRIGGER nueva_linea_comandaTRIGGER BEFORE INSERT ON linea_comanda FOR EACH ROW EXECUTE FUNCTION nueva_linea_comanda();
CREATE TRIGGER quitar_linea_comandaTRIGGER BEFORE DELETE ON linea_comanda FOR EACH ROW EXECUTE FUNCTION quitar_linea_comanda();
CREATE TRIGGER cambiar_linea_comandaTRIGGER BEFORE UPDATE ON linea_comanda FOR EACH ROW EXECUTE FUNCTION cambiar_linea_comanda();
