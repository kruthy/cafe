CREATE VIEW vw_employees_work_types AS 
SELECT employee_name, employee_id , employee_phoneno ,employee_email, employee_gender, employee_age, 
employee_photo, employee_user_name, employee_user_password, start_date, exit_date, work_type_name, work_type.work_type_id
FROM employee
INNER JOIN work_type ON work_type.work_type_id=employee.work_type_id;

select *from vw_employees_work_types

select *from customer
