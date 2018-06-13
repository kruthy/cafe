---Project Database File

CREATE TABLE suppliers(
	supplier_id       serial primary key,
	org_id			  integer references orgs,
	supplier_name     varchar(50),
	supplier_phone    integer NOT NULL,
	supplier_email    varchar(30)  NOT NULL,
	supplier_address  varchar(60)  NOT NULL,
    details            text
);
	CREATE INDEX suppliers_org_id ON suppliers(org_id);

 CREATE TABLE product_units(
	product_unit_id       serial primary key,
	org_id                integer references orgs,
	product_unit_name     varchar(50) NOT NULL,
	details               text
);
		CREATE INDEX product_units_org_id ON product_units(org_id);

CREATE TABLE productcategories(
	product_categories_id   serial primary key,
	org_id                  integer references orgs,
    product_unit_id        integer references product_units,
	product_categorie_name	varchar(100) NOT NULL,
	details                 text
);
	CREATE INDEX productcategories_org_id ON productcategories(org_id);
    CREATE INDEX productcategories_product_unit_id ON productcategories(product_unit_id);



CREATE TABLE supplies(
	supplies_id         	serial primary key,
	org_id 					integer references orgs,
	supplier_id		    	integer references suppliers,
	product_categories_id   integer references productcategories,
	quantity            	integer NOT NULL,
	date                	date,
	details					text
);
	CREATE INDEX suplies_org_id ON supplies(org_id);
	CREATE INDEX supplies_supplier_id ON supplies(supplier_id);
	CREATE INDEX supplies_productcategories_id ON supplies(product_categories_id);

ALTER TABLE supplies ADD COLUMN price_per_unit real DEFAULT 0 NOT NULL;



CREATE TABLE food_categories(
	food_category_id		serial primary key,
	org_id					integer references orgs,
	food_category_name		varchar(80) NOT NULL,
	food_narrative			varchar(250), 
	details					text
);
CREATE INDEX food_categories_org_id ON food_categories(org_id);




CREATE TABLE food(
	food_id		    serial primary key, 
    org_id          integer references orgs,
	food_category_id integer references food_categories,
	food_name 	    varchar(120) not null,
	details         text
);
	CREATE INDEX food_org_id ON food(org_id);
	CREATE INDEX food_food_category_id ON food(food_category_id);


CREATE TABLE ingredients (
	ingeredient_id   	serial primary key,
    org_id     		 	integer references orgs,
	ingredient_name   	varchar(120) NOT NULL,
	food_id				integer references food,
	quantity		  	float,
	narrative			varchar(250),
	details         	text
);
	CREATE INDEX ingredients_org_id ON ingredients(org_id);
	CREATE INDEX ingredients_food_id ON ingredients(food_id);


CREATE TABLE menus(
	menu_id         serial primary key,
	org_id          integer references orgs,
	food_id         integer  references food,
	price           real,
	status          boolean NOT NULL,
	details   		text
);
	CREATE INDEX menus_org_id ON menus(org_id);
	CREATE INDEX menus_food_id ON menus(food_id);

CREATE TABLE ordertype(                                              
	order_type_id     serial primary key,
	org_id            integer references orgs,
	order_type_name   varchar(50) NOT NULL,
	details           text
);
CREATE INDEX ordertype_org_id  ON ordertype(org_id);


CREATE TABLE customers(
	customer_id         serial primary key,
	org_id				integer references orgs,
	customer_name       varchar(60) NOT NULL,
	phone_no             varchar(12) NOT NULL,
	email                varchar(60) NOT NULL,
	order_type_id       integer references ordertype,
	details				text
);
	CREATE INDEX customers_org_id ON customers(org_id);
	CREATE INDEX customers_order_type_id ON customers(order_type_id);



CREATE TABLE worktype(
	work_type_id   serial primary key,
	org_id         integer references orgs,
	work_type_name  varchar(70) NOT NULL
);
	CREATE INDEX worktype_org_id ON worktype(org_id);


CREATE TABLE employees(
	employee_id             serial primary key,
	org_id			        integer references orgs,
	employee_name           varchar(50) NOT NULL,
	employee_gender         varchar(50) NOT NULL,
	employee_age            integer NOT NULL,
	employee_phone          varchar(12) NOT NULL,
	employee_email          varchar(60) NOT NULL,
	employee_address        varchar(70) NOT NULL,
	work_type_id            integer references worktype,
	employee_start_date     date,
    employee_end_date       date,
	employee_status			boolean
);
	CREATE INDEX employees_org_id ON employees(org_id);
	CREATE INDEX employees_work_type_id ON employees(work_type_id);





CREATE TABLE orderfood(
	order_id        serial primary key,
	org_id          integer references orgs,
	customer_id     integer  references customers,
	menu_id         integer   references menus,
	order_type_id   integer references ordertype,
	order_date      date,
	cancel_order    boolean,
	quantity        float,
	table_no		varchar(15),
	employee_id     integer references employees,
	food_id         integer references food
);
	CREATE INDEX   orderfood_org_id ON orderfood(org_id);
	CREATE INDEX   orderfood_customer_id ON orderfood(customer_id);
	CREATE INDEX   orderfood_menu_id  ON  orderfood(menu_id);
	CREATE INDEX   orderfood_employee_id ON orderfood(employee_id);
	CREATE INDEX   orderfood_food_id ON orderfood(food_id);





CREATE TABLE cart(
	cart_id			serial primary key,
	org_id			integer references orgs,
	customer_id     integer references customers,
	employee_id 	integer references employees,
	order_id        integer references orderfood,
	order_type_id	integer references ordertype,
	food_id			integer references food,
	menu_id			integer references menus,
	check_out		boolean
);
 	CREATE INDEX   cart_org_id ON cart(org_id);
	CREATE INDEX   cart_order_id  ON cart(order_id);
	CREATE INDEX   cart_menu_id  ON cart(menu_id);
	CREATE INDEX   cart_order_type_id ON cart(order_type_id);
	CREATE INDEX   cart_customer_id ON cart(customer_id);
	CREATE INDEX   cart_employee_id ON cart(employee_id);




