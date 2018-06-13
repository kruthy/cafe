UPDATE students 
SET school_id=departments.school_id
FROM departments
WHERE students.department_id=departments.department_id;
