INSERT INTO use_keys (use_key_id, use_key_name, use_function) VALUES
(6, 'customers' , 0),
(7, 'employees', 0);

--- Entity types
INSERT INTO entity_types (org_id, entity_type_name, entity_role, use_key_id) VALUES 
(0, 'customers', 'customers', 6),
(0, 'employees', 'employees', 7);



INSERT INTO suppliers(org_id,supplier_name,supplier_phone,supplier_email,supplier_address) VALUES (0,'Peter', 0700878675,'peter@me.com','2500 Eldoret');
INSERT INTO suppliers(org_id,supplier_name,supplier_phone,supplier_email,supplier_address) VALUES (0,'Vivian', 0723263784,'vyvy@yahoo.com','5010 Kapsabet');
INSERT INTO suppliers(org_id,supplier_name,supplier_phone,supplier_email,supplier_address) VALUES (0,'Raven', 0785674654,'raven@gmail.com','30100 Kericho');
INSERT INTO suppliers(org_id,supplier_name,supplier_phone,supplier_email,supplier_address) VALUES (0,'Cate', 0756746534,'cate@hotmail.com','500 Nairobi');
INSERT INTO suppliers(org_id,supplier_name,supplier_phone,supplier_email,supplier_address) VALUES (0,'Charles', 0753234543,'charles@hotlook.com','00 Kissi');


INSERT INTO product_units(org_id,product_unit_name) VALUES (0, 'bag');
INSERT INTO product_units(org_id,product_unit_name) VALUES (0, 'basket');
INSERT INTO product_units(org_id,product_unit_name) VALUES (0, 'crate/tray');
INSERT INTO product_units(org_id,product_unit_name) VALUES (0, 'bundle');
INSERT INTO product_units(org_id,product_unit_name) VALUES (0, 'carton');


INSERT INTO food_categories(org_id,food_category_name) VALUES (0,'Main Dish');
INSERT INTO food_categories(org_id,food_category_name) VALUES (0,'Bevarages');
INSERT INTO food_categories(org_id,food_category_name) VALUES (0,'Salad');
INSERT INTO food_categories(org_id,food_category_name) VALUES (0,'Dessert');
INSERT INTO food_categories(org_id,food_category_name) VALUES (0,'Side Dish');

INSERT INTO ordertype(org_id,order_type_name) VALUES (0,'Delivery');
INSERT INTO ordertype(org_id,order_type_name) VALUES (0,'By Server');

INSERT INTO customers (org_id, customer_name, phone_no,email) VALUES (0,'Jane','0700675643','jane@gmail.com');
INSERT INTO customers (org_id, customer_name, phone_no,email) VALUES (0,'Vivian','0734565544','vivian@gmail.com');
INSERT INTO customers (org_id, customer_name, phone_no,email) VALUES (0,'Kamande','0755676543','kamande66@gmail.com');
INSERT INTO customers (org_id, customer_name, phone_no,email) VALUES (0,'Wekesa','0713241234','wekesa@yahoo.com');
INSERT INTO customers (org_id, customer_name, phone_no,email) VALUES (0,'Cate','0756432314','cate@gmail.com');

INSERT INTO worktype(org_id,work_type_name) VALUES (0,'cashier');
INSERT INTO worktype(org_id,work_type_name) VALUES (0,'dishwasher');
INSERT INTO worktype(org_id,work_type_name) VALUES (0,'cook');
INSERT INTO worktype(org_id,work_type_name) VALUES (0,'Server');
INSERT INTO worktype(org_id,work_type_name) VALUES (0,'Manager');


















               
