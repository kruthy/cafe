insert into food (food_name, products_used, product_name) values ('skuma', 'skuma','vegetables');
insert into food (food_name, products_used, product_name) values ('ugali', 'flour','charbohydrates');
insert into food (food_name, products_used, product_name) values ('tea', 'milk','drinks');

select food_name,products_used,product_name from food;

                 


insert into menu(food_id, price, status) values (2,250,'f');
insert into menu(food_id, price, status) values (2,250,'f');
insert into menu(food_id, price, status) values (2,250,'f');

select food_id,price,status from menu;


insert into customer(customer_name,customer_phoneno,customer_email,customer_address,user_name,user_password,user_photo ) values ('John',0720435677, 'johntu@ueab.ac.ke','3400 eldoret','jhn',1234, '');
insert into customer(customer_name,customer_phoneno,customer_email,customer_address,user_name,user_password,user_photo ) values ('charles',0725225640, 'charles@ueab.ac.ke','3400 eldoret','charl',4564,'');
insert into customer(customer_name,customer_phoneno,customer_email,customer_address,user_name,user_password,user_photo ) values ('Ann',0710578389, 'annu@ueab.ac.ke','500 eldoret','annu',5678, '');

select customer_name,customer_phoneno,customer_email,customer_address,user_name,user_password,user_photo  from customer;


insert into work_type(work_type_name) values ('cashier');
insert into work_type( work_type_name) values ('dishwasher');
insert into work_type ( work_type_name) values ('cook');

select work_type_name from work_type;


insert into employee(employee_name,employee_id , employee_phoneno ,employee_email, employee_gender,employee_age, employee_photo ,employee_user_name,employee_user_password,start_date,exit_date,employee_work_type) values ('ruth' ,3453, 0703343045, 'ruth@ueab.ac.ke', 'female', 22, '' , 'ruthy' , 12345 , 2017 , 2022 , 2);
insert into employee(employee_name,employee_id , employee_phoneno ,employee_email, employee_gender,employee_age, employee_photo ,employee_user_name,employee_user_password,start_date,exit_date,employee_work_type) values ('fabian',1022,072345534,'kilui@ueab.ac.ke','male',25,'','kiluii',12345,2017,2022,2);
insert into employee(employee_name,employee_id , employee_phoneno ,employee_email, employee_gender,employee_age, employee_photo ,employee_user_name,employee_user_password,start_date,exit_date,employee_work_type) values ('vyvy',4040,0715435422,'vy@ueab.ac.ke','female',27,'','ruthy',7389,2017,2022,2);

select employee_name,employee_id , employee_phoneno ,employee_email, employee_gender,employee_age, employee_photo ,employee_user_name,employee_user_password,start_date,exit_date,employee_work_type from employee;

INSERT INTO orderf(customer_id, customer_name, ordet_date, order_type,
table_no, cancel_order, quantity, menu_n) values (2, 'john', '2011-05-16 15:36:38', 1, 4, 'f', 1, 2); 
INSERT INTO orderf(customer_id, customer_name, ordet_date, order_type,
table_no, cancel_order, quantity, menu_n) values (3, 'charles', '2011-05-16 15:36:38', 1, 4, 'f', 1, 2); 
INSERT INTO orderf(customer_id, customer_name, ordet_date, order_type,
table_no, cancel_order, quantity, menu_n) values (4, 'ann', '2011-05-16 15:36:38', 1, 4, 'f', 2, 2); 

SELECT customer_id, customer_name, ordet_date, order_type,
table_no, cancel_order, quantity, menu_n from orderf;

SELECT customer.customer_id, customer.customer_name, ordet_date, order_type,
table_no, cancel_order, quantity, menu_n 
FROM orderf
INNER JOIN customer ON customer.customer_id= orderf.customer_id;


INSERT INTO ordertype (order_type_name) values ('delivery');
select order_type_name from ordertype;


INSERT INTO cart (order_id, checkout) values (2, 'f');
INSERT INTO cart (order_id, checkout) values (1, 't');
select order_id, checkout from cart;














               