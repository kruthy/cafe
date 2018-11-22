-----------function file

---------after customer inserts Trigger to ctreate login credentials

CREATE OR REPLACE FUNCTION aft_customers() RETURNS trigger AS $$
DECLARE
	v_entity_type_id	integer;
	v_entity_id		integer;
	v_user_name	           varchar(25);

BEGIN
	IF((TG_OP = 'INSERT'))THEN
		SELECT entity_type_id INTO v_entity_type_id
		FROM entity_types 
		WHERE (org_id = NEW.org_id) AND (use_key_id = 6);
		v_entity_id := nextval('entitys_entity_id_seq');
		v_user_name := 'OR'   || NEW.org_id || 'NT' ||  v_entity_id;
		
		INSERT INTO entitys (entity_id, org_id, use_key_id, entity_type_id, entity_name, user_name, primary_email, primary_telephone, function_role)
		VALUES (v_entity_id,  NEW.org_id,  6,  v_entity_type_id,  NEW.customer_name,  v_user_name, lower(trim(NEW.email)), NEW.phone_no  , 'customer');
	END IF;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER aft_customers AFTER INSERT OR UPDATE ON customers
	FOR EACH ROW EXECUTE PROCEDURE aft_customers();



---------------------after employee inserts Trigger to create login credentials
CREATE OR REPLACE FUNCTION aft_employees() RETURNS trigger AS $$
DECLARE
	v_entity_type_id	integer;
	v_entity_id		integer;
	v_user_name	           varchar(25);

BEGIN
	IF((TG_OP = 'INSERT'))THEN
		SELECT entity_type_id INTO v_entity_type_id
		FROM entity_types 
		WHERE (org_id = NEW.org_id) AND (use_key_id = 7);
		v_entity_id := nextval('entitys_entity_id_seq');
		v_user_name := 'OR'   || NEW.org_id || 'NT' ||  v_entity_id;
		
		INSERT INTO entitys (entity_id, org_id, use_key_id, entity_type_id, entity_name, user_name, primary_email, primary_telephone, function_role)
		VALUES (v_entity_id,  NEW.org_id,  7,  v_entity_type_id,  NEW.employee_name ,  v_user_name, lower(trim(NEW.employee_email )), NEW.employee_phone  , 'employee');
	END IF;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER aft_employees AFTER INSERT OR UPDATE ON employees
	FOR EACH ROW EXECUTE PROCEDURE aft_employees();









	
