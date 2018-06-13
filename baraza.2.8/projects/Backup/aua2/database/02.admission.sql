
--- Extend Entities to accomodate 
ALTER TABLE entitys ADD selection_id 			integer;

CREATE TABLE applications (
	application_id			integer primary key,
	session_id				varchar(12) references sessions,
	org_id					integer references orgs,
	entity_id 				integer references entitys,
	surname					varchar(50) not null,
	other_names				varchar(50),
	first_name				varchar(50) not null,
	email					varchar(120) not null,
	approved				boolean default false not null,
	open_application		boolean default false not null,
	closed					boolean default false not null,
	emailed					boolean default false not null,
	paid					boolean default false not null,
	receipt_number			varchar(50),
	confirmation_no			varchar(75),
	purchase_centre			varchar(50),
	amount					real not null,
	application_date    	date default current_date not null,
	Picked					boolean default false not null,
	picked_date				timestamp,
	pay_date				timestamp,
	e_amount				real,
	success					varchar(50),
	payment_code			varchar(50),
	trans_no				varchar(50),
	card_type				varchar(50),
	terminal_id				varchar(16),
	transaction_id			integer,
	phistory_id				integer default -100,
	paid_time				timestamp,
	narrative				varchar(240),
	UNIQUE(email,org_id)
);

CREATE INDEX applications_session_id ON applications (session_id);
CREATE INDEX applications_org_id ON applications (org_id);
CREATE INDEX applications_entity_id ON applications (entity_id);
CREATE SEQUENCE applications_transaction_id_seq;


CREATE TABLE registrations (
	registration_id			integer primary key,
	first_choice_id			varchar(12) references majors,
	second_choice_id		varchar(12) references majors,
	application_id 			integer references applications,
	major_id				varchar(12) references majors,
	entry_form_id			integer references entry_forms,
	mark_id					integer references marks,
	org_id					integer references orgs,
	surname					varchar(50) not null,
	first_name				varchar(50) not null,
	other_names				varchar(50),
	maiden_name				varchar(50),
	former_names			varchar(50),
	home_address			text,
	phone_number			varchar(50),
	email					varchar(120) not null,
	address					varchar(240),
	zip_code				varchar(50),
	town					varchar(50),
	birth_date				date not null,
	sex						varchar(12),
	home_number				varchar(50),
	mobile_number			varchar(50),
	nationality_id			char(2) references sys_countrys,
	origin_country_id		char(2) references sys_countrys,
	denomination_id			varchar(12) references denominations,
	marital_status			varchar(12),
	guardian				text,
	next_of_kin				varchar(50),
	kin_relationship		varchar(50),
	existing_id				varchar(12),
	application_date    	date not null default current_date,
	submit_application		boolean default false not null,
	submit_date				timestamp,
	is_accepted				boolean default false not null,
	is_reported				boolean default false not null,
	is_deferred				boolean default false not null,
	is_rejected				boolean default false not null,
	evaluation_date			date,
	reported				boolean default false not null,
	reported_date			date,
	off_campus				boolean default false not null,
	previous_applications	boolean default false not null,
	previous_admitted		boolean default false not null,
	admitted_year			varchar(12),
	admittted_major_id		varchar(12) references majors,
	previous_suspended		boolean default false not null,
	suspended_period		varchar(12),
	drug_abuse				boolean not null default false,
	drug_therapies			varchar(240),
	cult_member				boolean not null default false,
	cult_period				varchar(240),
	cult_therapies			varchar(240),
	gce_marks				real,
	ssce_marks				real,
	other_marks				real,
	evaluation_officer		varchar(50),
	admission_status		varchar(25) not null default 'regular',
	picture_file			varchar(240),
	social_problems			text,
	admission_level			integer default 100 not null,	
	direct_entry			varchar(16) default 'no' not null,
	jamb_reg_no				varchar(50),
	jamb_exam_no			varchar(50),
	jamb_score				varchar(50),	
	acceptance_fees			real,
	af_date					timestamp,
	af_amount				real,
	af_success				varchar(50),
	af_payment_code			varchar(50),
	af_trans_no				varchar(50),
	af_card_type			varchar(50),
	af_picked				boolean default false not null,
	af_picked_date			timestamp,	
	is_new_student			boolean default false not null,
	account_number			varchar(50),
	e_tranzact_no			varchar(50),	
	details					text,
	
	UNIQUE (org_id,application_id)
);
CREATE INDEX registrations_first_choice_id ON registrations (first_choice_id);
CREATE INDEX registrations_second_choice_id ON registrations (second_choice_id);
CREATE INDEX registrations_major_id ON registrations (major_id);
CREATE INDEX registrations_nationality_id ON registrations (nationality_id);
CREATE INDEX registrations_denomination_id ON registrations (denomination_id);
CREATE INDEX registrations_org_id ON registrations (org_id);
ALTER TABLE student_payments ADD registration_id integer references registrations;
CREATE INDEX student_payments_registration_id ON student_payments (registration_id);



