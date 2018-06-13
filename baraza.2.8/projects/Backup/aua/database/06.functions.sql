CREATE OR REPLACE FUNCTION ins_new_student(integer) RETURNS varchar(50) AS $$
DECLARE
	myrec RECORD;
	priadd RECORD;
	gudadd RECORD;
	id_count RECORD;
	myqtr RECORD;
	base_id VARCHAR(12);
	new_id VARCHAR(12);
	full_name VARCHAR(50);
	gen_first_pass VARCHAR(32);
	gen_student_pass VARCHAR(32);
BEGIN
	SELECT INTO myrec departments.school_id, registrations.denomination_id, registrations.registration_id,
		registrations.last_name, registrations.middle_name, registrations.first_name,
		registrations.sex, registrations.nationality_id, registrations.marital_status,
		registrations.birth_date, registrations.existing_id, registrations.degree_id, registrations.sub_level_id,
		registrations.major_id, registrations.pre_major
	FROM (departments INNER JOIN majors ON departments.department_id = majors.department_id)
	INNER JOIN registrations ON majors.major_id = registrations.major_id
	WHERE (registrations.registration_id=$1);

	SELECT INTO priadd reg_contacts.address, reg_contacts.zipcode, reg_contacts.town, reg_contacts.country_code_id,
		reg_contacts.telephone, reg_contacts.email
	FROM contact_types INNER JOIN reg_contacts ON contact_types.contact_type_id = reg_contacts.contact_type_id
	WHERE (contact_types.primary_contact = true) AND (reg_contacts.registration_id=$1);

	SELECT INTO gudadd reg_contacts.reg_contact_name, reg_contacts.address, reg_contacts.zipcode, reg_contacts.town,
		reg_contacts.country_code_id, reg_contacts.telephone, reg_contacts.email
	FROM reg_contacts
	WHERE (reg_contacts.guardian_contact = true) AND (reg_contacts.registration_id=$1);

	SELECT INTO myqtr session_id FROM sessions WHERE active = true;

	base_id := upper('S' || substring(trim(myrec.last_name) from 1 for 3) || substring(trim(myrec.first_name) from 1 for 2) || substring(myqtr.session_id from 8 for 2) || substring(myqtr.session_id from 11 for 1));

	SELECT INTO id_count count(student_id) as base_id_count
	FROM students
	WHERE substring(student_id from 1 for 9) = base_id;

	new_id := base_id || (id_count.base_id_count + 1);

	IF (myrec.middle_name IS NULL) THEN
		full_name := upper(trim(myrec.last_name)) || ', ' || upper(trim(myrec.first_name));
	ELSE
		full_name := upper(trim(myrec.last_name)) || ', ' || upper(trim(myrec.middle_name)) || ' ' || upper(trim(myrec.first_name));
	END IF;
	
	gen_first_pass := first_passwd();
	gen_student_pass := md5(gen_first_pass);

	IF myrec.existing_id IS NULL THEN
		INSERT INTO students (student_id, account_number, student_name, school_id, denomination_id, Sex, Nationality,
			marital_status, birth_date, first_pass, student_pass, address, zipcode, town, country_code_id, telno, email,
			guardian_name, gaddress, gzipcode, gtown, gcountry_code_id, gtelno, gemail)
		VALUES (new_id, new_id, full_name, myrec.school_id, myrec.denomination_id, myrec.Sex, myrec.nationality_id,
			myrec.marital_status, myrec.birth_date, gen_first_pass, gen_student_pass,
			priadd.address, priadd.zipcode, priadd.town, priadd.country_code_id, priadd.telephone, priadd.email,
			gudadd.reg_contact_name, gudadd.address, gudadd.zipcode, gudadd.town, gudadd.country_code_id, gudadd.telephone, gudadd.email);

		INSERT INTO student_degrees (degree_id, sub_level_id, student_id, started, bulletingid)
		VALUES (myrec.degree_id,  myrec.sub_level_id, new_id, current_date, 0);

		INSERT INTO student_majors (student_degree_id, major_id, major, non_degree, pre_major, primary_major)
		VALUES (get_student_degree_id(new_id), myrec.major_id, true, false, myrec.pre_major, true);

		UPDATE registrations SET existing_id = new_id, accepted=true, accepteddate=current_date, first_pass=gen_first_pass  WHERE (registrations.registration_id=$1);
	END IF;

    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ins_student_name() RETURNS trigger AS $$
DECLARE
	myrec RECORD;
	stdnum integer;
BEGIN	
	NEW.student_name := UPPER(NEW.surname)	|| ', ' || UPPER(NEW.first_name) || ' ' || UPPER(COALESCE(NEW.othernames, ''));

	IF (TG_OP = 'INSERT') AND (NEW.student_id is null) THEN
		SELECT max(cast(substring(student_id from 6 for 3) as int)) as stdno INTO myrec
		FROM students
		WHERE substring(student_id from 2 for 4) = to_char(current_timestamp, 'YYYY');

		if(myrec.stdno is null) then
			stdnum := 1;
		else
			stdnum := myrec.stdno + 1;
		end if;

		NEW.student_id := 'S' || to_char(current_timestamp, 'YYYY') || lpad(cast((stdnum) as varchar), 3, '0');
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_student_name BEFORE INSERT OR UPDATE ON students
    FOR EACH ROW EXECUTE PROCEDURE ins_student_name();

CREATE OR REPLACE FUNCTION get_first_session_id(varchar(12)) RETURNS varchar(12) AS $$
	SELECT min(session_id) 
	FROM sstudents INNER JOIN student_degrees ON sstudents.student_degree_id = student_degrees.student_degree_id
	WHERE (student_id = $1);
$$ LANGUAGE SQL;

------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_exam_time_count(integer, date, time, time) RETURNS bigint AS $$
	SELECT count(scourse_id) FROM vw_sexam_timetables
	INNER JOIN sstudents ON sstudents.session_id=vw_sexam_timetables.session_id
	WHERE (sstudent_id = $1) AND (exam_date = $2) AND (((start_time, end_time) OVERLAPS ($3, $4))=true);
$$ LANGUAGE SQL;
---------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_student_degree_id(varchar(12)) RETURNS integer AS $$
    SELECT max(student_degree_id) FROM student_degrees WHERE (student_id = $1);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION gets_student_id(varchar(12)) RETURNS int AS $$
	SELECT max(sstudents.sstudent_id) 
	FROM (student_degrees INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id)
		INNER JOIN sessions ON sstudents.session_id = sessions.session_id
	WHERE (student_degrees.student_id = $1) AND (sessions.active = true);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_sstudent_id(varchar(12), varchar(12)) RETURNS int AS $$
	SELECT max(sstudents.sstudent_id) 
	FROM student_degrees INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id
	WHERE (student_degrees.student_id = $1) AND (sstudents.session_id = $2);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_student_id(varchar(12)) RETURNS varchar(12) AS $$
    SELECT max(student_id) FROM students WHERE (student_id = $1);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_study_level(int) RETURNS int AS $$
	SELECT max(study_level) 
	FROM sstudents
	WHERE (student_degree_id = $1) AND (approved = true);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_Sresident_id(varchar(12)) RETURNS int AS $$
	SELECT max(sresidences.sresidence_id) 
	FROM sresidences INNER JOIN sessions ON sresidences.session_id =sessions.session_id 
	WHERE (sresidences.residence_id = $1) AND (sessions.active = true);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_S_resident_id(varchar(12), varchar(12)) RETURNS int AS $$
	SELECT max(sresidence_id) 
	FROM sresidences 
	WHERE (residence_id = $1) AND (session_id  = $2);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION updBalances() RETURNS varchar(50) AS $$
