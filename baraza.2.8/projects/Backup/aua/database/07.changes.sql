

ALTER TABLE students
---DROP 	admission_basis,
ADD		children_number		integer, 
ADD		Spouse_name			varchar(120), 
ADD		Spouse_education	varchar(240),
ADD		Present_work		varchar(240),
ADD		old_town			varchar(50);

UPDATE students SET old_town = town;
ALTER TABLE students DROP 	town;
ALTER TABLE students ADD	town		varchar(100);
UPDATE students SET  town = old_town;
ALTER TABLE students DROP 	old_town;

ALTER TABLE student_degrees
ADD 	admission_basis		varchar(240),
ADD		center_id			varchar(12) references centers;
CREATE INDEX student_degrees_center_id ON student_degrees (center_id);

ALTER TABLE scourses
ADD	old_scourse_id	varchar(16);

ALTER TABLE scourses
ADD	center_id		varchar(12) references centers;
CREATE INDEX scourses_center_id ON scourses (center_id);

---SELECT setval('studentdegrees_studentdegreeid_seq', 151);
---SELECT setval('studentmajors_studentmajorid_seq', 181);
ALTER TABLE scourses DROP CONSTRAINT scourses_instructor_id_key;

CREATE OR REPLACE FUNCTION getDataValue(varchar(16), varchar(16)) RETURNS varchar(240) AS $$
	SELECT trim(data_value) 
	FROM old_data_values
	WHERE (id_data = $1) AND (id_people = $2);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getCountryID(varchar(240)) RETURNS char(2) AS $$
	SELECT sys_country_id
	FROM sys_countrys
	WHERE (trim(lower(sys_country_name)) = trim(lower($1)));
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getCenterID(varchar(240)) RETURNS char(16) AS $$
	SELECT max(name_short)
	FROM old_centers
	WHERE id_center = $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getstudentdegreeid(varchar(12)) RETURNS integer AS $$
    SELECT max(student_degree_id) FROM student_degrees WHERE (student_id = $1);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getInstructorID(varchar(240)) RETURNS char(16) AS $$
	SELECT instructors.instructor_id
	FROM instructors INNER JOIN old_teachers ON trim(lower(old_teachers.family_name || ', ' || old_teachers.first_name)) = trim(lower(instructors.instructorname))
	WHERE (old_teachers.id_people = $1);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getSresidentid(varchar(12)) RETURNS int AS $$
	SELECT max(sresidences.sresidence_id) 
	FROM sresidences INNER JOIN sessions ON sresidences.session_id =sessions.session_id 
	WHERE (sresidences.residence_id = $1) AND (sessions.active = true);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getSresidentid(varchar(12), varchar(12)) RETURNS int AS $$
	SELECT max(sresidence_id) 
	FROM sresidences 
	WHERE (residence_id = $1) AND (session_id  = $2);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getsstudentid(varchar(12)) RETURNS int AS $$
	SELECT max(sstudents.sstudent_id) 
	FROM (student_degrees INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id)
		INNER JOIN sessions ON sstudents.session_id = sessions.session_id
	WHERE (student_degrees.studentid = $1) AND (sessions.active = true);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getsstudentid(varchar(12), varchar(12)) RETURNS int AS $$
	SELECT max(sstudents.sstudent_id) 
	FROM student_degrees INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id
	WHERE (student_degrees.studentid = $1) AND (sstudents.session_id = $2);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION insScourses() RETURNS trigger AS $$
BEGIN
	NEW.course_title := getcoursetitle(NEW.course_id);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insScourses BEFORE INSERT ON scourses
    FOR EACH ROW EXECUTE PROCEDURE insScourses();

CREATE OR REPLACE FUNCTION updScourses() RETURNS trigger AS $$
BEGIN
	IF (OLD.course_id <> NEW.course_id) THEN
		NEW.course_title := getcoursetitle(NEW.course_id);
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER updScourses BEFORE UPDATE ON scourses
    FOR EACH ROW EXECUTE PROCEDURE updScourses();

CREATE OR REPLACE FUNCTION getcoursetitle(varchar(12)) RETURNS varchar(50) AS $$
	SELECT MAX(course_title) FROM courses WHERE (course_id = $1);
$$ LANGUAGE SQL;