DROP VIEW vw_entitys;
CREATE VIEW vw_entitys AS
	SELECT orgs.org_id, orgs.org_name, 
		entity_types.entity_type_id, entity_types.entity_type_name, 
		entity_types.entity_role, entity_types.group_email, entity_types.use_key_id,
		entitys.entity_id, entitys.entity_name, entitys.user_name, entitys.Super_User, entitys.Entity_Leader, 
		entitys.Date_Enroled, entitys.Is_Active, entitys.entity_password, entitys.first_password, 
		entitys.primary_email, entitys.function_role, entitys.selection_id, entitys.details
	FROM entitys INNER JOIN orgs ON entitys.org_id = orgs.org_id
		INNER JOIN entity_types ON entitys.entity_type_id = entity_types.entity_type_id;

CREATE VIEW vw_applications AS 
	SELECT entitys.entity_id, entitys.entity_name, entitys.user_name, entitys.primary_email,
		entitys.primary_telephone, entitys.selection_id, 
		(CASE WHEN entitys.selection_id = 4 THEN 'UNDERGRADUATE' ELSE 'POSTGRADUATE' END) as selection_name,

		applications.application_id, applications.confirmation_no, applications.receipt_number, 
		applications.purchase_centre, applications.application_date, applications.amount, applications.paid,
		applications.approved, applications.closed, applications.open_application, applications.narrative,
		applications.pay_date, applications.card_type, applications.success,
		applications.session_id, applications.org_id,
		'Babcock Application Responce'::varchar AS emailsubject,
		(CASE WHEN applications.paid = true THEN 'The payment is completed and updated'
		WHEN (applications.confirmation_no is null) THEN applications.narrative
		ELSE
		'<a href="payments/paymentApplicant.jsp?amount=' || applications.amount || '&confirmation_no='|| applications.confirmation_no
		|| '&transId=' || applications.application_id
		|| '" target="_blank"><IMG SRC="resources/images/etranzact.jpg" width=318 height=32 alt="Etranzact"></a>'
		END) as makepayment,

		(CASE WHEN applications.paid = false THEN 
		'<a href="payments/paymentClientApp.jsp?TRANSACTION_ID=' || applications.application_id
		|| '" target="_blank"><IMG SRC="resources/images/etranzact.jpg" width=120 height=24 alt="Etranzact"></a>'
		ELSE 'The payment is completed and updated' END) as pay_web,

		(CASE WHEN applications.paid = true THEN 'The payment is completed' ELSE 'Payment has not been done' END) as payment_Status,

		(CASE WHEN applications.paid = false THEN applications.application_id
		ELSE 0 END) as payeditid
	FROM entitys INNER JOIN applications ON entitys.entity_id = applications.application_id;


CREATE VIEW vw_exam_registration AS
	SELECT registrations.registration_id, registrations.email, registrations.submit_application, 
		registrations.is_accepted, registrations.is_reported, registrations.is_deferred, registrations.is_rejected,
		registrations.application_date, registrations.sex, registrations.surname, registrations.first_name, registrations.other_names, 
		registrations.org_id, registrations.entry_form_id,
		trim(registrations.surname || ', ' ||  registrations.first_name || ' ' || COALESCE(registrations.other_names)) as full_name,
		admission_status, gce_marks, ssce_marks, other_marks, evaluation_officer, evaluation_date, reported, reported_date,
		('<a href="http://afrihub.com/babcock/?data=' || ENCODE(CAST('10001:' || replace(trim(registrations.surname || ' ' ||  registrations.first_name || ' ' || COALESCE(registrations.other_names, '')), ':', '')
		|| ':' || registration_id || ':' || Sex || ':' || COALESCE(replace(email, ':', ''), '')  || 
		':' || replace(COALESCE(mobile_number, phone_number, ''), ':', '') AS bytea), 'base64') || '" target="_blank">Exam Registration</a>') as exam_registration
	FROM registrations;