DECLARE
    myrecord RECORD;
	mysstudent_id int;
BEGIN
	
	FOR myrecord IN SELECT sunimports.balance, students.student_id
		FROM (sun_imports INNER JOIN students ON TRIM(UPPER(sunimports.account_number)) = TRIM(UPPER(students.account_number))) 
		WHERE sunimports.IsUploaded = False
	LOOP
		mysstudent_id = get_sstudent_id(myrecord.student_id);

		IF (mysstudent_id is not null) THEN
			UPDATE sstudents SET currbalance = myrecord.balance WHERE sstudent_id = mysstudent_id;
		ELSE
			UPDATE students SET currentbalance = myrecord.balance WHERE student_id = myrecord.student_id;
		END IF;
	END LOOP;
	
	INSERT INTO audittrail (username, tablename, recordid, changetype, narrative)
	VALUES (current_user, 'sstudents', 'UPLOAD', 'UPLOAD', 'Charges Upload');

	DELETE FROM sunimports;
	
	RETURN 'Done';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION updBankPicked() RETURNS varchar(50) AS $$
BEGIN	
	INSERT INTO banksuspence (entrydate, CustomerReference, session_id, account_number, TransactionAmount, Narrative)
	SELECT vwbankfile.entrydate, vwbankfile.CustomerReference, vwbankfile.session_id,
		vwbankfile.account_number, vwbankfile.TransactionAmount, vwbankfile.Narrative
	FROM vwbankfile LEFT JOIN banksuspence ON vwbankfile.Narrative = banksuspence.Narrative
	WHERE (banksuspence.Narrative is null);
	
	UPDATE student_payments SET approved = true, phistoryid = 0 FROM vwbankfile
	WHERE (student_payments.Narrative = vwbankfile.Narrative) AND (student_payments.approved = false) AND (student_payments.amount = vwbankfile.Transactionamount);
	
	UPDATE student_payments SET approved = true, phistoryid = 0 FROM banksuspence
	WHERE (student_payments.Narrative = banksuspence.TransComments) AND (student_payments.approved = false) AND (student_payments.amount = banksuspence.Transactionamount);
	
	DELETE FROM bankfile;
	
	UPDATE banksuspence SET Approved = true, Approved_date = now()
	FROM student_payments
	WHERE (banksuspence.narrative = student_payments.narrative)
		AND (banksuspence.Approved = false) AND (student_payments.Approved = true);
		
	UPDATE banksuspence SET Approved = true, Approved_date = now()
	FROM student_payments
	WHERE (banksuspence.TransComments = student_payments.narrative)
		AND (banksuspence.Approved = false) AND (student_payments.Approved = true);
		
	INSERT INTO audittrail (username, tablename, recordid, changetype, narrative)
	VALUES (current_user, 'banksuspence', 'RECONSILIATION', 'ETRANZACT', 'Charges Bank Reconsiliation');
	
	RETURN 'Done';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION updBankPicked(varchar(12)) RETURNS varchar(50) AS $$
BEGIN	
	UPDATE student_payments SET Picked = true, Picked_date  = now() FROM sstudents
	WHERE (student_payments.sstudent_id = sstudents.sstudent_id) 
	AND (sstudents.session_id = $1) AND (student_payments.approved = true)
	AND (student_payments.Picked = false);
	
	UPDATE sstudents SET Picked = true, Picked_date  = now(), LRF_Picked = true, LRF_Picked_date  = now()
	WHERE (session_id = $1) AND (finance_approval = true) AND (Picked = false);

	UPDATE scholarships SET posted = true, date_posted = now()
	WHERE (session_id = $1) AND (approved = true) AND (posted = false);
	
	RETURN 'Done';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delBankPicked() RETURNS varchar(50) AS $$
