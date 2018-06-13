
CREATE OR REPLACE VIEW vw_supplies AS 
SELECT suppliers.supplier_id, suppliers.org_id, suppliers.supplier_name, suppliers.supplier_phone, suppliers.supplier_address, 
	suppliers.details, 
	supplies.supplies_id, supplies.product_categories_id, supplies.quantity, supplies.date, 
	productcategories.product_categorie_name,
	product_units.product_unit_id,product_units.product_unit_name, supplies.price_per_unit,(supplies.quantity * supplies.price_per_unit) AS total_price
FROM productcategories 
	INNER JOIN supplies ON productcategories.product_categories_id = supplies.product_categories_id
	INNER JOIN suppliers ON suppliers.supplier_id = supplies.supplier_id
	INNER JOIN product_units ON productcategories.product_unit_id = product_units.product_unit_id;


CREATE OR REPLACE VIEW vw_employees  AS
SELECT employees.employee_id, employees.org_id, employees.employee_name, employees.employee_gender,
   employees.employee_age, employees.employee_phone, employees.employee_email, employees.employee_address,
   employees.work_type_id, employees.employee_start_date,
   employees.employee_end_date, worktype.work_type_name, employees.employee_status
FROM employees
   LEFT JOIN worktype ON worktype.work_type_id = employees.work_type_id;


CREATE OR REPLACE VIEW vw_customerorder AS 
SELECT customers.customer_id, customers.org_id, customers.customer_name, customers.phone_no, 
       customers.email,customers.order_type_id, customers.details, ordertype.order_type_name
FROM ordertype 
    INNER JOIN customers ON ordertype.order_type_id = customers.order_type_id;


CREATE OR REPLACE VIEW vw_food AS
SELECT food.food_id, food.org_id, food.food_category_id, food.food_name, food.details, food_categories.food_category_name
FROM food_categories 
	INNER JOIN food ON food_categories.food_category_id = food.food_category_id;


CREATE OR REPLACE VIEW vw_ingredients AS
SELECT ingredients.ingeredient_id, ingredients.org_id, ingredients.ingredient_name, ingredients.food_id, ingredients.quantity,
	   ingredients.narrative, food.food_name
FROM food 
	INNER JOIN ingredients ON food.food_id = ingredients.food_id;

CREATE OR REPLACE VIEW vw_menus AS 
SELECT menus.menu_id, menus.org_id, menus.food_id, menus.price, vw_food.food_name,
       vw_food.food_category_name, menus.status
FROM menus
	INNER JOIN vw_food ON vw_food.food_id=menus.food_id;


CREATE OR REPLACE VIEW vw_orderfood AS 
SELECT orderfood.order_id, orderfood.org_id, orderfood.customer_id, orderfood.menu_id, orderfood.order_type_id, 
       orderfood.order_date, orderfood.cancel_order, orderfood.quantity, orderfood.table_no, orderfood.employee_id, 
	   orderfood.food_id, vw_menus.food_category_name, vw_menus.food_name, vw_menus.price, vw_menus.status, 
       vw_employees.employee_name, vw_employees.employee_phone, vw_employees.work_type_name, customers.customer_name, 
       customers.phone_no, ordertype.order_type_name, (orderfood.quantity * vw_menus.price) AS total
FROM orderfood  
	 INNER JOIN vw_menus ON vw_menus.menu_id = orderfood.menu_id
 	 INNER JOIN  vw_employees ON vw_employees.employee_id = orderfood.employee_id
  	 INNER JOIN customers ON customers.customer_id = orderfood.customer_id
  	 INNER JOIN ordertype ON ordertype.order_type_id = orderfood.order_type_id;

CREATE OR REPLACE VIEW vw_cart AS
SELECT cart.cart_id, cart.org_id, cart.customer_id, cart.order_id, cart.order_type_id, cart.food_id, cart.menu_id, cart.check_out, 
        customers.customer_name, customers.phone_no, food.food_name, ordertype.order_type_name, menus.price,
		 employees.employee_name,employees.employee_status

FROM cart

	LEFT JOIN customers ON customers.customer_id= cart.customer_id  
	LEFT JOIN food ON food.food_id= cart.food_id
	LEFT JOIN menus ON menus.menu_id=cart.menu_id
	LEFT JOIN employees ON employees.employee_id=cart.employee_id
	LEFT JOIN ordertype ON ordertype.order_type_id=cart.order_type_id;