CREATE OR REPLACE FUNCTION ins_application() RETURNS trigger AS $$
DECLARE
	reca			RECORD;
	v_org_id		INTEGER;
BEGIN	
	IF(NEW.selection_id is not null) THEN
		IF(TG_WHEN = 'BEFORE')THEN
			IF((NEW.user_name is null) OR (NEW.primary_email is null))THEN
				RAISE EXCEPTION 'You need to enter the email address';
			END IF;

			IF(NEW.user_name != NEW.primary_email)THEN
				RAISE EXCEPTION 'The email and confirmation email should match.';
			END IF;

			SELECT org_id INTO v_org_id
			FROM forms WHERE (form_id = NEW.selection_id);

			NEW.user_name := lower(trim(NEW.user_name));
			NEW.primary_email := lower(trim(NEW.user_name));

			NEW.first_password := upper(substring(md5(random()::text) from 3 for 9));
			NEW.entity_password := md5(NEW.first_password);

			NEW.org_id = v_org_id;

			RETURN NEW;
		END IF;

		IF(TG_WHEN = 'AFTER')THEN
			INSERT INTO entry_forms (org_id, entity_id, entered_by_id, form_id)
			VALUES(NEW.org_id, NEW.entity_id, NEW.entity_id, NEW.selection_id);

			INSERT INTO sys_emailed (org_id, sys_email_id, table_id, table_name)
			VALUES(NEW.org_id, 1, NEW.entity_id, 'entitys');

			SELECT session_id, applicationfees INTO reca
			FROM sessions 
			WHERE (session_id IN (SELECT max(session_id) FROM sessions WHERE (org_id = NEW.org_id)));

			INSERT INTO applications (org_id, application_id, session_id, amount, terminal_id, narrative)
			VALUES(NEW.org_id, NEW.entity_id, reca.session_id, reca.applicationfees, '7007139289',
				'For ETranzact PIN payment enter receipt and confirmation numbers');
		END IF;
	ELSE
		IF(TG_WHEN = 'BEFORE')THEN
			RETURN NEW;
		END IF;
	END IF;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_bf_application BEFORE INSERT ON entitys
    FOR EACH ROW EXECUTE PROCEDURE ins_application();

CREATE TRIGGER ins_application AFTER INSERT ON entitys
    FOR EACH ROW EXECUTE PROCEDURE ins_application();

CREATE OR REPLACE FUNCTION upd_application() RETURNS trigger AS $$
DECLARE
	v_submit_application	BOOLEAN;
BEGIN	
	SELECT submit_application INTO v_submit_application
	FROM registrations
	WHERE (registration_id = NEW.entity_id);

	IF(NEW.first_password = OLD.first_password) AND (NEW.entity_password = OLD.entity_password)THEN
		IF(v_submit_application = true) THEN
			RAISE EXCEPTION 'You cannot make changed after submission of application.';
		END IF;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER upd_application BEFORE UPDATE ON entitys
    FOR EACH ROW EXECUTE PROCEDURE upd_application();

CREATE OR REPLACE FUNCTION upd_applications() RETURNS trigger AS $$
DECLARE
	myrec RECORD;