BEGIN
	DELETE FROM Bankrecons;
	RETURN 'Done';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION updOpenFinance(varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	myrec RECORD;
	mystr VARCHAR(120);
BEGIN
	SELECT INTO myrec sstudent_id, finance_approval, finance_closed FROM sstudents
	WHERE (sstudent_id = CAST($2 as int));
	
	IF (myrec.sstudent_id IS NULL) THEN
		mystr := 'You must add the semester first.';
	ELSIF (myrec.finance_approval = true) THEN
		mystr := 'You have been finacially approved, Visit busuary to get your payments opened.';
	ELSE
		UPDATE sstudents SET finance_approval = false, finance_closed = false WHERE sstudent_id = myrec.sstudent_id;
		mystr := 'Your financial application has been opened for adjustments.';
	END IF;
		
	RETURN mystr;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getchargedays(date, date) RETURNS integer AS $$
DECLARE
	cdays integer;
	mydays integer;
BEGIN
	cdays := 0;
	mydays := $2 - $1;
	
	FOR i IN 0..mydays LOOP
		IF not ((date_part('DOW', ($1 + i)) = 0) OR (date_part('DOW', ($1 + i)) = 6)) THEN
			cdays := cdays + 1;
		END IF;
	END LOOP;
	
	RETURN cdays;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ins_sstudent(varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	mystud RECORD;
	myrec RECORD;
	mycourse RECORD;
	mysession RECORD;
	mymajor RECORD;
	mystr VARCHAR(120);
	mydegree_id int;
	creditcount real;
	mycurrqs int;
	mystudy_level int;
	mysresidentid int;
	mylatefees real;
	mycurrbalance real;
	mynarrative VARCHAR(120);
BEGIN
	SELECT INTO mystud onprobation, userpasswd, first_passwd, residence_id, blockname, roomnumber,
		currentbalance, account_number, new_student, seeregistrar
	FROM students
	WHERE (student_id = $1);

	mydegree_id := get_student_degree_id($1);
	mystudy_level := getstudy_level(mydegree_id);
	mysresidentid := getSresidentid(mystud.residence_id);
	
	SELECT INTO mymajor minlevel, maxlevel FROM majors INNER JOIN student_majors ON majors.major_id = student_majors.major_id
	WHERE (student_majors.student_degree_id = mydegree_id);
	
	SELECT INTO myrec sstudent_id FROM sstudents
	WHERE (student_degree_id = mydegree_id) AND (session_id = $2);
	
	SELECT INTO mysession slatereg, slast_drop, late_registration_fee, getchargedays(slatereg, current_date) as late_days,
		late_registration_fee * getchargedays(slatereg, current_date) as late_fees,
		session_id, substring(session_id from 11 for 1) as session
	FROM sessions WHERE (session_id = $2);
	
	IF (mystud.currentbalance IS NOT NULL) THEN
		mycurrbalance := mystud.currentbalance;
	ELSIF (mystud.new_student = true) THEN
		mycurrbalance := 0;
	END IF;

	mylatefees := 0;
	mynarrative := '';
	IF (mysession.late_fees > 0) AND ((mystud.new_student = false) OR (mysession.session != '1')) THEN 
		mylatefees := mysession.late_fees;
		mynarrative := 'Late Registration fees charges for ' || CAST(mysession.late_days as text) || ' days at a rate of ' || CAST(mysession.late_registration_fee as text) || ' Per day.';
	END IF;

	IF (mystudy_level is null) AND (mymajor.minlevel is not null) THEN
		mystudy_level := mymajor.minlevel;
	ELSIF (mystudy_level is null) THEN
		mystudy_level := 100;
	ELSIF (substring($2 from 11 for 1) = '1') THEN
			mystudy_level := mystudy_level + 100;
	END IF;

	IF (mymajor.maxlevel is not null) THEN
		IF (mystudy_level > mymajor.maxlevel) THEN
			mystudy_level := mymajor.maxlevel;
		END IF;
	ELSE
		IF (mystudy_level > 500) THEN
			mystudy_level := 500;
		END IF;
	END IF;

	IF (mysession.slast_drop < current_date) THEN
		mystr := 'The registration is closed for this session.';
	ELSIF (mystud.onprobation = true) THEN
		mystr := 'Student on Probation cannot proceed.';
	ELSIF (mystud.seeregistrar = true) THEN
		mystr := 'Cannot Proceed, See Registars office.';
	ELSIF (mystud.userpasswd = md5(mystud.first_passwd)) THEN
		mystr := 'You must change your password first before proceeding.';
	ELSIF (mystud.account_number IS NULL) THEN
		mystr := 'You must have an account number, contact Finance office.';
	ELSIF (mydegree_id IS NULL) THEN
		mystr := 'No Degree Indicated contact Registrars Office';
	ELSIF (getcoremajor(mydegree_id) IS NULL) THEN
		mystr := 'No Major Indicated contact Registrars Office';
	ELSIF (myrec.sstudent_id IS NULL) THEN
		IF (mysresidentid is null) THEN
			INSERT INTO sstudents(session_id, student_degree_id, study_level, currbalance, charges, financenarrative, paymenttype)
			VALUES ($2, mydegree_id, mystudy_level, mycurrbalance, mylatefees, mynarrative, 1);
		ELSE
			INSERT INTO sstudents(session_id, student_degree_id, study_level, qresidentid, blockname, roomnumber, currbalance, charges, financenarrative, paymenttype)
			VALUES ($2, mydegree_id, mystudy_level, mysresidentid, mystud.blockname, mystud.roomnumber, mycurrbalance, mylatefees, mynarrative, 1);
		END IF;
		
		mycurrqs := get_sstudent_id($1);
		creditcount := 0;
		FOR mycourse IN SELECT year_taken, course_id, min(scourse_id) as scourse_id, max(credit_hours) as credit_hours
			FROM scourse_check_pass
			WHERE (elective = false) AND (coursepased = false) AND (prereqpassed = true)
				AND (year_taken <= (mystudy_level/100)) AND (student_id = $1)
			GROUP BY year_taken, course_id
			ORDER BY year_taken, course_id
		LOOP
			IF (creditcount < 16) THEN
				INSERT INTO sgrades(sstudent_id, scourse_id, hours, credit, approved) 
				VALUES (mycurrqs, mycourse.scourse_id, mycourse.credit_hours, mycourse.credit_hours, true);
				creditcount := creditcount + mycourse.credit_hours;
			END IF;
		END LOOP;
		
		mystr := 'Semester registered confirm course selection and awaiting approval';
	ELSE
		mystr := 'Semester already registered';
	END IF;

    RETURN mystr;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION updSStudent(varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	myrec RECORD;
	mystr VARCHAR(120);
	mycurrqs int;
BEGIN
	mycurrqs := get_sstudent_id($1);
	
	SELECT INTO myrec sstudent_id, finance_closed, finance_approval, mealtype, mealticket
		FROM sstudents WHERE (sstudent_id = mycurrqs);

	IF (myrec.sstudent_id is null) THEN
		mystr := 'Register for the semester first';
	ELSIF (myrec.finance_closed = true) OR (myrec.finance_approval = true) THEN
		mystr := 'You cannot make changes after submiting your payment unless you apply on the post for it to be opened by finance.';
	ELSIF (myrec.mealticket > 0) THEN
			mystr := 'You cannot not change meal selection after getting meal ticket.';
	ELSIF ($2 = '1') THEN
		UPDATE sstudents SET off_campus = true, premiumhall = false, mealtype = 'NONE' WHERE (sstudent_id = mycurrqs);
		mystr := 'Off campus applied, await authorization.';
	ELSIF ($2 = '2') THEN
		UPDATE sstudents SET off_campus = false, premiumhall = false, mealtype = 'BL' WHERE (sstudent_id = mycurrqs);
		mystr := 'Resident Student Taking Breakfast and Lunch';
	ELSIF ($2 = '3') THEN
		UPDATE sstudents SET off_campus = false, premiumhall = false, mealtype = 'BS' WHERE (sstudent_id = mycurrqs);
		mystr := 'Resident Student Taking Breakfast and Supper';
	ELSIF ($2 = '4') THEN
		UPDATE sstudents SET off_campus = false, premiumhall = false, mealtype = 'LS' WHERE (sstudent_id = mycurrqs);
		mystr := 'Resident Student Taking Lunch and Supper';
	ELSIF ($2 = '5') THEN
		UPDATE sstudents SET off_campus = false, premiumhall = false, mealtype = 'BLS' WHERE (sstudent_id = mycurrqs);
		mystr := 'Resident Student Taking Breakfast, Lunch and Supper';
	ELSIF ($2 = '6') THEN
		UPDATE sstudents SET off_campus = false, premiumhall = true, mealtype = 'BL' WHERE (sstudent_id = mycurrqs);
		mystr := 'Premier Hall Resident Student Taking Breakfast and Lunch';
	ELSIF ($2 = '7') THEN
		UPDATE sstudents SET off_campus = false, premiumhall = true, mealtype = 'BS' WHERE (sstudent_id = mycurrqs);
		mystr := 'Premier Hall Resident Student Taking Breakfast and Supper';
	ELSIF ($2 = '8') THEN
		UPDATE sstudents SET off_campus = false, premiumhall = true, mealtype = 'LS' WHERE (sstudent_id = mycurrqs);
		mystr := 'Premier Hall Resident Student Taking Lunch and Supper';
	ELSIF ($2 = '9') THEN
		UPDATE sstudents SET off_campus = false, premiumhall = true, mealtype = 'BLS' WHERE (sstudent_id = mycurrqs);
		mystr := 'Premier Hall Resident Student Taking Breakfast, Lunch and Supper';
	ELSIF ($2 = '10') THEN
		UPDATE sstudents SET paymenttype = 1 WHERE (sstudent_id = mycurrqs);
		mystr := 'Make full payment for the entire session.';
	ELSIF ($2 = '11') THEN
		UPDATE sstudents SET paymenttype = 2 WHERE (sstudent_id = mycurrqs);
		mystr := 'Make full payment for the semester.';
	ELSIF ($2 = '12') THEN
		UPDATE sstudents SET paymenttype = 3 WHERE (sstudent_id = mycurrqs);
		mystr := 'Applied for part payment for the semester.';
	ELSE
		mystr := 'Make Proper selection';
	END IF;

    RETURN mystr;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getcoursehours(int) RETURNS float AS $$
	SELECT courses.credit_hours
	FROM courses INNER JOIN scourses ON courses.course_id = scourses.course_id
	WHERE (scourse_id=$1);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getcoursecredits(int) RETURNS float AS $$
	SELECT (CASE courses.no_gpa WHEN true THEN 0 ELSE courses.credit_hours END)
	FROM courses INNER JOIN scourses ON courses.course_id = scourses.course_id
	WHERE (scourse_id=$1);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION insSCourse(varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	mysrec RECORD;
	myrec RECORD;
	mystr VARCHAR(120);
	mycurrqs int;
BEGIN
	mycurrqs := get_sstudent_id($1);

	SELECT INTO mysrec sstudent_id, finalised, approved FROM sstudents
	WHERE (sstudent_id = mycurrqs);

	SELECT INTO myrec sgrade_id, dropped, approved FROM sgrades
	WHERE (sstudent_id = mycurrqs) AND (scourse_id = CAST($2 as int));
	
	IF (mysrec.sstudent_id IS NULL) THEN
		mystr := 'Please register for Semester and select residence first.';
	ELSIF (mysrec.finalised = true) THEN
		mystr := 'You have closed the selection.';
	ELSIF (myrec.sgrade_id IS NULL) THEN
		INSERT INTO sgrades(sstudent_id, scourse_id, hours, credit, approved) VALUES (mycurrqs, CAST($2 AS integer), getcoursehours(CAST($2 AS integer)), getcoursecredits(CAST($2 AS integer)), true);
		mystr := 'Course registered awaiting approval';
	ELSIF (myrec.dropped=true) THEN
		UPDATE sgrades SET dropped=false, ask_drop=false, approved=false, hours=getcoursehours(CAST($2 AS integer)), credit=getcoursecredits(CAST($2 AS integer)) WHERE sgrade_id = myrec.sgrade_id;
		mystr := 'Course registered awaiting approval';
	ELSE
		mystr := 'Course already registered';
	END IF;

    RETURN mystr;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insSSpecialCourse(varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	mysrec RECORD;
	myrec RECORD;
	mystr VARCHAR(120);
	mycurrqs int;
BEGIN
	mycurrqs := get_sstudent_id($1);

	SELECT INTO mysrec sstudent_id, finalised, approved FROM sstudents
	WHERE (sstudent_id = mycurrqs);

	SELECT INTO myrec sgrade_id, dropped, approved FROM sgrades
	WHERE (sstudent_id = mycurrqs) AND (scourse_id = CAST($2 as int));
	
	IF (mysrec.sstudent_id IS NULL) THEN
		mystr := 'Please register for Semester and select residence first.';
	ELSIF (mysrec.finalised = true) THEN
		mystr := 'You have closed the selection.';
	ELSIF (myrec.sgrade_id IS NULL) THEN
		INSERT INTO sgrades(sstudent_id, scourse_id, hours, credit, approved) VALUES (mycurrqs, CAST($2 AS integer), getcoursehours(CAST($2 AS integer)), getcoursecredits(CAST($2 AS integer)), false);
		mystr := 'Course registered awaiting approval';
	ELSIF (myrec.dropped=true) THEN
		UPDATE sgrades SET dropped=false, ask_drop=false, approved=false, hours=getcoursehours(CAST($2 AS integer)), credit=getcoursecredits(CAST($2 AS integer)) WHERE sgrade_id = myrec.sgrade_id;
		mystr := 'Course registered awaiting approval';
	ELSE
		mystr := 'Course already registered';
	END IF;

    RETURN mystr;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dropQCourse(varchar(12), varchar(12)) RETURNS VARCHAR(50) AS $$
DECLARE
	myrec RECORD;
	mystr VARCHAR(50);
	mycurrqs int;
BEGIN
	mycurrqs := get_sstudent_id($1);

	SELECT INTO myrec sstudent_id, finalised FROM sstudents
	WHERE (sstudent_id = mycurrqs);

	IF (myrec.sstudent_id IS NULL) THEN
		mystr := 'Please register for Semester and select residence first.';
	ELSIF (myrec.finalised = true) THEN
		mystr := 'You have closed the selection.';
	ELSE
		UPDATE sgrades SET ask_drop = true, ask_drop_date = current_timestamp WHERE sgrade_id = CAST($2 as int);
		UPDATE sgrades SET dropped = true, drop_date = current_date WHERE sgrade_id = CAST($2 as int);
		mystr := 'Course Dropped.';
	END IF;
	
    RETURN mystr;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION gettimecount(integer, time, time, boolean, boolean, boolean, boolean, boolean, boolean, boolean) RETURNS bigint AS $$
	SELECT count(stimetable_id) FROM vw_student_timetable
	WHERE (sstudent_id=$1) AND (((start_time, end_time) OVERLAPS ($2, $3))=true) 
	AND ((c_monday and $4) OR (c_tuesday and $5) OR (c_wednesday and $6) OR (c_thursday and $7) OR (c_friday and $8) OR (c_saturday and $9) OR (c_sunday and $10));
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION insQClose(varchar(12), varchar(12)) RETURNS VARCHAR(250) AS $$
DECLARE
	myrec RECORD;
	mymajor RECORD;
	ttb RECORD;
	courserec RECORD;
	placerec RECORD;
	prererec RECORD;
	studentrec RECORD;
	mystr VARCHAR(250);
	mydegree_id int;
	myoverload boolean;
	myfeesline integer;
	mymaxcredit real;
BEGIN
	mydegree_id := get_student_degree_id($1);

	SELECT INTO myrec sstudent_id, finalised, finance_approval, gpa, hours, 
		session_id, session, min_credits, max_credits, study_level,
		off_campus, residence_off_campus, overload_approval, overload_hours, student_dean_approval
	FROM vw_student_sessions
	WHERE (student_degree_id = mydegree_id) AND (session_id = $2);
	
	mymaxcredit := myrec.max_credits;
	
	SELECT INTO mymajor majors.sessionload
	FROM (majors INNER JOIN student_majors ON majors.major_id = student_majors.major_id)
	WHERE student_majors.student_degree_id = mydegree_id;
	
	IF (mymajor.sessionload IS NOT NULL) THEN
		mymaxcredit := mymajor.sessionload;
	END IF;

	SELECT INTO courserec course_id, course_title FROM vw_selcourses 
		WHERE (sstudent_id = myrec.sstudent_id) AND (max_class < scoursestudents);
	SELECT INTO prererec course_id, course_title, prereqpassed FROM selectedgradeview 
		WHERE (sstudent_id = myrec.sstudent_id) AND (prereqpassed = false);
		
---	SELECT INTO placerec scourse_check_pass.year_taken, scourse_check_pass.course_id, scourse_check_pass.course_title
---	FROM scourse_check_pass LEFT JOIN studentgradeview ON (scourse_check_pass.student_id = studentgradeview.student_id)
---		AND (scourse_check_pass.course_id = studentgradeview.course_id)
---	WHERE (scourse_check_pass.elective = false) AND (scourse_check_pass.coursepased = false)
---		AND (scourse_check_pass.year_taken <= ((myrec.study_level/100)-1)) AND (scourse_check_pass.student_id = $1)
---		AND ((studentgradeview.grade_id is null) OR (studentgradeview.grade_id <> 'NG'))
---	ORDER BY year_taken, course_id;

	SELECT INTO ttb course_title FROM vw_student_timetable WHERE (sstudent_id=myrec.sstudent_id)
	AND (gettimecount(sstudent_id, start_time, end_time, c_monday, c_tuesday, c_wednesday, c_thursday, cfriday, csaturday, csunday) >1);

	IF (myrec.sstudent_id IS NULL) THEN 
		mystr := 'Please register for the semester and make course selections first before closing.';
	ELSIF (myrec.finalised = true) THEN
		mystr := 'Semester is closed for registration';
	ELSIF (ttb.course_title IS NOT NULL) THEN
		mystr := 'You have an timetable clashing for ' || ttb.course_title;
	ELSIF (courserec.course_id IS NOT NULL) THEN
		mystr := 'The class ' || courserec.course_id || ', ' || courserec.course_title || ' is full';
	ELSIF (prererec.course_id IS NOT NULL) THEN
		mystr := 'You need to complete the prerequisites or placement for course ' || prererec.course_id || ', ' || prererec.course_title;
---	ELSIF (placerec.course_id IS NOT NULL) THEN
---		mystr := 'You need to take all lower level course first like ' || placerec.course_id || ', ' || placerec.course_title;
	ELSIF (myrec.hours < myrec.min_credits) AND (myrec.overload_approval = false) THEN
		mystr := 'You have an underload, the required minimum is ' || CAST(myrec.min_credits as text) || ' credits.';
	ELSIF (myrec.hours < myrec.min_credits) AND (myrec.overload_approval = true) AND (myrec.hours < myrec.overload_hours) THEN
		mystr := 'You have an underload, you can only take the approved minimum of ' ||  CAST(myrec.overload_hours as text);
	ELSIF (myrec.hours > mymaxcredit) AND (myrec.overload_approval = false) THEN
		mystr := 'You have an overload, the required maximum is ' || CAST(mymaxcredit as text) || ' credits.';
	ELSIF (myrec.hours > mymaxcredit) AND (myrec.overload_approval = true) AND (myrec.hours > myrec.overload_hours) THEN
		mystr := 'You have an overload, you can only take the approved maximum of ' ||  CAST(myrec.overload_hours as text);
	ELSIF (myrec.off_campus = true) and (myrec.student_dean_approval = false) THEN
		mystr := 'You have no clearence to be off campus';
	ELSIF (myrec.finance_approval = true) THEN
		UPDATE sstudents SET finalised = true WHERE sstudent_id = myrec.sstudent_id;
		UPDATE sstudents SET firstclosetime = now() WHERE (firstclosetime is null) AND (sstudent_id = myrec.sstudent_id);
		mystr := 'Semester Submision done check status for approvals.';
	ELSE
		mystr := 'Get Financial approval first';
	END IF;

    RETURN mystr;
END;
$$ LANGUAGE plpgsql;

-- update the person who finacially approved a student
CREATE OR REPLACE FUNCTION updsstudents() RETURNS trigger AS $$
DECLARE
	myrec RECORD;
	mystr VARCHAR(120);
BEGIN
	IF (OLD.ispartpayment = false) AND (NEW.ispartpayment = true) THEN
		INSERT INTO approval_list(sstudent_id, approved_by, approval_type, approve_date, client_ip) 
		VALUES (NEW.sstudent_id, current_user, 'Plan Payment', now(), cast(inet_client_addr() as varchar));
	END IF;
	
	IF (OLD.finance_approval = false) AND (NEW.finance_approval = true) THEN
		INSERT INTO approval_list(sstudent_id, approved_by, approval_type, approve_date, client_ip) 
		VALUES (NEW.sstudent_id, current_user, 'Finance', now(), cast(inet_client_addr() as varchar));
	END IF;

	IF (OLD.finance_approval = true) AND (NEW.finance_approval = false) THEN
		INSERT INTO approval_list(sstudent_id, approved_by, approval_type, approve_date, client_ip) 
		VALUES (NEW.sstudent_id, current_user, 'Finance Open', now(), cast(inet_client_addr() as varchar));
	END IF;
	
	IF (OLD.student_dean_approval = false) AND (NEW.student_dean_approval = true) THEN
		INSERT INTO approval_list(sstudent_id, approved_by, approval_type, approve_date, client_ip) 
		VALUES (NEW.sstudent_id, current_user, 'Dean', now(), cast(inet_client_addr() as varchar));
	END IF;
	
	IF (OLD.approved = false) AND (NEW.approved = true) THEN
		INSERT INTO approval_list(sstudent_id, approved_by, approval_type, approve_date, client_ip) 
		VALUES (NEW.sstudent_id, current_user, 'Registary', now(), cast(inet_client_addr() as varchar));
	END IF;

	IF (OLD.finalised = true) AND (NEW.finalised = false) THEN
		UPDATE sstudents SET printed = false, approved = false, major_approval = false 
		WHERE sstudent_id = NEW.sstudent_id;
	END IF;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER updsstudents AFTER UPDATE ON sstudents
    FOR EACH ROW EXECUTE PROCEDURE updsstudents();

-- update the date a course was withdrawn
CREATE OR REPLACE FUNCTION updsgrades() RETURNS trigger AS $$
BEGIN
	IF (OLD.grade_id <> 'W') and (NEW.grade_id = 'W') THEN
		UPDATE sgrades SET withdraw_date = current_date WHERE sgrade_id = NEW.sgrade_id;
	END IF;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER updsgrades AFTER UPDATE ON sgrades
    FOR EACH ROW EXECUTE PROCEDURE updsgrades();

-- insert scourse_marks after adding scourse_items
CREATE OR REPLACE FUNCTION updscourse_items(varchar(12), varchar(12)) RETURNS varchar(240) AS $$
BEGIN
	INSERT INTO scourse_marks (sgrade_id, scourse_item_id)
	SELECT sgrades.sgrade_id, scourse_items.scourse_item_id
	FROM (scourse_items INNER JOIN sgrades ON scourse_items.scourse_id = sgrades.scourse_id)
		LEFT JOIN scourse_marks ON (sgrades.sgrade_id = scourse_marks.sgrade_id) AND (scourse_items.scourse_item_id = scourse_marks.scourse_item_id)
	WHERE (scourse_marks.scourse_mark_id is null) AND (sgrades.sgrade_id = CAST($2 as int));
	
	RETURN 'Student Marks Items Entered Correctly';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION updscourse_items() RETURNS trigger AS $$
BEGIN
	INSERT INTO scourse_marks (sgrade_id, scourse_item_id)
	SELECT sgrades.sgrade_id, NEW.scourse_item_id
	FROM sstudents INNER JOIN sgrades ON sstudents.sstudent_id = sgrades.sstudent_id
	WHERE (sstudents.approved = true) AND (sgrades.scourse_id = NEW.scourse_id);
	
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER updscourse_items AFTER INSERT ON scourse_items
    FOR EACH ROW EXECUTE PROCEDURE updscourse_items();
	
CREATE OR REPLACE FUNCTION updqcourseitemmarks(varchar(12), varchar(12)) RETURNS varchar(240) AS $$
BEGIN
	UPDATE sgrades SET instructor_marks = vw_course_item_marks.netscore FROM vw_course_item_marks
	WHERE (sgrades.sgrade_id = vw_course_item_marks.sgrade_id) AND 
		(sgrades.scourse_id = CAST($2 as int));
	
	RETURN 'Student Marks Updated Correctly';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION updqcoursedepartment(varchar(12), varchar(12)) RETURNS varchar(240) AS $$
BEGIN
	UPDATE sgrades SET department_marks = instructor_marks
	WHERE (sgrades.scourse_id = CAST($2 as int));
	
	UPDATE scourses SET lecture_submit = true, lsdate = now()
	WHERE (scourse_id = CAST($2 as int));
	
	RETURN 'Marks Submitted to the Department Correctly';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION openqcoursedepartment(varchar(12), varchar(12)) RETURNS varchar(240) AS $$
BEGIN
	UPDATE scourses SET lecture_submit = false
	WHERE (scourse_id = CAST($2 as int));
	
	RETURN 'Course opened for lecturer to correct';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION updqcoursefaculty(varchar(12), varchar(12)) RETURNS varchar(240) AS $$
BEGIN
	UPDATE sgrades SET final_marks = department_marks
	WHERE (sgrades.scourse_id = CAST($2 as int));
	
	UPDATE scourses SET department_submit = true, dsdate = now()
	WHERE (scourse_id = CAST($2 as int));
	
	RETURN 'Marks Submitted to the Faculty Correctly';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION updqcoursegrade(varchar(12), varchar(12)) RETURNS varchar(240) AS $$
BEGIN
	UPDATE sgrades SET grade_id = getgradeid(final_marks)
	WHERE (sgrades.scourse_id = CAST($2 as int));
	
	UPDATE scourses SET facultysubmit = true, fsdate = now()
	WHERE (scourse_id = CAST($2 as int));
	
	RETURN 'Final Grade Submitted to Registry Correctly';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION updprinted(integer) RETURNS void AS $$
	UPDATE sstudents SET printed = true WHERE sstudent_id=$1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION selQResidence(varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	mystr VARCHAR(120);
	myrec RECORD;
	myqstud int;
	myres int;
BEGIN
	myqstud := get_sstudent_id($1);
	myres := CAST($2 AS integer);

	SELECT INTO myrec sstudent_id, finalised FROM sstudents
	WHERE (sstudent_id=myqstud);

	IF (myrec.sstudent_id IS NULL) THEN
		mystr := 'Please register for the semester first.';
	ELSIF (myrec.finalised = true) THEN
		mystr := 'You have closed the selection.';
	ELSE
		UPDATE sstudents SET qresidenceid = myres, roomnumber = null WHERE (sstudent_id = myqstud);
		mystr := 'Residence registered awaiting approval';
	END IF;

    RETURN mystr;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION selQRoom(varchar(12), varchar(12)) RETURNS VARCHAR(50) AS $$
DECLARE
	mystr VARCHAR(120);
	myrec RECORD;
	myqstud int;
	myroom int;
BEGIN
	myqstud := get_sstudent_id($1);
	myroom := CAST($2 AS integer);

	SELECT INTO myrec sstudent_id, finalised FROM sstudents
	WHERE (sstudent_id = myqstud);

	IF (myrec.sstudent_id IS NULL) THEN
		mystr := 'Please register for the semester first.';
	ELSIF (myrec.finalised = true) THEN
		mystr := 'You have closed the selection.';
	ELSE
		UPDATE sstudents SET roomnumber = myroom WHERE sstudent_id = myqstud;
		mystr := 'Room Selected';
	END IF;

	RETURN mystr; 
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION selQsabathclass(varchar(12), varchar(12)) RETURNS VARCHAR(50) AS $$
DECLARE
	mystr VARCHAR(120);
	myrec RECORD;
	myqstud int;
	myclass int;
BEGIN
	myqstud := get_sstudent_id($1);
	myclass := CAST($2 AS integer);

	SELECT INTO myrec sstudent_id, finalised FROM sstudents
	WHERE (sstudent_id = myqstud);

	IF (myrec.sstudent_id IS NULL) THEN
		mystr := 'Please register for the semester first.';
	ELSIF (myrec.finalised = true) THEN
		mystr := 'You have closed the selection.';
	ELSE
		UPDATE sstudents SET sabathclassid = myclass, chaplainapproval = true WHERE sstudent_id = myqstud;
		mystr := 'Sabath Class Selected';
	END IF;

	RETURN mystr; 
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION updsubmited(varchar(12), varchar(12)) RETURNS VARCHAR(50) AS $$
BEGIN
	UPDATE scourse_marks SET submited = current_date WHERE scourse_mark_id=$2;
	RETURN 'Submmited';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION updatemajorapproval(varchar(12), int) RETURNS varchar AS $$
	UPDATE sstudents SET major_approval = true WHERE sstudent_id = $2;
	INSERT INTO approval_list(sstudent_id, approved_by, approval_type, approve_date) VALUES ($2, $1, 'Major', now());
	SELECT varchar 'Major Approval Done' as reply;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_core_major(int) RETURNS varchar(50) AS $$
    SELECT max(majors.major_name)
    FROM student_majors INNER JOIN majors ON student_majors.major_id = majors.major_id
    WHERE (student_majors.student_degree_id = $1) AND (student_majors.primary_major = true);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getaccsstudent_id(varchar(25)) RETURNS int AS $$
	SELECT max(sstudents.sstudent_id) 
	FROM (vw_student_degrees INNER JOIN sstudents ON vw_student_degrees.student_degree_id = sstudents.student_degree_id)
		INNER JOIN sessions ON sstudents.session_id = sessions.session_id
	WHERE (vw_student_degrees.account_number=$1) AND (sessions.active = true);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION updaterepeats(int, varchar(12)) RETURNS varchar(50) AS $$
DECLARE
    myrec RECORD;
    pass boolean;
BEGIN
	pass := false;
	FOR myrec IN SELECT sgrades.sgrade_id
		FROM ((sgrades INNER JOIN grades ON sgrades.grade_id = grades.grade_id)
			INNER JOIN scourses ON sgrades.scourse_id = scourses.scourse_id)
			INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id 

		WHERE (sgrades.grade_id<>'W') AND (grades.grade_name<>'AW') AND (grades.grade_name<>'NG') AND (sgrades.dropped = false)
			AND (sstudents.approved = true) AND (sstudents.student_degree_id = $1) AND (scourses.course_id = $2)
		ORDER BY grades.grade_weight desc, scourses.scourse_id
	LOOP
		IF (pass = true) THEN
			UPDATE sgrades SET repeated = true WHERE (sgrade_id = myrec.sgrade_id);
		ELSE
			UPDATE sgrades SET repeated = false WHERE (sgrade_id = myrec.sgrade_id);
		END IF;
		pass := true;
	END LOOP;

    RETURN 'Updated';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insTranscript(integer) RETURNS integer AS $$
	INSERT INTO transcript_print (student_degree_id) VALUES($1);
	SELECT 1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_student_degree_id(varchar(12), varchar(12)) RETURNS integer AS $$
	SELECT MAX(sstudents.student_degree_id)
	FROM student_degrees INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id
	WHERE (student_degrees.student_id = $1) AND (sstudents.session_id = $2);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION addacademicyear(varchar(12), int) RETURNS varchar(12) AS $$
	SELECT cast(substring($1 from 1 for 4) as int) + $2 || '/' || cast(substring($1 from 1 for 4) as int) + $2 + 1 || '.3';
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_grade_id(real) RETURNS integer AS $$
	SELECT max(grade_id)
	FROM grades 
	WHERE (min_range <= $1) AND (max_range >= $1);
$$ LANGUAGE SQL;

-- update the course title from course titles
CREATE OR REPLACE FUNCTION get_course_title(varchar(12)) RETURNS varchar(50) AS $$
	SELECT MAX(course_title) FROM courses WHERE (course_id = $1);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION ins_session() RETURNS trigger AS $$
BEGIN
	INSERT INTO scourses (session_id, instructorid, course_id, max_class)
	SELECT NEW.session_id, 0, course_id, 200
	FROM major_contents
	WHERE session_done = CAST(substring(NEW.session_id from 11 for 1) as int)
	GROUP BY course_id;

	INSERT INTO sresidences (session_id, residence_id, charges)
	SELECT NEW.session_id, residence_id, default_rate
	FROM residences;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_session AFTER INSERT ON sessions
    FOR EACH ROW EXECUTE PROCEDURE ins_session();

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
	
-- update students email address
CREATE OR REPLACE FUNCTION upd_student_email(varchar(50), varchar(50)) RETURNS varchar(120) AS $$
DECLARE
	mycnt RECORD;
	mypass VARCHAR(120);
	mystr VARCHAR(120);
BEGIN
	mypass := lower($2 || substring($1 from 1 for 2));

	SELECT INTO mycnt count(student_id) as emailcount
	FROM students
	WHERE (emailuser = mypass);
	
	IF (mycnt.emailcount = 0) THEN
		mystr := mypass;
	ELSE
		mystr := mypass || mycnt.emailcount;
	END IF;
	
	RETURN mystr;
END;
$$ LANGUAGE plpgsql;

-- update students email address
CREATE OR REPLACE FUNCTION upd_student_email(varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	myrec RECORD;
	mystr VARCHAR(120);
BEGIN
	SELECT INTO myrec upd_student_email(first_name, surname) as newemail, emailuser
	FROM students
	WHERE (student_id = $1);
	
	IF (myrec.emailuser is not null) THEN
		mystr := 'There is already and email ' || myrec.emailuser || ' assigned';
	ELSE
		UPDATE students SET emailuser = myrec.newemail WHERE (student_id = $1);
		mystr := 'New email ' || myrec.newemail;
	END IF;
	
	RETURN mystr;
END;
$$ LANGUAGE plpgsql;


--- Finance payment
CREATE OR REPLACE FUNCTION insQPayment(varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	myrec RECORD;
	myqrec RECORD;
	mypayrec RECORD;
	mypayreccheck RECORD;
	mysession RECORD;
	mystud RECORD;
	mystr VARCHAR(120);
	mycurrqs int;
	myamount REAL;
	mylatefees int;
	mynarrative varchar(120);
BEGIN
	mycurrqs := get_sstudent_id($1);
	
	SELECT INTO mystud currentbalance, account_number, new_student, seeregistrar
	FROM students WHERE (student_id = $1);
	
	SELECT INTO mypayrec student_payment_id
	FROM student_payments WHERE (sstudent_id = mycurrqs) AND (approved = false);
	
	SELECT INTO mypayreccheck student_payment_id
	FROM student_payments WHERE (sstudent_id = mycurrqs) AND (approved = true);
	
	SELECT INTO myqrec charges
	FROM sstudents
	WHERE (sstudent_id = mycurrqs);	
	
	SELECT INTO mysession slatereg, slast_drop, late_registration_fee, getchargedays(slatereg, current_date) as late_days,
		late_registration_fee * getchargedays(slatereg, current_date) as late_fees,
		session_id, substring(session_id from 11 for 1) as session
	FROM sessions WHERE (active = true);
	
	mylatefees := 0;
	mynarrative := '';
	IF (mysession.late_fees > 0) AND (myqrec.charges = 0) AND ((mystud.new_student = false) OR (mysession.session != '1')) THEN 
		mylatefees := mysession.late_fees;
		mynarrative := 'Late Registration fees charges for ' || CAST(mysession.late_days as text) || ' days at a rate of ' || CAST(mysession.late_registration_fee as text) || ' Per day.';
	END IF;

	IF (mycurrqs is not null) AND (mypayreccheck.student_payment_id is null) AND (mysession.late_fees > 0) THEN
		UPDATE sstudents SET charges = mylatefees, financenarrative = mynarrative
		WHERE (sstudent_id = mycurrqs);
	END IF;
	
	SELECT INTO myrec account_number, session_id, currbalance, full_final_balance, finalbalance,
		paymenttype, ispartpayment, off_campus, student_dean_approval, finance_closed, finance_approval
	FROM vw_sstudent_balances
	WHERE (sstudent_id = mycurrqs);	

	myamount := 0;
	mystr := null;
	IF (myrec.currbalance is null) THEN
		mystr := 'Application for payment rejected because your current credit is not updated, send a post to Bursary.';
	ELSIF (myrec.finance_closed = true) OR (myrec.finance_approval = true) THEN
		mystr := 'You cannot make changes after submiting your payment unless you apply on the post for it to be opened by finance.';
	ELSIF (myrec.off_campus = true) AND (myrec.student_dean_approval = false) THEN
		mystr := 'Application for payment rejected, first get off campus approval.';
	ELSIF (myrec.paymenttype = 1) THEN
		myamount := myrec.full_final_balance;
	ELSIF (myrec.paymenttype = 2) THEN
		myamount := myrec.finalbalance;
	ELSIF (myrec.paymenttype = 3) AND (myrec.ispartpayment = false) THEN
		mystr := 'Application for payment rejected, your require approval for the payment plan';
	ELSIF (myrec.paymenttype = 3) AND (myrec.ispartpayment = true) THEN
		myamount := myrec.currbalance + (myrec.finalbalance - myrec.currbalance) / 2;
	ELSE
		mystr := 'Application for payment rejected, verify application and approvals';
	END IF;

	IF (myamount < 0) THEN
		IF (mypayrec.student_payment_id is null) THEN
			INSERT INTO student_payments (sstudent_id, amount, narrative) 
			VALUES (mycurrqs, myamount * (-1), CAST(nextval('studentpayment_seq') as text) || 'Fees;' || myrec.session_id || ';' || myrec.account_number);
		ELSE
			UPDATE student_payments SET amount = myamount * (-1)
			WHERE student_payment_id = mypayrec.student_payment_id;
		END IF;
		UPDATE sstudents SET finance_closed = true WHERE (sstudent_id = mycurrqs);
		mystr := 'Application for payment accepted, proceed';
	END IF;

	IF (myamount >= 0) AND (mystr is null) THEN
		UPDATE sstudents SET finance_closed = true WHERE sstudent_id = mycurrqs;
		mystr := 'Fees indicated as fully paid';
	END IF;

    RETURN mystr;
END;
$$ LANGUAGE plpgsql;

-- update students email address
CREATE OR REPLACE FUNCTION del_dup_student(varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	myrec RECORD;
	myreca RECORD;
	myrecb RECORD;
	myrecc RECORD;
	myqtr RECORD;
	new_id VARCHAR(16);
	mystr VARCHAR(120);
BEGIN
	IF($2 is null) THEN 
		SELECT INTO myqtr substring(session_id from 3 for 2) as qid, session_id FROM sessions WHERE active = true;
		new_id := myqtr.qid || substring($1 from 3 for 5);
	ELSE
		new_id := $2;
	END IF;
	
	SELECT INTO myrec student_id, student_name FROM students WHERE (student_id = new_id);
	SELECT INTO myreca student_degree_id, student_id FROM student_degrees WHERE (student_id = $2);
	SELECT INTO myrecb student_degree_id, student_id FROM student_degrees WHERE (student_id = $1);
	SELECT INTO myrecc a.student_degree_id, a.session_id FROM
	((SELECT student_degree_id, session_id FROM sstudents WHERE student_degree_id = myreca.student_degree_id)
	EXCEPT (SELECT student_degree_id, session_id FROM sstudents WHERE student_degree_id = myrecb.student_degree_id)) as a;
	
	IF ($1 = $2) THEN
		mystr := 'That the same ID no change';
	ELSIF (myrecc.session_id IS NOT NULL) THEN
		mystr := 'Conflict in session ' || myrecc.session_id;
	ELSIF (myreca.student_degree_id IS NOT NULL) AND (myrecb.student_degree_id IS NOT NULL) THEN
		UPDATE sstudents SET student_degree_id = myreca.student_degree_id WHERE student_degree_id = myrecb.student_degree_id;
		UPDATE student_requests SET student_id = $2 WHERE student_id = $1;
		DELETE FROM student_majors WHERE student_degree_id = myrecb.student_degree_id;
		DELETE FROM student_degrees WHERE student_degree_id = myrecb.student_degree_id;
		DELETE FROM students WHERE student_id = $1;	
		mystr := 'Changes to ' || $2;
	ELSIF (myrec.student_id is not null) THEN
		UPDATE student_degrees SET student_id = $2 WHERE student_id = $1;
		UPDATE student_requests SET student_id = $2 WHERE student_id = $1;
		DELETE FROM students WHERE student_id = $1;
		mystr := 'Changes to ' || $2;
	ELSIF ($2 is null) THEN
		DELETE FROM student_degrees WHERE student_id is null;
		UPDATE student_degrees SET student_id = null WHERE student_id = $1;
		UPDATE student_requests SET student_id = null WHERE student_id = $1;
		UPDATE students SET student_id = new_id, new_student = false  WHERE student_id = $1;
		UPDATE student_degrees SET student_id = new_id WHERE student_id is null;
		UPDATE student_requests SET student_id = new_id WHERE student_id is null;
		mystr := 'Changes to ' || new_id;
	END IF;
	
	RETURN mystr;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Closesession(varchar(12)) RETURNS varchar(50) AS $$
	UPDATE scourses SET approved = true WHERE (session_id = $1);
	
	SELECT text 'Done' AS mylabel;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION Opensession(varchar(12)) RETURNS varchar(50) AS $$
	UPDATE scourses SET approved = false WHERE (session_id = $1);
	
	SELECT text 'Done' AS mylabel;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION Matriculate(varchar(12)) RETURNS varchar(50) AS $$
	SELECT del_dup_student(student_id, null) FROM students
	
$$ LANGUAGE SQL;

-- update the transaction ID
CREATE OR REPLACE FUNCTION upd_student_payments() RETURNS trigger AS $$
DECLARE
	reca RECORD;
BEGIN
	SELECT school_id, department_id INTO reca
	FROM (students INNER JOIN student_degrees ON students.student_id = student_degrees.student_id)
		INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id
	WHERE (sstudents.sstudent_id = NEW.sstudent_id);

	IF(reca.department_id = 'CSMA') THEN
		NEW.terminalid = '0110000004';
	ELSIF(reca.school_id = 'LSS') THEN
		NEW.terminalid = '0560000128';
	ELSIF(reca.school_id = 'SAT') THEN
		NEW.terminalid = '0330000008';
	ELSIF(reca.school_id = 'EAH') THEN
		NEW.terminalid = '0350000001';
	ELSE
		NEW.terminalid = '0690000082';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER upd_student_payments BEFORE INSERT ON student_payments
    FOR EACH ROW EXECUTE PROCEDURE upd_student_payments();

CREATE OR REPLACE FUNCTION updSPayment(varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	transid integer;
	oldtransid integer;
BEGIN
	transid := nextval('studentpaymentid_seq');
	oldtransid := CAST($2 as integer);
	
	INSERT INTO paymentracks (student_payment_id, oldtransactionid)
	VALUES (transid, oldtransid);

	UPDATE student_payments SET student_payment_id = transid
	WHERE student_payment_id = oldtransid;

	RETURN 'Update Transaction to new ID ' || CAST(transid as varchar);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ins_pin_data() RETURNS trigger AS $$
BEGIN	
	UPDATE applications SET paid = true, open_application = true
	WHERE (receiptnumber = NEW.receipt_no) AND (confirmationno = NEW.confirmation_no);

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION submit_application(varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
BEGIN
	UPDATE registrations SET submit_application = true, submit_date = now()
	WHERE (application_id = CAST($2 as integer));

	UPDATE applications SET open_application = false
	WHERE (application_id = CAST($2 as integer));

	RETURN 'Submitted the application.';
END;
$$ LANGUAGE plpgsql;