BEGIN

	IF(OLD.paid = true) AND (NEW.paid = true)THEN
		IF(OLD.confirmation_no <> NEW.confirmation_no)THEN
			RAISE EXCEPTION 'You cannot make changes to a paid application.';
		END IF;
	END IF;

	SELECT applications.application_id, applications.receipt_number, applications.confirmation_no INTO myrec
	FROM applications
	WHERE (applications.application_id <> NEW.application_id) 
		AND ((receipt_number = NEW.receipt_number) OR (confirmation_no = NEW.confirmation_no));
	
	IF(myrec.application_id is not null) THEN
		NEW.receipt_number = null;
		NEW.confirmation_no = null;
		NEW.narrative = 'The receipt number or confirmation number you have used have been used before';
	ELSE
		NEW.narrative = 'Click on the PIN Payment icon bellow to proceed';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER upd_applications BEFORE UPDATE ON applications
	FOR EACH ROW EXECUTE PROCEDURE upd_applications();


CREATE OR REPLACE FUNCTION get_transaction_id(integer) RETURNS integer AS $$
DECLARE
	v_transaction_id			integer;
	v_amount					real;
BEGIN
	v_transaction_id := nextval('applications_transaction_id_seq');
	
	SELECT amount INTO v_amount
	FROM applications
	WHERE (application_id = $1);
	
	UPDATE applications SET transaction_id = v_transaction_id WHERE (application_id = $1);

	INSERT INTO application_payments (application_id, transaction_id, amount)
	VALUES ($1, v_transaction_id, v_amount);
	
	RETURN v_transaction_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ins_registrations() RETURNS trigger AS $$
DECLARE
	v_org_id			INTEGER;	
	v_entity_id			INTEGER;
BEGIN
	
	SELECT org_id, entity_id INTO v_org_id, v_entity_id
	FROM entry_forms
	WHERE (entry_form_id = NEW.entry_form_id);
	
	NEW.registration_id := v_entity_id;
	NEW.org_id := v_org_id;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_registrations BEFORE INSERT ON registrations
    FOR EACH ROW EXECUTE PROCEDURE ins_registrations();

CREATE OR REPLACE FUNCTION select_exam_date(varchar(12), varchar(12), varchar(12), varchar(12)) RETURNS varchar AS $$
DECLARE
	v_app_id			int;
	v_exam_id			int;
	v_capacity			int;
	v_count				int;
	v_paid 				boolean;
	msg					varchar;
BEGIN
	v_app_id := CAST($2 AS int);
	v_exam_id := CAST($1 AS int);
	
	SELECT exam_centers.center_capacity INTO v_capacity
	FROM exam_centers INNER JOIN exam_dates ON exam_centers.exam_center_id = exam_dates.exam_center_id
	WHERE (exam_dates.exam_date_id = v_exam_id);
	
	SELECT count(application_id) INTO v_count
	FROM applications
	WHERE (paid = true) AND (exam_date_id = v_exam_id);
	
	SELECT paid INTO v_paid
	FROM applications
	WHERE (application_id = v_app_id);

	IF(v_exam_id is null) THEN
		msg:= 'Not Updated';
		RAISE EXCEPTION 'The exam center for this date is full select another one.';
	ELSIF(v_count >= v_capacity) THEN
		msg:= 'Not Updated';
		RAISE EXCEPTION 'The exam center for this date is full select another one.';
	ELSIF(v_paid = false) THEN
		msg:= 'You need to pay before selecting the exam center';
		RAISE EXCEPTION 'You need to pay before selecting the exam center';
	ELSE
		UPDATE applications SET exam_date_id = v_exam_id
		WHERE application_id = v_app_id;
		msg:= 'Updated'|| ' Application ID ' || v_app_id || ' exam center and date ID ' || v_exam_id;
	END IF;

	RETURN msg;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION submit_application(varchar(12), varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	myrec				RECORD;
	v_approve_status	VARCHAR(16);
	mystr 				VARCHAR(120);
BEGIN
	SELECT applications.application_id, applications.exam_date_id, applications.paid, 
		entitys.entity_id, entitys.picture_file,
		registrations.registration_id, registrations.first_choice_id, registrations.second_choice_id,
		registrations.denomination_id, age(registrations.birth_date) as app_age
	INTO myrec
	FROM applications INNER JOIN registrations ON applications.application_id = registrations.registration_id
		INNER JOIN entitys ON applications.application_id = entitys.entity_id
	WHERE (applications.application_id = CAST($1 as integer));

	SELECT approve_status INTO v_approve_status
	FROM entry_forms
	WHERE (entity_id = myrec.entity_id);

	IF (myrec.picture_file is null) THEN
		mystr := 'You must upload your photo before submission';
	ELSIF (myrec.paid = false) THEN
		mystr := 'You must first make full payment before submiting the application.';
	ELSIF (myrec.exam_date_id is null) THEN
		mystr := 'Select exam center date';
	ELSIF (myrec.app_age < '14 years'::interval) THEN
		mystr := 'You need to be older than 16 years to apply for this programme';
	ELSIF (myrec.first_choice_id is null) THEN
		mystr := 'Select First Programme Choice';
	ELSIF (myrec.second_choice_id is null) THEN
		mystr := 'Select Second Programme Choice';
	ELSIF (myrec.denomination_id is null) THEN
		mystr := 'Select Denomination';
	ELSIF (v_approve_status = 'Draft') THEN
		mystr := 'You need the form submited first';
	ELSE
		UPDATE applications SET open_application = false
		WHERE (application_id = myrec.application_id);

		UPDATE registrations SET submit_application = true, submit_date = now(), major_id = first_choice_id
		WHERE (registration_id = myrec.application_id);

		mystr := 'Submitted the application.';
	END IF;

	RETURN mystr;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION manage_application(varchar(12), varchar(12), varchar(12), varchar(12)) RETURNS VARCHAR(120) AS $$
DECLARE
	v_registration_id		integer;
	v_org_id				integer;
	v_studentpaymentid		integer;
	myrec					RECORD;
	msg 					varchar(120);
BEGIN
	v_registration_id := CAST($1 as integer);

	SELECT org_id INTO v_org_id
	FROM registrations WHERE (registration_id = v_registration_id);

	IF ($3 = '1') THEN
		SELECT session_id, acceptance_fee INTO myrec
		FROM sessions 
		WHERE session_id IN (SELECT max(session_id) FROM sessions);

		UPDATE registrations SET is_accepted = true, evaluation_date = current_date,
			acceptance_fees = myrec.acceptance_fee
		WHERE (registration_id = v_registration_id) AND (is_accepted = false);

		INSERT INTO sys_emailed (org_id, sys_email_id, table_id, table_name)
		VALUES(v_org_id, 4, v_registration_id, 'entitys');

		msg := 'Application Accepted';
	ELSIF ($3 = '2') THEN
		UPDATE registrations SET is_rejected = true, evaluation_date = current_date
		WHERE (registration_id = v_registration_id);

		INSERT INTO sys_emailed (org_id, sys_email_id, table_id, table_name)
		VALUES(v_org_id, 5, v_registration_id, 'entitys');

		msg := 'Application rejected';
	ELSIF ($3 = '3') THEN
		UPDATE entry_forms SET approve_status = 'Draft'
		WHERE (entity_id = v_registration_id);

		UPDATE applications SET open_application = true
		WHERE (application_id = v_registration_id);

		DELETE FROM registrations WHERE (registration_id = v_registration_id);

		INSERT INTO sys_emailed (org_id, sys_email_id, table_id, table_name)
		VALUES(v_org_id, 6, v_registration_id, 'entitys');

		msg := 'Application opened for corrections';
	ELSIF ($3 = '4') THEN
		UPDATE registrations SET is_reported = true
		WHERE (registration_id = v_registration_id);

		msg := 'Applicant reported';
	ELSIF ($3 = '5') THEN
		UPDATE registrations SET is_deferred = true
		WHERE (registration_id = v_registration_id);

		msg := 'Applicant deferred';
	END IF;

	RETURN msg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pick_appfees(varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	msg				varchar(120);
BEGIN
	UPDATE registrations SET af_picked = true, af_picked_date = now()
	WHERE registrations.registration_id = CAST($1 as int);

	msg := 'Picked';

    RETURN msg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION admit_applicant(varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	myrec 			RECORD;
	reca			RECORD;
	new_id 			varchar(12);
	full_name 		varchar(100);
	p_email			varchar(120);
	email_count		bigint;
	genfirstpass 	varchar(32);
	genstudentpass 	varchar(32);
	v_degree_id		integer;
	msg				varchar(120);
BEGIN
	SELECT departments.department_id, departments.org_id, majors.major_id,
		registrations.denomination_id, registrations.registration_id,
		registrations.surname, registrations.first_name, registrations.other_names,
		registrations.nationality_id, registrations.birth_date, registrations.existing_id, registrations.first_choice_id,
		registrations.address, registrations.zip_code, registrations.town, registrations.origin_country_id,
		registrations.phone_number, registrations.email, registrations.account_number, registrations.e_tranzact_no,
		registrations.birth_state_id,
		substring(registrations.sex from 1 for 1) as sex, substring(registrations.maritalstatus from 1 for 1) as maritalstatus,
		entitys.picture_file
		INTO myrec
	FROM (departments INNER JOIN majors ON departments.department_id = majors.department_id)
		INNER JOIN registrations ON majors.major_id = registrations.major_id
		INNER JOIN entitys ON registrations.registration_id = entitys.entity_id
	WHERE (registrations.registration_id = CAST($1 as integer));

	SELECT session_id, new_student_code, new_student_index INTO reca
	FROM sessions 
	WHERE session_id IN (SELECT max(session_id) FROM sessions);
	
	IF myrec.major_id IS NULL THEN
		msg := 'No programme selected.';
	ELSIF myrec.existing_id IS NULL THEN
		IF (myrec.other_names IS NULL) THEN
			full_name := upper(trim(myrec.surname)) || ', ' || upper(trim(myrec.first_name));
		ELSE
			full_name := upper(trim(myrec.surname)) || ', ' || upper(trim(myrec.first_name)) || ' ' || upper(trim(myrec.other_names));
		END IF;		

		p_email := lower(trim(myrec.surname)) || '.' || lower(trim(myrec.first_name));
		SELECT count(entity_id) + 1 INTO email_count
		FROM entitys 
		WHERE primary_email ilike p_email || '%';

		p_email :=  p_email || lpad(CAST(email_count as varchar), 2, '0') || '@std.babcock.edu.ng';

		genfirstpass := upper(substring(md5(random()::text) from 3 for 10));
		genstudentpass := md5(genfirstpass);

		new_id := reca.new_student_code || '/' || lpad(CAST(reca.new_student_index as varchar), 4, '0');
		UPDATE sessions SET new_student_index = new_student_index + 1 WHERE (session_id = reca.session_id);

		INSERT INTO students (org_id, student_id, studentname, surname, first_name, other_names,
			department_id, denomination_id, sex, 
			Marital_Status, birth_date, address, zip_code, town, telno, email,
			nationality, country_code_id, g_country_code_id, picture_file,
			accountnumber, Etranzact_card_no, state_id)
		VALUES (myrec.org_id, new_id, full_name, myrec.surname, myrec.first_name, myrec.other_names,
			myrec.department_id, myrec.denomination_id, myrec.sex, 
			myrec.Marital_Status, myrec.birth_date, 
			myrec.address, myrec.zip_code, myrec.town, myrec.phone_number, myrec.email,
			myrec.nationality_id, myrec.nationality_id, myrec.nationality_id, myrec.picture_file,
			myrec.account_number, myrec.e_tranzact_no, myrec.birth_state_id);

		INSERT INTO sys_emailed (org_id, sys_email_id, table_id, table_name)
		VALUES(myrec.org_id, 7, myrec.registration_id, 'registrations');

		INSERT INTO studentdegrees (org_id, degree_id, sublevelid, student_id, started, bulletingsid)
		VALUES (myrec.org_id, 'B.A',  'UNDM', new_id, current_date, 0);

		v_degree_id = currval('studentdegrees_studentdegree_id_seq');

		INSERT INTO studentmajors (org_id, studentdegree_id, major_id, major, nondegree, premajor, primarymajor)
		VALUES (myrec.org_id, v_degree_id, myrec.major_id, true, false, false, true);

		UPDATE registrations SET existing_id = new_id
		WHERE (registrations.registration_id = myrec.registration_id);

		msg := full_name || ' matric number : ' || new_id || ' password : ' || genfirstpass;
	ELSE
		msg := myrec.existing_id;
	END IF;

    RETURN msg;
END;
$$ LANGUAGE plpgsql;


