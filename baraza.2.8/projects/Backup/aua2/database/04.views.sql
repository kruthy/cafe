
-- view linking departments to schools--
CREATE VIEW vw_departments AS
	SELECT schools.school_id, schools.school_name, departments.department_id, departments.department_name,
		departments.philosopy, departments.vision, departments.mission, departments.objectives,
		departments.exposures, departments.oppotunities, departments.details
	FROM schools 
		INNER JOIN departments ON schools.school_id = departments.school_id
	ORDER BY departments.school_id;
	
--linking denominations to religions--
CREATE VIEW vw_denominations AS
	SELECT religions.religion_id, religions.religion_name, religions.details as religion_details,
		denominations.denomination_id, denominations.denomination_name, denominations.details as denomination_details
	FROM religions 
		INNER JOIN denominations ON religions.religion_id = denominations.religion_id;
		
--- view divisions of the degree levels on location {nairobi, eldoret} and specialisations like nursing
CREATE VIEW vw_sub_levels AS
	SELECT degree_levels.degree_level_id, degree_levels.degree_level_name,
		degree_levels.freshman, degree_levels.sophomore, degree_levels.junior, degree_levels.senior,
		level_locations.level_location_id, level_locations.level_location_name,
		sub_levels.org_id, sub_levels.sub_level_id, sub_levels.sub_level_name, sub_levels.special_charges, 
		sub_levels.unit_charge, sub_levels.lab_charges, sub_levels.exam_fees, sub_levels.general_fees,
		sub_levels.details
	FROM sub_levels
		INNER JOIN degree_levels ON sub_levels.degree_level_id = degree_levels.degree_level_id
		LEFT JOIN level_locations ON sub_levels.level_location_id = level_locations.level_location_id;

--view degree and their levels--	
CREATE VIEW vw_degrees AS
	SELECT degree_levels.degree_level_id, degree_levels.degree_level_name, degrees.degree_id, degrees.degree_name, degrees.details
	FROM degree_levels
		INNER JOIN degrees ON degree_levels.degree_level_id = degrees.degree_level_id;

--view existing residential areas with their respective locations--	
CREATE VIEW vw_residences AS
	SELECT level_locations.level_location_id, level_locations.level_location_name, 
		residences.residence_id, residences.residence_name, residences.capacity, residences.room_size,
		residences.default_rate, residences.off_campus, residences.Sex, residences.residence_dean, residences.details
	FROM residences 
		LEFT JOIN level_locations ON level_locations.level_location_id = residences.level_location_id;

--view instructors in a school and their departments--	
CREATE VIEW vw_instructors AS
	SELECT instructors.org_id,vw_departments.school_id, vw_departments.school_name, vw_departments.department_id, vw_departments.department_name,
		entitys.entity_id,entitys.entity_name,instructor_groups.instructor_group_id,instructor_groups.instructor_group_name,instructor_groups.details,
		instructors.instructor_id, instructors.instructor_name,sys_countrys.sys_country_id,sys_countrys.sys_country_name, instructors.post_office_box,
		 instructors.postal_code, instructors.premises, instructors.street, instructors.town, instructors.phone_number,
		instructors.mobile, instructors.email

	FROM vw_departments 
		INNER JOIN instructors ON vw_departments.department_id = instructors.department_id
		INNER JOIN entitys ON entitys.entity_id = instructors.entity_id
		LEFT JOIN sys_countrys ON sys_countrys.sys_country_id=instructors.sys_country_id
		LEFT JOIN instructor_groups ON instructor_groups.instructor_group_id = instructors.instructor_group_id;


--view courses details --	
CREATE VIEW vw_courses AS
	SELECT vw_departments.school_id, vw_departments.school_name, vw_departments.department_id, vw_departments.department_name,
		degree_levels.degree_level_id, degree_levels.degree_level_name, course_types.course_type_id, course_types.course_type_name,
		courses.course_id, courses.course_title,courses.lab_course, courses.min_credit, courses.max_credit, courses.lecture_hours, courses.practical_hours,
		courses.credit_hours, courses.is_current, courses.no_gpa, courses.no_repeats,courses.extra_charge,
		courses.year_taken,courses.details,course_modes.course_mode_id, course_modes.course_mode_name
	
	FROM ((vw_departments
		INNER JOIN courses ON vw_departments.department_id = courses.department_id)
		INNER JOIN degree_levels ON courses.degree_level_id = degree_levels.degree_level_id)
		INNER JOIN course_types ON courses.course_type_id = course_types.course_type_id
		INNER JOIN course_modes ON course_modes.course_mode_id=courses.course_mode_id;
	
--prereq view--	
CREATE VIEW vw_prereq AS
	SELECT courses.course_id, courses.course_title, prerequisites.prerequisite_id,  prerequisites.precourse_id, 
		prerequisites.option_level, prerequisites.narrative, grades.grade_id, grades.grade_weight,
		bulletings.bulletings_id, bulletings.bulletings_name, bulletings.starting_session, bulletings.ending_session
	FROM ((courses INNER JOIN prerequisites ON courses.course_id = prerequisites.course_id)
		INNER JOIN grades ON prerequisites.grade_id = grades.grade_id)
		INNER JOIN bulletings ON prerequisites.bulletings_id = bulletings.bulletings_id;
		
--prerequisite view--	
CREATE VIEW vw_prerequisite AS
	SELECT courses.course_id as precourse_id, courses.course_title as precourse_title,
		vw_prereq.course_id, vw_prereq.course_title,  vw_prereq.prerequisite_id,  
		vw_prereq.option_level, vw_prereq.narrative, vw_prereq.grade_id, vw_prereq.grade_weight,
		vw_prereq.bulletings_id, vw_prereq.bulletings_name, vw_prereq.starting_session, vw_prereq.ending_session
	FROM courses 
		INNER JOIN vw_prereq ON courses.course_id = vw_prereq.precourse_id
	ORDER BY vw_prereq.course_id, vw_prereq.option_level;

--view major details--
CREATE VIEW vw_majors AS
	SELECT vw_departments.school_id, vw_departments.school_name, vw_departments.department_id,
		 vw_departments.department_name,
		majors.major_id, majors.major_name, majors.major, majors.minor, majors.full_credit,majors.elective_credit,majors.minor_elective_credit,
		 majors.major_minimal, majors.minor_minimum,majors.core_minimum,majors.details
	FROM vw_departments 
		INNER JOIN majors ON vw_departments.department_id = majors.department_id;	
		
--view major options details--
CREATE VIEW vw_major_options AS
	SELECT vw_majors.school_id, vw_majors.school_name, vw_majors.department_id, vw_majors.department_name,
		vw_majors.major_id, vw_majors.major_name, vw_majors.major, vw_majors.minor, vw_majors.full_credit,vw_majors.elective_credit,
		vw_majors.minor_elective_credit,
		vw_majors.major_minimal, vw_majors.minor_minimum,vw_majors.core_minimum,vw_majors.details as major_details,
		major_options.major_option_id, major_options.major_option_name, major_options.details
	FROM vw_majors 
		INNER JOIN major_options ON vw_majors.major_id = major_options.major_id;
	
--requirements view--
CREATE VIEW vw_requirements AS
	SELECT vw_majors.school_id, vw_majors.department_id, vw_majors.department_name, vw_majors.major_id, vw_majors.major_name, 
		subjects.subject_id, subjects.subject_name, marks.mark_id,marks.grade, requirements.requirement_id, requirements.narrative
	FROM ((vw_majors 
	
			INNER JOIN requirements ON vw_majors.major_id = requirements.major_id)
			INNER JOIN subjects ON requirements.subject_id = subjects.subject_id)
		INNER JOIN marks ON requirements.mark_id = marks.mark_id;
		
--view contents of a major --
CREATE VIEW vw_major_contents AS
	SELECT vw_majors.school_id, vw_majors.department_id, vw_majors.department_name, vw_majors.major_id, vw_majors.major_name, 
		vw_majors.elective_credit, courses.course_id, courses.course_title, courses.credit_hours, courses.no_gpa, 
		courses.year_taken, courses.details as course_details,
		content_types.content_type_id, content_types.content_type_name, content_types.elective, content_types.prerequisite,
		content_types.pre_major, major_contents.major_content_id, major_contents.minor, major_contents.grade_id, major_contents.narrative,
		bulletings.bulletings_id, bulletings.bulletings_name, bulletings.starting_session, bulletings.ending_session,
		bulletings.active
	FROM (((vw_majors 
			INNER JOIN major_contents ON vw_majors.major_id = major_contents.major_id)
			INNER JOIN courses ON major_contents.course_id = courses.course_id)
			INNER JOIN content_types ON major_contents.content_type_id = content_types.content_type_id)
		INNER JOIN bulletings ON major_contents.bulletings_id = bulletings.bulletings_id;
	

----view sponsors details---
CREATE VIEW vw_sponsors AS
	SELECT sponsor_types.sponsor_type_id, sponsor_types.sponsor_type_name, sponsors.sponsor_id,entitys.entity_id, sponsors.org_id,
		entitys.entity_name,sponsors.sponsor_name, sponsors.address, sponsors.street, sponsors.postal_code,
		sponsors.town, sponsors.telno, sponsors.email, sponsors.active, sponsors.details,
		sys_countrys.sys_country_id, sys_countrys.sys_country_name
	FROM sponsor_types
		INNER JOIN sponsors ON sponsor_types.sponsor_type_id = sponsors.sponsor_type_id
		INNER JOIN entitys ON sponsors.entity_id = entitys.entity_id
		INNER JOIN sys_countrys ON sys_countrys.sys_country_id = sponsors.sys_country_id;


--view students details--
CREATE VIEW vw_students AS
	SELECT vw_denominations.religion_id, vw_denominations.religion_name, vw_denominations.denomination_id, vw_denominations.denomination_name,
		vw_sponsors.sponsor_type_id, vw_sponsors.sponsor_type_name, vw_sponsors.sponsor_id, vw_sponsors.sponsor_name,
		vw_sponsors.address as sponsor_address, vw_sponsors.street as sponsor_street, vw_sponsors.postal_code as sponsor_postal_code,
		vw_sponsors.town as sponsor_town, vw_sponsors.telno as sponsor_telno, vw_sponsors.email as sponsor_email, 
		vw_sponsors.sys_country_id as sponsor_country_id, vw_sponsors.sys_country_name as sponsor_country_name,
		residences.residence_id, residences.residence_name,
		schools.school_id, schools.school_name, c1.sys_country_name as address_country, 
		students.org_id, students.student_id, students.student_name,students.room_number, students.address, students.zipcode, students.town,
		students.telno, students.email, 
		students.account_number,students.admission_basis, students.Nationality, c3.sys_country_name as nationality_country, students.Sex,
		students.marital_status, students.birth_date, students.alumnae, students.post_contacts, 
		students.on_probation, students.off_campus, students.current_contact, students.current_email, students.current_tel,
		students.full_bursary, students.details,students.staff,students.onhold,students.student_edit,students.disabilitys_details,students.passport,
		students.national_id,students.identification_no,students.picture_file,students.balance_time,students.curr_balance,
		 students.probation_details
	FROM ((((vw_denominations 
			INNER JOIN students ON vw_denominations.denomination_id = students.denomination_id)
			LEFT JOIN schools ON students.school_id = schools.school_id)
		  	INNER JOIN vw_sponsors ON students.sponsor_id=vw_sponsors.sponsor_id)
			LEFT JOIN residences ON students.residence_id = residences.residence_id)
		LEFT JOIN sys_countrys as c1 ON students.country_code_id = c1.sys_country_id
		LEFT JOIN sys_countrys as c3 ON students.Nationality = c3.sys_country_id;

--view students degrees details--
CREATE VIEW vw_student_degrees AS
	SELECT vw_students.religion_id, vw_students.religion_name, vw_students.denomination_id, vw_students.denomination_name,
		vw_students.sponsor_type_id, vw_students.sponsor_type_name, vw_students.sponsor_id, vw_students.sponsor_name,
		vw_students.sponsor_address, vw_students.sponsor_street, vw_students.sponsor_postal_code,
		vw_students.sponsor_town, vw_students.sponsor_telno, vw_students.sponsor_email, 
		vw_students.sponsor_country_id, vw_students.sponsor_country_name,
		vw_students.school_id, vw_students.school_name, vw_students.student_id, vw_students.student_name, vw_students.address, vw_students.zipcode,
		vw_students.town, vw_students.address_country, vw_students.telno, vw_students.email, vw_students.staff,vw_students.onhold,
		vw_students.student_edit,vw_students.disabilitys_details,vw_students.passport,
		vw_students.national_id,vw_students.identification_no,vw_students.picture_file,vw_students.balance_time,vw_students.curr_balance,
		vw_students.account_number, vw_students.Nationality, vw_students.nationality_country, vw_students.Sex,
		vw_students.marital_status, vw_students.birth_date, vw_students.alumnae, vw_students.post_contacts,
		vw_students.on_probation, vw_students.off_campus, vw_students.current_contact, vw_students.current_email, vw_students.current_tel,
		vw_students.org_id, 
		vw_sub_levels.degree_level_id, vw_sub_levels.degree_level_name,
		vw_sub_levels.freshman, vw_sub_levels.sophomore, vw_sub_levels.junior, vw_sub_levels.senior,
		vw_sub_levels.level_location_id, vw_sub_levels.level_location_name,
		vw_sub_levels.sub_level_id, vw_sub_levels.sub_level_name, vw_sub_levels.special_charges,
		degrees.degree_id, degrees.degree_name,
		student_degrees.student_degree_id, student_degrees.completed, student_degrees.started, student_degrees.cleared, student_degrees.clear_date,
		student_degrees.graduated, student_degrees.graduate_date,student_degrees.graduation_apply, student_degrees.drop_out, student_degrees.transfer_in, student_degrees.transfer_out,
		student_degrees.details
	FROM ((vw_students 
			INNER JOIN student_degrees ON vw_students.student_id = student_degrees.student_id)
			LEFT JOIN vw_sub_levels ON student_degrees.sub_level_id = vw_sub_levels.sub_level_id)
		INNER JOIN degrees ON student_degrees.degree_id = degrees.degree_id;


CREATE VIEW vw_sessions AS
	SELECT sessions.session_id, sessions.session_start, sessions.slate_reg, sessions.slate_change, sessions.slast_drop,
		sessions.session_end, sessions.active, sessions.charge_rate, 
		sessions.session_name,sessions.details,
		
		SUBSTRING(sessions.session_id from 1 for 9)  AS session_year,
		trim(SUBSTRING(sessions.session_id from 1 for 9)) AS sessions
	FROM sessions
	ORDER BY session_id desc;
	

--view residence details for the session--
CREATE VIEW vw_sresidences AS
	SELECT residences.residence_id, residences.residence_name, residences.capacity, residences.default_rate,
		residences.off_campus, residences.Sex, residences.residence_dean,
		vw_sessions.session_year, vw_sessions.sessions, vw_sessions.active,vw_sessions.session_name,
		sresidences.org_id, sresidences.sresidence_id, sresidences.session_id, sresidences.residence_option,
		sresidences.charges, sresidences.details
	FROM (residences 
			INNER JOIN sresidences ON residences.residence_id = sresidences.residence_id)
		INNER JOIN vw_sessions ON sresidences.session_id = vw_sessions.session_id;

--view students session degrees details----
CREATE VIEW vw_sstudent_degrees AS
	SELECT students.student_id, students.school_id, students.student_name, students.Sex, students.Nationality, students.Marital_Status,
		students.birth_date, students.email, student_degrees.student_degree_id, student_degrees.degree_id,
		sub_levels.sub_level_id, sub_levels.degree_level_id, sub_levels.level_location_id, sub_levels.sub_level_name, sub_levels.special_charges,
		sstudents.org_id, sstudents.sstudent_id, sstudents.session_id, sstudents.scharge_id,sstudents.extra_charges, 
		sstudents.probation, sstudents.room_number, sstudents.curr_balance, sstudents.application_time, 
		sstudents.finalised, sstudents.finance_approval, sstudents.major_approval, sstudents.student_dean_approval, 
		sstudents.overload_approval, sstudents.overload_hours, sstudents.inter_session, sstudents.approved, sstudents.no_approval,
		sstudents.exam_clear, sstudents.exam_clear_date, sstudents.exam_clear_balance,
		vw_sresidences.residence_id, vw_sresidences.residence_name, vw_sresidences.capacity, vw_sresidences.default_rate,
		vw_sresidences.off_campus, vw_sresidences.Sex as residence_sex, vw_sresidences.residence_dean, vw_sresidences.charges as residence_charges,
		vw_sresidences.sresidence_id, vw_sresidences.residence_option, (vw_sresidences.sresidence_id || 'R' || sstudents.room_number) as room_id,
		vw_sresidences.session_name
				  
	FROM (((students INNER JOIN (student_degrees LEFT JOIN sub_levels ON student_degrees.sub_level_id = sub_levels.sub_level_id) ON students.student_id = student_degrees.student_id)
		INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id)
		INNER JOIN vw_sresidences ON sstudents.sresidence_id = vw_sresidences.sresidence_id);

--view students transcript print details --
CREATE VIEW vw_transcript_prints AS
	SELECT entitys.entity_id, entitys.entity_name, entitys.user_name, transcript_print.transcript_print_id, 
		transcript_print.student_degree_id, transcript_print.print_date, transcript_print.narrative,
		transcript_print.ip_address, transcript_print.accepted
	FROM transcript_print
		INNER JOIN entitys ON transcript_print.entity_id = entitys.entity_id; 
	
--view students majors details --
CREATE VIEW vw_student_majors AS 
	SELECT vw_student_degrees.religion_id, vw_student_degrees.religion_name, vw_student_degrees.denomination_id, vw_student_degrees.denomination_name,
		vw_student_degrees.school_id as student_school_id, vw_student_degrees.school_name as student_school_name, vw_student_degrees.student_id,
		vw_student_degrees.student_name, vw_student_degrees.Nationality, vw_student_degrees.nationality_country, vw_student_degrees.Sex,
		vw_student_degrees.marital_status, vw_student_degrees.birth_date, 
		vw_student_degrees.degree_level_id, vw_student_degrees.degree_level_name,
		vw_student_degrees.freshman, vw_student_degrees.sophomore, vw_student_degrees.junior, vw_student_degrees.senior,
		vw_student_degrees.level_location_id, vw_student_degrees.level_location_name,
		vw_student_degrees.sub_level_id, vw_student_degrees.sub_level_name, vw_student_degrees.special_charges,
		vw_student_degrees.degree_id, vw_student_degrees.degree_name,
		vw_student_degrees.student_degree_id, vw_student_degrees.completed, vw_student_degrees.started, vw_student_degrees.cleared, vw_student_degrees.clear_date,
		vw_student_degrees.graduated, vw_student_degrees.graduate_date, vw_student_degrees.drop_out, vw_student_degrees.transfer_in, vw_student_degrees.transfer_out,
		vw_majors.school_id, vw_majors.school_name, vw_majors.department_id, vw_majors.department_name,
		vw_majors.major_id, vw_majors.major_name, vw_majors.major as do_major, vw_majors.minor as do_minor,
		vw_majors.elective_credit, vw_majors.major_minimal, vw_majors.minor_minimum, vw_majors.core_minimum,
		student_majors.student_major_id, student_majors.major, student_majors.non_degree, student_majors.pre_major, 
		student_majors.primary_major, student_majors.details
	FROM ((vw_student_degrees
			INNER JOIN student_majors ON vw_student_degrees.student_degree_id = student_majors.student_degree_id)
		INNER JOIN vw_majors ON student_majors.major_id = vw_majors.major_id);
	
	---view transfered credits---------
CREATE VIEW vw_transfered_credits AS 
	SELECT 
		student_degrees.student_degree_id, student_degrees.completed, student_degrees.started, student_degrees.cleared, student_degrees.clear_date,
		student_degrees.graduated, student_degrees.graduate_date, student_degrees.drop_out,student_degrees.student_id, student_degrees.transfer_in,student_degrees.graduation_apply, student_degrees.transfer_out,
		student_degrees.details, 
		transfered_credits.transfered_credit_id,transfered_credits.course_id,transfered_credits.credit_hours,transfered_credits.narrative,courses.course_title, degrees.degree_name
	FROM student_degrees
		INNER JOIN transfered_credits ON student_degrees.student_degree_id=transfered_credits.student_degree_id
		INNER JOIN degrees ON (student_degrees.student_degree_id)::character varying=degrees.degree_id
		INNER JOIN courses ON (student_degrees.student_degree_id)::character varying =degrees.degree_id
		INNER JOIN degree_levels ON courses.degree_level_id=degrees.degree_level_id;

	
	--view  primary_majors--
CREATE VIEW vw_primary_majors AS
	SELECT schools.school_id, schools.school_name, departments.department_id, departments.department_name, 
		majors.major_id, majors.major_name, student_majors.student_degree_id	
	FROM ((schools 
			INNER JOIN departments ON schools.school_id = departments.school_id) 
			INNER JOIN majors ON departments.department_id = majors.department_id)
		INNER JOIN student_majors ON majors.major_id = student_majors.major_id
	WHERE (student_majors.major = true) AND (student_majors.primary_major = true); 

	--view students primajors for continuing students--
CREATE VIEW vw_students_primary_majors AS
	SELECT students.org_id, students.student_id, students.student_name, students.account_number, students.Nationality, 
		students.sex, students.marital_status, students.birth_date, students.on_probation, students.off_campus,
		student_degrees.student_degree_id, student_degrees.completed, student_degrees.started, student_degrees.graduated,
		vw_primary_majors.school_id, vw_primary_majors.school_name, vw_primary_majors.department_id, vw_primary_majors.department_name, 
		vw_primary_majors.major_id, vw_primary_majors.major_name
	FROM (students 
			INNER JOIN student_degrees ON students.student_id = student_degrees.student_id)
		INNER JOIN vw_primary_majors ON student_degrees.student_degree_id = vw_primary_majors.student_degree_id
	WHERE (student_degrees.completed = false);


	
	--view major opt_contents--
CREATE VIEW vw_major_opt_contents AS
	SELECT major_options.major_option_id, major_options.major_id, major_options.major_option_name,
		courses.course_id, courses.course_title, courses.credit_hours, courses.no_gpa, 
		courses.year_taken, courses.details as course_details,
		content_types.content_type_id, content_types.content_type_name, content_types.elective, content_types.prerequisite, content_types.pre_major,
		major_opt_contents.major_opt_content_id, major_opt_contents.minor, major_opt_contents.grade_id, major_opt_contents.narrative,
		bulletings.bulletings_id, bulletings.bulletings_name, bulletings.starting_session, bulletings.ending_session,
		bulletings.active
	FROM (((major_options 
			INNER JOIN major_opt_contents ON major_options.major_option_id = major_opt_contents.major_option_id)
			INNER JOIN courses ON major_opt_contents.course_id = courses.course_id)
			INNER JOIN content_types ON major_opt_contents.content_type_id = content_types.content_type_id)
		INNER JOIN bulletings ON major_opt_contents.bulletings_id = bulletings.bulletings_id;


	--view student requests---	
CREATE VIEW vw_student_requests AS
	SELECT students.student_id, students.student_name, request_types.request_type_id, request_types.request_type_name, request_types.to_approve,
		request_types.details as type_details, 
		student_requests.org_id, student_requests.student_request_id, student_requests.narrative, student_requests.date_sent,
		student_requests.actioned, student_requests.date_actioned, student_requests.approved, student_requests.date_apploved,
		student_requests.details, student_requests.reply
	FROM (students 
			INNER JOIN student_requests ON students.student_id = student_requests.student_id)
		INNER JOIN request_types ON student_requests.request_type_id = request_types.request_type_id;



--view Active sessions--
CREATE VIEW vw_active_sessions AS
	SELECT session_id, session_year, session_start, slate_reg, slate_change, session_name,
		slast_drop, session_end, active, charge_rate, details
	FROM vw_sessions
	WHERE (active = true);
	
--view session years--
CREATE VIEW vw_years AS
	SELECT session_year
	FROM vw_sessions
	GROUP BY session_year
	ORDER BY session_year desc;
	
--view session calendars--
CREATE VIEW vw_scalendars AS
	SELECT vw_sub_levels.degree_level_id, vw_sub_levels.degree_level_name, vw_sub_levels.sub_level_id, vw_sub_levels.sub_level_name,
		scalendars.org_id, scalendars.scalendar_id, scalendars.session_id, scalendars.sdate, scalendars.event, scalendars.details
	FROM vw_sub_levels
	INNER JOIN scalendars ON vw_sub_levels.sub_level_id = scalendars.sub_level_id;
	

	--view scharges--
CREATE VIEW vw_scharges AS
	SELECT vw_sessions.session_id, vw_sessions.session_start, vw_sessions.slate_reg, vw_sessions.slate_change, vw_sessions.slast_drop,
		vw_sessions.session_end, vw_sessions.active, vw_sessions.charge_rate, vw_sessions.session_name, vw_sessions.session_year, vw_sessions.sessions, 

		degree_levels.degree_level_id, degree_levels.degree_level_name, 
		level_locations.level_location_id, level_locations.level_location_name, 

		sub_levels.sub_level_id, sub_levels.sub_level_name, sub_levels.special_charges,

		scharges.org_id, scharges.scharge_id, scharges.session_active, scharges.session_closed, scharges.exam_balances, 
		scharges.sun_posted, scharges.unit_charge, scharges.lab_charges, scharges.exam_fees, scharges.general_fees, 
		scharges.residence_stay, scharges.exchange_rate, scharges.narrative		
	FROM vw_sessions
		INNER JOIN scharges ON vw_sessions.session_id = scharges.session_id
		LEFT JOIN sub_levels ON scharges.sub_level_id = sub_levels.sub_level_id
		LEFT JOIN degree_levels ON sub_levels.degree_level_id = degree_levels.degree_level_id
		LEFT JOIN level_locations ON sub_levels.level_location_id = level_locations.level_location_id;

--view scholarships---
CREATE VIEW vw_scholarships AS
	SELECT students.student_id, students.student_name, students.account_number, students.Nationality, students.Sex,
		scholarship_types.scholarship_type_id, scholarship_types.scholarship_type_name, scholarship_types.scholarship_account,
		scholarships.session_id, scholarships.scholarship_id, scholarships.entry_date, scholarships.payment_date,
		scholarships.amount, scholarships.approved, scholarships.posted, scholarships.date_posted
	FROM (students
		 INNER JOIN scholarships ON students.student_id = scholarships.student_id)
	INNER JOIN scholarship_types ON scholarships.scholarship_type_id = scholarship_types.scholarship_type_id;
SELECT *FROM scholarships

---view approval lists---
CREATE VIEW vw_approval_lists AS 
		SELECT vw_students.student_id,vw_students.student_name,approval_list.approval_id, approval_list.approval_type_id,
		approval_list.sstudent_id,approval_types.is_active,approval_types.approval_order,approval_types.details,approval_types.approval_type_name,
		approval_list.approved_by,
		approval_list.approval_type,approval_list.approve_date,approval_list.client_ip
		FROM vw_students
		INNER JOIN approval_list ON vw_students.student_id=approval_list.student_id
		INNER JOIN approval_types ON approval_list.approval_type_id=approval_types.approval_type_id;


	--view  courses available for the session--

CREATE VIEW vw_scourses AS
	SELECT vw_courses.school_id, vw_courses.school_name, vw_courses.department_id, vw_courses.department_name,
		vw_courses.degree_level_id, vw_courses.degree_level_name, vw_courses.course_type_id, vw_courses.course_type_name,
		vw_courses.course_id,vw_courses.course_title, vw_courses.credit_hours, vw_courses.max_credit, vw_courses.is_current,
		vw_courses.no_gpa, vw_courses.year_taken,
		vw_courses.details,
		
		scourses.org_id, scourses.instructor_id, instructors.instructor_name,scourses.scourse_id, scourses.class_option, scourses.max_class,
		scourses.lab_course, scourses.clinical_fee, scourses.extra_charge, 
		 scourses.department_submit, scourses.department_submit_date, scourses.faculty_submit, scourses.faculty_submit_date, 
		scourses.attendance, scourses.approved, 
		scourses.full_attendance, scourses.attachement, scourses.submit_grades, scourses.submit_date,
		scourses.approved_grades, scourses.approve_date, scourses.exam_submited, scourses.examinable,
		scourses.department_change, scourses.registry_change, scourses.grade_submited,
		
		vw_sessions.session_id, vw_sessions.session_start, vw_sessions.slate_reg, vw_sessions.slate_change, vw_sessions.slast_drop,
		vw_sessions.session_end, vw_sessions.active, vw_sessions.charge_rate,  
		vw_sessions.session_name, vw_sessions.session_year, vw_sessions.sessions, 

		level_locations.level_location_id, level_locations.level_location_name
	FROM (((vw_courses 
			INNER JOIN scourses ON vw_courses.course_id = scourses.course_id)
			INNER JOIN instructors ON scourses.instructor_id = (instructors.instructor_id))
		INNER JOIN vw_sessions ON scourses.session_id = vw_sessions.session_id)
		LEFT JOIN level_locations ON scourses.level_location_id = level_locations.level_location_id;

--view students sessions detail--
CREATE VIEW vw_sstudents AS
	SELECT vw_student_degrees.religion_id, vw_student_degrees.religion_name, vw_student_degrees.denomination_id, 
		vw_student_degrees.denomination_name,
		vw_student_degrees.sponsor_type_id, vw_student_degrees.sponsor_type_name, vw_student_degrees.sponsor_id, vw_student_degrees.sponsor_name,
		vw_student_degrees.sponsor_address, vw_student_degrees.sponsor_street, vw_student_degrees.sponsor_postal_code,
		vw_student_degrees.sponsor_town, vw_student_degrees.sponsor_telno, vw_student_degrees.sponsor_email, 
		vw_student_degrees.sponsor_country_id, vw_student_degrees.sponsor_country_name,
		vw_student_degrees.school_id, vw_student_degrees.school_name, vw_student_degrees.student_id, vw_student_degrees.student_name, vw_student_degrees.address, vw_student_degrees.zipcode,
		vw_student_degrees.town, vw_student_degrees.address_country, vw_student_degrees.telno, vw_student_degrees.email,
		vw_student_degrees.account_number, vw_student_degrees.Nationality, vw_student_degrees.nationality_country, vw_student_degrees.Sex,
		vw_student_degrees.marital_status, vw_student_degrees.birth_date, vw_student_degrees.alumnae, vw_student_degrees.post_contacts,
		vw_student_degrees.on_probation, vw_student_degrees.off_campus, vw_student_degrees.current_contact, vw_student_degrees.current_email, vw_student_degrees.current_tel,
		vw_student_degrees.freshman, vw_student_degrees.sophomore, vw_student_degrees.junior, vw_student_degrees.senior,
		vw_student_degrees.degree_id, vw_student_degrees.degree_name,
		vw_student_degrees.student_degree_id, vw_student_degrees.completed, vw_student_degrees.started, vw_student_degrees.cleared, vw_student_degrees.clear_date,
		vw_student_degrees.graduated, vw_student_degrees.graduate_date, vw_student_degrees.drop_out, vw_student_degrees.transfer_in, vw_student_degrees.transfer_out,
		
		

		vw_scharges.session_id, vw_scharges.session_start, vw_scharges.slate_reg, vw_scharges.slate_change, 
		vw_scharges.slast_drop, vw_scharges.session_end, vw_scharges.active, vw_scharges.charge_rate, 
		vw_scharges.session_year, vw_scharges.sessions, 
		vw_scharges.session_name, vw_scharges.degree_level_id, vw_scharges.degree_level_name, 
		vw_scharges.scharge_id,vw_scharges.lab_charges, vw_scharges.exam_fees, 
		vw_scharges.level_location_id, vw_scharges.level_location_name, 
		vw_scharges.sub_level_id, vw_scharges.sub_level_name,vw_scharges.special_charges,
		vw_scharges.sun_posted, vw_scharges.session_active,
		vw_scharges.session_closed, vw_scharges.general_fees, vw_scharges.residence_stay,
		vw_scharges.exchange_rate,
		
		vw_sresidences.residence_id, vw_sresidences.residence_name, vw_sresidences.capacity, vw_sresidences.default_rate,
		vw_sresidences.off_campus AS residence_off_campus, vw_sresidences.Sex AS residence_sex, vw_sresidences.residence_dean,
		vw_sresidences.sresidence_id, vw_sresidences.residence_option,  
		
		sstudents.org_id, sstudents.sstudent_id, sstudents.extra_charges AS additional_charges, sstudents.probation,
		sstudents.room_number, sstudents.curr_balance,  sstudents.major_approval, 
		sstudents.exam_clear, sstudents.exam_clear_date, sstudents.exam_clear_balance,sstudents.inter_session,
		sstudents.request_withdraw, sstudents.request_withdraw_date, sstudents.withdraw, sstudents.ac_withdraw,
		sstudents.withdraw_date, sstudents.withdraw_rate, sstudents.approved,sstudents.no_approval,sstudents.study_level,
		sstudents.overload_approval, sstudents.finalised, sstudents.student_dean_approval, sstudents.chaplain_approval,sstudents.depart_approval,
		sstudents.details,sstudents.finance_approval,sstudents.hours,
		sstudents.first_instalment,sstudents.first_date,sstudents.second_instalment,sstudents.second_date,sstudents.LRF_picked,sstudents.LRF_picked_date,



		vw_scharges.unit_charge AS unit_charges, (vw_scharges.residence_stay * vw_sresidences.charges / 100) AS residence_charge,
		vw_scharges.lab_charges as lab_charge, vw_scharges.general_fees AS fees_charge
	FROM (((vw_student_degrees 
			INNER JOIN sstudents ON vw_student_degrees.student_degree_id = sstudents.student_degree_id)
			LEFT JOIN vw_scharges ON sstudents.scharge_id = vw_scharges.scharge_id)
			INNER JOIN vw_sresidences ON sstudents.sresidence_id = vw_sresidences.sresidence_id);	
		
--view a list of students in a session--

CREATE VIEW vw_sstudent_list AS
	SELECT students.student_id, students.school_id, students.student_name, students.Sex, students.Nationality, students.marital_status,
		students.birth_date, students.email, student_degrees.student_degree_id, student_degrees.degree_id, student_degrees.sub_level_id,
		sstudents.sstudent_id, sstudents.session_id, sstudents.extra_charges, sstudents.probation,
		sstudents.room_number, sstudents.curr_balance, 
		sstudents.first_instalment, sstudents.first_date, sstudents.second_instalment, sstudents.second_date,
		sstudents.finance_narrative,  sstudents.fee_refund, sstudents.finalised,
		sstudents.major_approval, sstudents.overload_approval, 
		sstudents.overload_hours,  
		SUBSTRING(sstudents.session_id from 1 for 9) as academic_year
	FROM (students 
			INNER JOIN student_degrees ON students.student_id = student_degrees.student_id)
		INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id;
	


---view course load----

CREATE VIEW vw_course_load AS
	SELECT vw_scourses.school_id, vw_scourses.school_name, vw_scourses.department_id, vw_scourses.department_name,
		vw_scourses.degree_level_id, vw_scourses.degree_level_name, vw_scourses.course_type_id, vw_scourses.course_type_name,
		vw_scourses.course_id, vw_scourses.credit_hours, vw_scourses.max_credit, vw_scourses.is_current,
		vw_scourses.no_gpa, vw_scourses.year_taken, 

		vw_scourses.org_id, vw_scourses.instructor_id, vw_scourses.scourse_id, vw_scourses.class_option, vw_scourses.max_class,
		vw_scourses.lab_course, vw_scourses.clinical_fee, vw_scourses.extra_charge, 
		vw_scourses.approved, vw_scourses.attendance,
		vw_scourses.full_attendance, vw_scourses.attachement, vw_scourses.submit_grades, vw_scourses.submit_date,
		vw_scourses.approved_grades, vw_scourses.approve_date, vw_scourses.exam_submited, vw_scourses.examinable,
		vw_scourses.department_change, vw_scourses.registry_change,
		vw_scourses.instructor_name, vw_scourses.course_title,

		vw_scourses.session_id, vw_scourses.session_start, vw_scourses.slate_reg, vw_scourses.slate_change, vw_scourses.slast_drop,
		vw_scourses.session_end, vw_scourses.active, vw_scourses.charge_rate, 
		 vw_scourses.session_name, vw_scourses.session_year, vw_scourses.sessions, 

		vw_scourses.level_location_id, vw_scourses.level_location_name,
		a.course_load
	FROM vw_scourses INNER JOIN 
		(SELECT scourse_id, count(sgrade_id) as course_load FROM sgrades WHERE (dropped = false) GROUP BY scourse_id) as a
		ON vw_scourses.scourse_id = a.scourse_id;


--view session timetable--
CREATE VIEW vw_stimetables AS
	SELECT assets.asset_id, assets.asset_name, assets.location, assets.building, assets.capacity, 
		vw_scourses.scourse_id,vw_scourses.course_title, vw_scourses.course_id, vw_scourses.instructor_id,vw_scourses.instructor_name,
		vw_scourses.session_id, vw_scourses.max_class, vw_scourses.class_option,
		
		option_times.option_time_id, option_times.option_time_name,
		
		stimetables.org_id, stimetables.stimetable_id, stimetables.start_time, stimetables.end_time, stimetables.lab,
		stimetables.details, stimetables.c_monday, stimetables.c_tuesday, stimetables.c_wednesday, stimetables.c_thursday,
		stimetables.c_friday, stimetables.c_saturday, stimetables.c_sunday 
	FROM ((assets 
			INNER JOIN stimetables ON assets.asset_id = stimetables.asset_id)
			INNER JOIN vw_scourses ON stimetables.scourse_id = vw_scourses.scourse_id)
		INNER JOIN option_times ON stimetables.option_time_id = option_times.option_time_id
	ORDER BY stimetables.start_time;
	
	
--session exam timetables--
CREATE VIEW vw_sexam_timetables AS
	SELECT assets.asset_id, assets.asset_name, assets.location, assets.building, assets.capacity, 
		vw_scourses.scourse_id, vw_scourses.course_id,vw_scourses.course_title, vw_scourses.instructor_id,vw_scourses.instructor_name,
		vw_scourses.session_id, vw_scourses.max_class, vw_scourses.class_option,
		option_times.option_time_id, option_times.option_time_name,
		sexam_timetable.org_id, sexam_timetable.sexam_timetable_id, sexam_timetable.start_time, sexam_timetable.end_time, 
		sexam_timetable.lab, sexam_timetable.exam_date, sexam_timetable.details 
	FROM ((assets 
			INNER JOIN sexam_timetable ON assets.asset_id = sexam_timetable.asset_id)
			INNER JOIN vw_scourses ON sexam_timetable.scourse_id = vw_scourses.scourse_id)
		INNER JOIN option_times ON sexam_timetable.option_time_id = option_times.option_time_id
	ORDER BY sexam_timetable.exam_date, sexam_timetable.start_time;
	
	
--function returning time schedule for assests--
CREATE OR REPLACE FUNCTION get_time_asset_count(integer, time, time, boolean, boolean, boolean, boolean, boolean, boolean, boolean, varchar(12)) RETURNS bigint AS $$
	SELECT count(stimetable_id) FROM vw_stimetables
	WHERE (asset_id = $1) AND (((start_time, end_time) OVERLAPS ($2, $3))=true) 
	AND ((c_monday and $4) OR (c_tuesday and $5) OR (c_wednesday and $6) OR (c_thursday and $7) OR (c_friday and $8) OR (c_saturday and $9) OR (c_sunday and $10))
	AND (session_id = $11);
$$ LANGUAGE SQL;

--view assets time schedule--
CREATE VIEW vw_sasset_timetables AS
	SELECT asset_id, asset_name, location, building, capacity, scourse_id,course_title, course_id,  instructor_id, instructor_name,
		 session_id, max_class, class_option, option_time_id, option_time_name,
		stimetable_id, start_time, end_time, lab, details, c_monday, c_tuesday, c_wednesday, c_thursday,
		c_friday, c_saturday, c_sunday,
		get_time_asset_count(asset_id, start_time, end_time, c_monday, c_tuesday, c_wednesday, c_thursday, c_friday, c_saturday, c_sunday, session_id) as time_asset_count 
	FROM vw_stimetables
	ORDER BY asset_id;
	
--view current timetables--
CREATE VIEW vw_curr_timetables AS
	SELECT vw_stimetables.asset_id, vw_stimetables.asset_name, vw_stimetables.location, vw_stimetables.building, vw_stimetables.capacity, 
		vw_stimetables.scourse_id, vw_stimetables.course_id, vw_stimetables.course_title, vw_stimetables.instructor_id, vw_stimetables.instructor_name,
		vw_stimetables.session_id, vw_stimetables.max_class, vw_stimetables.class_option,
		vw_stimetables.option_time_id, vw_stimetables.option_time_name,
		vw_stimetables.org_id, vw_stimetables.stimetable_id, vw_stimetables.start_time, vw_stimetables.end_time, vw_stimetables.lab,
		vw_stimetables.details, vw_stimetables.c_monday, vw_stimetables.c_tuesday, vw_stimetables.c_wednesday, vw_stimetables.c_thursday,
		vw_stimetables.c_friday, vw_stimetables.c_saturday, vw_stimetables.c_sunday
	FROM vw_stimetables INNER JOIN sessions ON vw_stimetables.session_id = sessions.session_id 
	WHERE (sessions.active = false)
	ORDER BY vw_stimetables.start_time;
	
--view session course items--
CREATE VIEW vw_scourse_items AS
	SELECT vw_scourses.org_id, vw_scourses.scourse_id, vw_scourses.course_id, vw_scourses.course_title, 
		vw_scourses.session_id,vw_scourses.instructor_id,vw_scourses.instructor_name,
		vw_scourses.class_option, scourse_items.scourse_item_id, scourse_items.course_item_name, scourse_items.mark_ratio,
		scourse_items.total_marks, scourse_items.given, scourse_items.deadline, scourse_items.details
	FROM vw_scourses 
		INNER JOIN scourse_items ON vw_scourses.scourse_id = scourse_items.scourse_id;

		
--view session grades--
CREATE VIEW vw_sgrades AS
	SELECT vw_scourses.school_id, vw_scourses.school_name, vw_scourses.department_id, vw_scourses.department_name,
		vw_scourses.degree_level_id, vw_scourses.degree_level_name, vw_scourses.course_type_id, vw_scourses.course_type_name,
		 vw_scourses.credit_hours, vw_scourses.is_current,vw_scourses.year_taken,
		vw_scourses.no_gpa,vw_scourses.course_id, vw_scourses.course_title,
		
		vw_scourses.instructor_id,vw_scourses.instructor_name, vw_scourses.session_id, vw_scourses.scourse_id, vw_scourses.class_option, vw_scourses.max_class,
		vw_scourses.lab_course, vw_scourses.extra_charge, vw_scourses.clinical_fee,
		vw_scourses.attendance as crs_attendance, 
		vw_scourses.full_attendance, 
		vw_scourses.attachement, vw_scourses.examinable,
		vw_scourses.submit_grades, vw_scourses.submit_date, vw_scourses.approved_grades,
		vw_scourses.department_change, vw_scourses.registry_change,

		sgrades.org_id, sgrades.sgrade_id, sgrades.sstudent_id, sgrades.hours, sgrades.credit, sgrades.approved as crs_approved, sgrades.approve_date, sgrades.ask_drop,
		sgrades.ask_drop_date, sgrades.dropped, sgrades.drop_date, sgrades.repeated, sgrades.attendance, sgrades.narrative,
		sgrades.challenge_course, sgrades.non_gpa_course, sgrades.lecture_marks, sgrades.lecture_cat_mark,
		sgrades.lecture_grade_id,sgrades.withdraw_date,sgrades.record_posted,sgrades.post_changed,sgrades.changed_by,
		sgrades.request_drop, sgrades.request_drop_date, sgrades.withdraw_rate as course_withdraw_rate,
		
		grades.grade_id, grades.grade_weight,grades.grade_name, grades.min_range, grades.max_range, grades.gpa_count, grades.narrative as grade_narrative,
		(CASE sgrades.repeated WHEN true THEN 0 ELSE (grades.grade_weight * sgrades.credit) END) as gpa,
		(CASE WHEN ((grades.grade_name='W') OR (grades.grade_name='AW') OR (grades.gpa_count = false) OR (sgrades.repeated = true) OR (sgrades.non_gpa_course=true)) THEN 0 ELSE sgrades.credit END) as gpa_hours,
		(CASE WHEN ((grades.grade_name='W') OR (grades.grade_name='AW')) THEN sgrades.hours * sgrades.withdraw_rate  ELSE sgrades.hours END) as charge_hours
	FROM (vw_scourses INNER JOIN sgrades ON vw_scourses.scourse_id = sgrades.scourse_id)
		INNER JOIN grades ON sgrades.grade_id = grades.grade_id;
	

--view active grades--
CREATE VIEW vw_sgrade AS
	SELECT vw_scourses.school_id, vw_scourses.school_name, vw_scourses.department_id, vw_scourses.department_name,
		vw_scourses.degree_level_id, vw_scourses.degree_level_name, vw_scourses.course_type_id, vw_scourses.course_type_name,
		vw_scourses.course_id, vw_scourses.course_title, vw_scourses.credit_hours, vw_scourses.is_current,
		vw_scourses.no_gpa, vw_scourses.year_taken, 
		vw_scourses.instructor_id,vw_scourses.instructor_name, vw_scourses.session_id, vw_scourses.scourse_id, vw_scourses.class_option, vw_scourses.max_class,
		vw_scourses.lab_course, vw_scourses.extra_charge, vw_scourses.clinical_fee,
		vw_scourses.attendance as crs_attendance, 
		vw_scourses.full_attendance, 
		vw_scourses.attachement, vw_scourses.examinable,
		vw_scourses.submit_grades, vw_scourses.submit_date, vw_scourses.approved_grades, vw_scourses.approve_date,
		vw_scourses.department_change, vw_scourses.registry_change,

		sgrades.org_id, sgrades.grade_id, sgrades.sstudent_id, sgrades.hours, sgrades.credit, sgrades.approved as crs_approved,  sgrades.ask_drop,
		sgrades.ask_drop_date, sgrades.dropped, sgrades.drop_date, sgrades.repeated, sgrades.attendance, sgrades.narrative,
		sgrades.challenge_course, sgrades.non_gpa_course, sgrades.lecture_marks, sgrades.lecture_cat_mark, 
		sgrades.lecture_grade_id,
		sgrades.request_drop, sgrades.request_drop_date, sgrades.withdraw_rate as course_withdraw_rate,
		
		grades.grade_weight, grades.min_range, grades.max_range, grades.gpa_count, 
		grades.narrative as grade_narrative,
		(CASE sgrades.repeated WHEN true THEN 0 ELSE (grades.grade_weight * sgrades.credit) END) as gpa,
		(CASE WHEN ((grades.grade_name='W') OR (grades.grade_name='AW') OR (grades.gpa_count = false) OR (sgrades.repeated = true) OR (sgrades.non_gpa_course=true)) THEN 0 ELSE sgrades.credit END) as gpa_hours,
		(CASE WHEN ((grades.grade_name='W') OR (grades.grade_name='AW')) THEN sgrades.hours * sgrades.withdraw_rate  ELSE sgrades.hours END) as charge_hours
	FROM (vw_scourses INNER JOIN sgrades ON vw_scourses.scourse_id = sgrades.scourse_id)
		INNER JOIN grades ON sgrades.grade_id = grades.grade_id
	WHERE (sgrades.dropped = false);

	
--view student grades--
CREATE VIEW vw_student_grades AS
	SELECT vw_sstudents.religion_id, vw_sstudents.religion_name, vw_sstudents.denomination_id, vw_sstudents.denomination_name,
		vw_sstudents.sponsor_type_id, vw_sstudents.sponsor_type_name, vw_sstudents.sponsor_id, vw_sstudents.sponsor_name,
		vw_sstudents.sponsor_address, vw_sstudents.sponsor_street, vw_sstudents.sponsor_postal_code,
		vw_sstudents.sponsor_town, vw_sstudents.sponsor_telno, vw_sstudents.sponsor_email, 
		vw_sstudents.sponsor_country_id, vw_sstudents.sponsor_country_name,
		vw_sstudents.school_id, vw_sstudents.school_name, vw_sstudents.student_name,vw_sstudents.address, vw_sstudents.zipcode,
		vw_sstudents.town, vw_sstudents.address_country, vw_sstudents.telno, vw_sstudents.email,   
		vw_sstudents.account_number, vw_sstudents.Nationality, vw_sstudents.nationality_country, vw_sstudents.Sex,
		vw_sstudents.marital_status, vw_sstudents.birth_date,  vw_sstudents.post_contacts,
		vw_sstudents.on_probation, vw_sstudents.off_campus, vw_sstudents.current_contact, vw_sstudents.current_email, vw_sstudents.current_tel,
		vw_sstudents.degree_level_id, vw_sstudents.degree_level_name,vw_sstudents.chaplain_approval,vw_sstudents.student_dean_approval,
		vw_sstudents.freshman, vw_sstudents.sophomore, vw_sstudents.junior, vw_sstudents.senior,vw_sstudents.inter_session,
		vw_sstudents.level_location_id, vw_sstudents.level_location_name,vw_sstudents.LRF_picked,vw_sstudents.LRF_picked_date,
		vw_sstudents.sub_level_id, vw_sstudents.sub_level_name, vw_sstudents.special_charges,
		vw_sstudents.degree_id, vw_sstudents.degree_name,
		vw_sstudents.student_degree_id, vw_sstudents.completed, vw_sstudents.started, vw_sstudents.cleared, vw_sstudents.clear_date,
		vw_sstudents.graduated, vw_sstudents.graduate_date, vw_sstudents.drop_out, vw_sstudents.transfer_in, vw_sstudents.transfer_out,
		vw_sstudents.session_id, vw_sstudents.session_year, vw_sstudents.sessions, vw_sstudents.session_start, vw_sstudents.slate_reg, vw_sstudents.slate_change, vw_sstudents.slast_drop,
		vw_sstudents.session_end, vw_sstudents.active,
		vw_sstudents.residence_name, vw_sstudents.capacity, vw_sstudents.default_rate,
		vw_sstudents.residence_off_campus, vw_sstudents.residence_sex, vw_sstudents.residence_dean,
		vw_sstudents.residence_id, vw_sstudents.residence_option, vw_sstudents.residence_charge,
		vw_sstudents.org_id, vw_sstudents.student_id, vw_sstudents.additional_charges,  vw_sstudents.probation,
		vw_sstudents.room_number, vw_sstudents.curr_balance,  vw_sstudents.major_approval,vw_sstudents.approved,
		vw_sstudents.overload_approval, vw_sstudents.finalised, 
		vw_sstudents.unit_charges, vw_sstudents.lab_charge, vw_sstudents.fees_charge,  vw_sstudents.finance_approval,

		vw_sstudents.exam_clear, vw_sstudents.exam_clear_date, vw_sstudents.exam_clear_balance, vw_sstudents.exam_fees,
		vw_sstudents.request_withdraw, vw_sstudents.request_withdraw_date, vw_sstudents.withdraw, vw_sstudents.ac_withdraw,
		vw_sstudents.withdraw_date, vw_sstudents.withdraw_rate,  vw_sstudents.exchange_rate,

		vw_sgrade.school_id as crs_school_id, vw_sgrade.school_name as crs_school_name,
		vw_sgrade.department_id as crs_department_id, vw_sgrade.department_name as crs_department_name,
		vw_sgrade.degree_level_id as crs_degree_level_id, vw_sgrade.degree_level_name as crs_degree_level_name,
		vw_sgrade.course_type_id, vw_sgrade.course_type_name, vw_sgrade.course_id, vw_sgrade.course_title, vw_sgrade.credit_hours, vw_sgrade.is_current,
		vw_sgrade.no_gpa, vw_sgrade.year_taken, 
		vw_sgrade.instructor_id, vw_sgrade.instructor_name, vw_sgrade.scourse_id, vw_sgrade.class_option, vw_sgrade.max_class,
		vw_sgrade.lab_course, vw_sgrade.attendance as crs_attendance, 
		vw_sgrade.full_attendance, 
		vw_sgrade.grade_id, vw_sgrade.hours, vw_sgrade.credit, vw_sgrade.crs_approved, vw_sgrade.ask_drop,	
		vw_sgrade.ask_drop_date, vw_sgrade.dropped, vw_sgrade.drop_date, vw_sgrade.repeated, vw_sgrade.attendance, vw_sgrade.narrative,
		vw_sgrade.grade_weight, vw_sgrade.min_range, vw_sgrade.max_range, vw_sgrade.gpa_count, vw_sgrade.grade_narrative,
		vw_sgrade.gpa, vw_sgrade.gpa_hours, vw_sgrade.charge_hours, vw_sgrade.attachement, vw_sgrade.lecture_marks, vw_sgrade.lecture_cat_mark,
		vw_sgrade.lecture_grade_id, vw_sgrade.course_withdraw_rate,
		vw_sgrade.submit_grades, vw_sgrade.submit_date, vw_sgrade.approved_grades, vw_sgrade.approve_date,
		vw_sgrade.department_change, vw_sgrade.registry_change,
		
		

		(CASE WHEN (vw_sgrade.challenge_course = true) THEN (vw_sstudents.charge_rate * vw_sgrade.charge_hours * vw_sstudents.unit_charges / 100)
			ELSE (vw_sgrade.charge_hours * vw_sstudents.unit_charges) END) as unit_fees,

		(CASE WHEN vw_sgrade.examinable = true THEN vw_sstudents.exam_fees ELSE 0 END)  as exam_fee,

		vw_sgrade.clinical_fee,
		

		(CASE WHEN (vw_sgrade.lab_course = true) THEN vw_sstudents.lab_charges ELSE 0 END) as lab_fees,

		vw_sgrade.extra_charge

	FROM vw_sstudents INNER JOIN vw_sgrade ON vw_sstudents.student_id::int = vw_sgrade.sstudent_id;
	
	
	
CREATE VIEW vw_selcourses AS
	SELECT courses.course_id, courses.course_title, courses.credit_hours, courses.no_gpa, courses.year_taken,
		scourses.scourse_id, scourses.session_id, scourses.class_option, scourses.max_class, scourses.lab_course,
		instructors.instructor_id, instructors.instructor_name, scourses.scourse_id as scourse_students,
		sgrades.grade_id, sgrades.sstudent_id,sgrades.hours, sgrades.credit, sgrades.approved,
		sgrades.approve_date, sgrades.ask_drop, sgrades.ask_drop_date, sgrades.dropped,	sgrades.drop_date,
		sgrades.repeated, sgrades.withdraw_date, sgrades.attendance, sgrades.option_time_id, sgrades.narrative
	FROM (((courses INNER JOIN scourses ON courses.course_id = scourses.course_id)
		INNER JOIN instructors ON scourses.instructor_id::character varying = instructors.instructor_id)
		INNER JOIN sgrades ON sgrades.scourse_id = scourses.scourse_id)
		INNER JOIN sessions ON scourses.session_id = sessions.session_id
	WHERE (sessions.active = true) AND (sgrades.dropped = false);

--function returning courses done--
CREATE OR REPLACE FUNCTION get_course_done(varchar(12), varchar(12)) RETURNS float AS $$
	SELECT max(grades.grade_weight)
	FROM (((scourses INNER JOIN sgrades ON scourses.scourse_id = sgrades.scourse_id)
		INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id)
		INNER JOIN grades ON sgrades.grade_id = grades.grade_id)
		INNER JOIN student_degrees ON sstudents.student_degree_id = student_degrees.student_degree_id
	WHERE (sstudents.finance_approval = true) AND (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW')
	AND (student_degrees.student_id = $1) AND (scourses.course_id = $2);		
$$ LANGUAGE SQL;

--function returning transferred courses--
CREATE OR REPLACE FUNCTION get_course_transfered(varchar(12), varchar(12)) RETURNS float AS $$
	SELECT sum(transfered_credits.credit_hours)
	FROM transfered_credits INNER JOIN student_degrees ON transfered_credits.student_degree_id = student_degrees.student_degree_id
	WHERE (student_degrees.student_id = $1) AND (transfered_credits.course_id = $2);		
$$ LANGUAGE SQL;

--function returning passed prerequisites--
CREATE OR REPLACE FUNCTION get_prereq_passed(varchar(12), varchar(12), integer, boolean) RETURNS boolean AS $$
DECLARE
	passed boolean;
	myrec RECORD;
BEGIN
	passed := false;
	
	FOR myrec IN SELECT option_level, precourse_id, grade_weight 
		FROM prereq_view 
		WHERE (prereq_view.course_id = $2) AND (prereq_view.option_level = 0) AND (prereq_view.bulletings_id = $3)
	ORDER BY prereq_view.option_level LOOP
		IF (get_course_done($1, myrec.precourse_id) >= myrec.grade_weight) THEN
			passed := true;
		END IF;
		IF (get_course_transfered($1, myrec.precourse_id) is not null) THEN
			passed := true;
		END IF;
	END LOOP;

	IF ($4 = true) THEN
		passed := true;
	END IF;

    RETURN passed;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_prereq_passed(varchar(12), varchar(12), integer) RETURNS boolean AS $$
DECLARE
	passed boolean;
	hasprereq boolean;
	myrec RECORD;
	order_id int;
BEGIN
	passed := false;
	hasprereq := false;
	order_id := 1;
	
	FOR myrec IN SELECT option_level, precourse_id, grade_weight 
		FROM prereq_view 
		WHERE (prereq_view.course_id = $2) AND (prereq_view.option_level > 0) AND (prereq_view.bulletings_id = $3)
	ORDER BY prereq_view.option_level LOOP
		hasprereq :=  true;
		IF(order_id <> myrec.option_level) THEN
			order_id := myrec.option_level;
			passed := false;
		END IF;

		IF (get_course_done($1, myrec.precourse_id) >= myrec.grade_weight) THEN
			passed := true;
		END IF;
		IF (get_course_transfered($1, myrec.precourse_id) is not null) THEN
			passed := true;
		END IF;
	END LOOP;

	IF (hasprereq = false) THEN
		passed := true;
	END IF;

    RETURN passed;
END;
$$ LANGUAGE plpgsql;

--view selected courses---
CREATE VIEW vw_selected_grades AS
	SELECT vw_selcourses.course_id, vw_selcourses.course_title, vw_selcourses.credit_hours, vw_selcourses.no_gpa, vw_selcourses.year_taken,
		vw_selcourses.scourse_id, vw_selcourses.session_id, vw_selcourses.class_option, vw_selcourses.max_class, vw_selcourses.lab_course,
		vw_selcourses.instructor_id, vw_selcourses.instructor_name, vw_selcourses.scourse_students,
		vw_selcourses.grade_id, vw_selcourses.sstudent_id, vw_selcourses.hours, vw_selcourses.credit, vw_selcourses.approved,
		vw_selcourses.approve_date, vw_selcourses.ask_drop, vw_selcourses.ask_drop_date, vw_selcourses.dropped,	vw_selcourses.drop_date,
		vw_selcourses.repeated, vw_selcourses.withdraw_date, vw_selcourses.attendance, vw_selcourses.option_time_id, vw_selcourses.narrative,
		student_degrees.student_degree_id, student_degrees.student_id, students.student_name, students.sex,
		  
		get_prereq_passed(student_degrees.student_id, vw_selcourses.course_id, student_degrees.bulletings_id) as prereq_passed,
		sstudents.org_id
	FROM ((vw_selcourses INNER JOIN sstudents ON vw_selcourses.sstudent_id = sstudents.sstudent_id)
		INNER JOIN student_degrees ON sstudents.student_degree_id = student_degrees.student_degree_id)
		INNER JOIN students ON student_degrees.student_id = students.student_id;

--view student timetables---
CREATE VIEW vw_student_timetable AS
	SELECT assets.asset_id, assets.asset_name, assets.location, assets.building, assets.capacity, 
		vw_selected_grades.course_id, vw_selected_grades.course_title, vw_selected_grades.credit_hours, vw_selected_grades.no_gpa, vw_selected_grades.year_taken,
		vw_selected_grades.scourse_id, vw_selected_grades.session_id, vw_selected_grades.class_option, vw_selected_grades.max_class, vw_selected_grades.lab_course,
		vw_selected_grades.instructor_id, vw_selected_grades.instructor_name, vw_selected_grades.student_degree_id, vw_selected_grades.student_id,
		vw_selected_grades.grade_id, vw_selected_grades.sstudent_id,  vw_selected_grades.hours, vw_selected_grades.credit, vw_selected_grades.approved,
		vw_selected_grades.approve_date, vw_selected_grades.ask_drop, vw_selected_grades.ask_drop_date, vw_selected_grades.dropped,	vw_selected_grades.drop_date,
		vw_selected_grades.repeated, vw_selected_grades.withdraw_date, vw_selected_grades.attendance, vw_selected_grades.narrative,
		stimetables.org_id, stimetables.stimetable_id, stimetables.start_time, stimetables.end_time, stimetables.lab,
		stimetables.details, stimetables.c_monday, stimetables.c_tuesday, stimetables.c_wednesday, stimetables.c_thursday,
		stimetables.c_friday, stimetables.c_saturday, stimetables.c_sunday,sexam_timetable.exam_date,
		option_times.option_time_id, option_times.option_time_name
	FROM (assets INNER JOIN (stimetables INNER JOIN option_times ON stimetables.option_time_id = option_times.option_time_id) ON assets.asset_id = stimetables.asset_id)
		INNER JOIN vw_selected_grades ON (stimetables.scourse_id = vw_selected_grades.scourse_id AND stimetables.option_time_id =  vw_selected_grades.option_time_id)
		INNER JOIN sexam_timetable ON sexam_timetable.scourse_id=stimetables.scourse_id
	ORDER BY stimetables.start_time;
	
--view student session exam timetables---
CREATE VIEW vw_student_sexam_timetable AS
	SELECT vw_scourses.course_id,  
		vw_scourses.school_id, vw_scourses.school_name, vw_scourses.department_id, vw_scourses.department_name,
		vw_scourses.instructor_id, 
		sexam_timetable.org_id, sexam_timetable.sexam_timetable_id, sexam_timetable.exam_date, sexam_timetable.start_time, 
		sexam_timetable.end_time, sexam_timetable.lab,
		sessions.session_id, sessions.active
	FROM (vw_scourses INNER JOIN sexam_timetable ON vw_scourses.scourse_id = sexam_timetable.scourse_id)
		INNER JOIN sessions ON vw_scourses.session_id = sessions.session_id;

--view student course marks--
CREATE VIEW vw_course_marks AS
	SELECT vw_student_grades.school_id, vw_student_grades.school_name, vw_student_grades.student_id, vw_student_grades.student_name, vw_student_grades.email,
		vw_student_grades.degree_level_id, vw_student_grades.degree_level_name, vw_student_grades.sub_level_id, vw_student_grades.sub_level_name, 
		vw_student_grades.degree_id, vw_student_grades.degree_name, vw_student_grades.student_degree_id, vw_student_grades.completed, vw_student_grades.started,
		vw_student_grades.cleared, vw_student_grades.clear_date, vw_student_grades.session_id,
		vw_student_grades.full_attendance,   vw_student_grades.class_option,
		vw_student_grades.grade_id, vw_student_grades.hours, vw_student_grades.credit, vw_student_grades.crs_approved,
		vw_student_grades.dropped, vw_student_grades.grade_weight, vw_student_grades.min_range,
		vw_student_grades.max_range, vw_student_grades.gpa_count,
		vw_student_grades.submit_grades, vw_student_grades.submit_date, vw_student_grades.approved_grades, vw_student_grades.approve_date,
		vw_student_grades.department_change, vw_student_grades.registry_change,
		
		scourse_marks.scourse_mark_id, scourse_marks.approved, scourse_marks.submited, scourse_marks.mark_date, scourse_marks.marks,
		scourse_marks.details,
		scourse_items.scourse_item_id, scourse_items.course_item_name, scourse_items.mark_ratio, scourse_items.total_marks,
		scourse_items.given, scourse_items.deadline, scourse_items.details as item_details
	FROM (vw_student_grades INNER JOIN scourse_marks ON vw_student_grades.grade_id = scourse_marks.sgrade_id)
		INNER JOIN scourse_items ON scourse_marks.scourse_item_id =  scourse_items.scourse_item_id;

---view students session grades---
CREATE VIEW vw_sstudents_grades AS
	SELECT vw_student_grades.org_id, vw_student_grades.religion_id, vw_student_grades.religion_name, vw_student_grades.denomination_id, vw_student_grades.denomination_name,
		vw_student_grades.school_id, vw_student_grades.school_name, vw_student_grades.student_name, vw_student_grades.address, vw_student_grades.zipcode,
		vw_student_grades.town, vw_student_grades.address_country, vw_student_grades.telno, vw_student_grades.email,
		vw_student_grades.account_number, vw_student_grades.Nationality, vw_student_grades.nationality_country, vw_student_grades.Sex,
		vw_student_grades.marital_status, vw_student_grades.birth_date,  
		vw_student_grades.on_probation, vw_student_grades.off_campus, vw_student_grades.current_contact, vw_student_grades.current_email, vw_student_grades.current_tel,
		vw_student_grades.degree_level_id, vw_student_grades.degree_level_name,
		vw_student_grades.freshman, vw_student_grades.sophomore, vw_student_grades.junior, vw_student_grades.senior,
		vw_student_grades.level_location_id, vw_student_grades.level_location_name,
		vw_student_grades.sub_level_id, vw_student_grades.sub_level_name, vw_student_grades.special_charges,
		vw_student_grades.degree_id, vw_student_grades.degree_name,
		vw_student_grades.student_degree_id, vw_student_grades.completed, vw_student_grades.started, vw_student_grades.cleared, vw_student_grades.clear_date,
		vw_student_grades.graduated, vw_student_grades.graduate_date, vw_student_grades.drop_out, vw_student_grades.transfer_in, vw_student_grades.transfer_out,
		vw_student_grades.session_id, vw_student_grades.session_year, vw_student_grades.sessions, vw_student_grades.session_start, vw_student_grades.slate_reg, vw_student_grades.slate_change, vw_student_grades.slast_drop,
		vw_student_grades.session_end, vw_student_grades.active,   
		vw_student_grades.residence_name, vw_student_grades.capacity, vw_student_grades.default_rate,
		vw_student_grades.residence_off_campus, vw_student_grades.residence_sex, vw_student_grades.residence_dean,
		vw_student_grades.residence_id, vw_student_grades.residence_option,
		vw_student_grades.student_id,  vw_student_grades.probation,vw_student_grades.inter_session,
		vw_student_grades.room_number,  vw_student_grades.major_approval, vw_student_grades.finance_approval,
		vw_student_grades.overload_approval, vw_student_grades.finalised, vw_student_grades.approved,
		vw_student_grades.unit_charges, vw_student_grades.lab_charge, vw_student_grades.curr_balance, vw_student_grades.additional_charges,

		vw_student_grades.exam_clear, vw_student_grades.exam_clear_date, vw_student_grades.exam_clear_balance, vw_student_grades.exam_fees,
		vw_student_grades.request_withdraw, vw_student_grades.request_withdraw_date, vw_student_grades.withdraw, vw_student_grades.ac_withdraw,
		vw_student_grades.withdraw_date, vw_student_grades.withdraw_rate, 

		(CASE sum(vw_student_grades.gpa_hours) WHEN 0 THEN 0 ELSE (sum(vw_student_grades.gpa)/sum(vw_student_grades.gpa_hours)) END) as gpa,

		sum(vw_student_grades.gpa_hours) as credit, sum(vw_student_grades.charge_hours) as hours, 
		bool_and(vw_student_grades.attachement) as on_attachment,

		(CASE bool_and(vw_student_grades.attachement) WHEN true THEN 0 ELSE vw_student_grades.fees_charge END) as fees_charge, 

		sum(vw_student_grades.unit_fees) as unit_charge, sum(vw_student_grades.lab_fees) as lab_charges, sum(vw_student_grades.clinical_fee) as clinical_charge,
		sum(vw_student_grades.exam_fee) as exam_fee, sum(vw_student_grades.extra_charge) as course_extra_charge,

		vw_student_grades.residence_charge, 

		((CASE bool_and(vw_student_grades.attachement) WHEN true THEN 0 ELSE vw_student_grades.fees_charge END) 
			+ sum(vw_student_grades.unit_fees) + sum(vw_student_grades.exam_fee) + sum(vw_student_grades.lab_fees) 
			+ sum(vw_student_grades.clinical_fee) + sum(vw_student_grades.extra_charge) 
			+ vw_student_grades.residence_charge + vw_student_grades.additional_charges) as total_fees,

		(vw_student_grades.curr_balance
			+ ((CASE bool_and(vw_student_grades.attachement) WHEN true THEN 0 ELSE vw_student_grades.fees_charge END) 
			+ sum(vw_student_grades.unit_fees) + sum(vw_student_grades.exam_fee) + sum(vw_student_grades.lab_fees) 
			+ sum(vw_student_grades.clinical_fee) + sum(vw_student_grades.extra_charge) 
			+ vw_student_grades.residence_charge + vw_student_grades.additional_charges)) as final_balance

	FROM vw_student_grades
	INNER JOIN grades ON grades.grade_id=vw_student_grades.grade_id
	WHERE (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW')
	GROUP BY vw_student_grades.org_id, vw_student_grades.religion_id, vw_student_grades.religion_name, vw_student_grades.denomination_id, vw_student_grades.denomination_name,
		vw_student_grades.school_id, vw_student_grades.school_name, vw_student_grades.student_id, vw_student_grades.student_name, vw_student_grades.address, vw_student_grades.zipcode,
		vw_student_grades.town, vw_student_grades.address_country, vw_student_grades.telno, vw_student_grades.email,   
		vw_student_grades.account_number, vw_student_grades.Nationality, vw_student_grades.nationality_country, vw_student_grades.Sex,
		vw_student_grades.marital_status, vw_student_grades.birth_date, 
		vw_student_grades.on_probation, vw_student_grades.off_campus, vw_student_grades.current_contact, vw_student_grades.current_email, vw_student_grades.current_tel,
		vw_student_grades.degree_level_id, vw_student_grades.degree_level_name,
		vw_student_grades.freshman, vw_student_grades.sophomore, vw_student_grades.junior, vw_student_grades.senior,
		vw_student_grades.level_location_id, vw_student_grades.level_location_name,
		vw_student_grades.sub_level_id, vw_student_grades.sub_level_name, vw_student_grades.special_charges,
		vw_student_grades.degree_id, vw_student_grades.degree_name,
		vw_student_grades.student_degree_id, vw_student_grades.completed, vw_student_grades.started, vw_student_grades.cleared, vw_student_grades.clear_date,
		vw_student_grades.graduated, vw_student_grades.graduate_date, vw_student_grades.drop_out, vw_student_grades.transfer_in, vw_student_grades.transfer_out,
		vw_student_grades.session_id, vw_student_grades.session_year, vw_student_grades.sessions, vw_student_grades.session_start, vw_student_grades.slate_reg, vw_student_grades.slate_change, vw_student_grades.slast_drop,
		vw_student_grades.session_end, vw_student_grades.active,  
		vw_student_grades.residence_id, vw_student_grades.residence_name, vw_student_grades.capacity, vw_student_grades.default_rate,
		vw_student_grades.residence_off_campus, vw_student_grades.residence_sex, vw_student_grades.residence_dean,
		vw_student_grades.residence_id, vw_student_grades.residence_option, 
		vw_student_grades.student_id,  vw_student_grades.probation,
		vw_student_grades.room_number,  vw_student_grades.major_approval,
		vw_student_grades.overload_approval, vw_student_grades.finalised, 
		vw_student_grades.unit_charges, vw_student_grades.lab_charge, vw_student_grades.curr_balance, vw_student_grades.fees_charge, vw_student_grades.residence_charge, vw_student_grades.additional_charges,
		vw_student_grades.exam_clear, vw_student_grades.exam_clear_date, vw_student_grades.exam_clear_balance, vw_student_grades.exam_fees,
		vw_student_grades.request_withdraw, vw_student_grades.request_withdraw_date, vw_student_grades.withdraw, vw_student_grades.ac_withdraw,
		vw_student_grades.withdraw_date, vw_student_grades.withdraw_rate,vw_student_grades.inter_session,vw_student_grades.finance_approval,vw_student_grades.approved;
		
--view course outline--
CREATE VIEW vw_course_outlines (
	order_id,
	student_id,
	student_degree_id,
	degree_id,
	description,
	course_id,
	course_title,
	minor,
	elective,
	credit_hours,
	no_gpa,
	grade_id,
	grade_weight
) AS
	(SELECT 1, student_degrees.student_id, student_degrees.student_degree_id, student_degrees.degree_id, majors.major_name, vw_major_contents.course_id,
		vw_major_contents.course_title, vw_major_contents.minor, vw_major_contents.elective, vw_major_contents.credit_hours,
		vw_major_contents.no_gpa, vw_major_contents.grade_id, grades.grade_weight
	FROM (((majors INNER JOIN vw_major_contents ON majors.major_id = vw_major_contents.major_id)
		INNER JOIN student_majors ON vw_major_contents.major_id = student_majors.major_id)
		INNER JOIN student_degrees ON (student_majors.student_degree_id = student_degrees.student_degree_id) AND (vw_major_contents.bulletings_id = student_degrees.bulletings_id))
		INNER JOIN grades ON vw_major_contents.grade_id = grades.grade_id
	WHERE ((not student_majors.pre_major and vw_major_contents.pre_major)=false) AND ((not student_majors.non_degree and vw_major_contents.prerequisite)=false)
		and (student_degrees.completed=false) and (student_degrees.drop_out=false))
	UNION
	(SELECT 2, student_degrees.student_id, student_degrees.student_degree_id, student_degrees.degree_id, major_options.major_option_name, vw_major_opt_contents.course_id,
		vw_major_opt_contents.course_title, vw_major_opt_contents.minor, vw_major_opt_contents.elective, vw_major_opt_contents.credit_hours,
		vw_major_opt_contents.no_gpa, vw_major_opt_contents.grade_id, grades.grade_weight
	FROM (((major_options 
		INNER JOIN vw_major_opt_contents ON major_options.major_option_id = vw_major_opt_contents.major_option_id)
		INNER JOIN student_majors ON student_majors.major_id = vw_major_opt_contents.major_id)
		INNER JOIN student_degrees ON (student_majors.student_degree_id = student_degrees.student_degree_id) AND (vw_major_opt_contents.bulletings_id = student_degrees.bulletings_id))
		INNER JOIN grades ON vw_major_opt_contents.grade_id = grades.grade_id
	WHERE ((not student_majors.pre_major and vw_major_opt_contents.pre_major)=false) AND ((not student_majors.non_degree and vw_major_opt_contents.prerequisite)=false)
		and (student_degrees.completed=false) and (student_degrees.drop_out=false));
		
--view corecourseoutline--
CREATE VIEW vw_core_course_outline AS 
	(SELECT 1 AS order_id, student_degrees.student_id, student_degrees.student_degree_id, student_degrees.degree_id, 
		majors.major_name AS description, vw_major_contents.content_type_id, vw_major_contents.content_type_name,
		vw_major_contents.course_id, vw_major_contents.course_title, vw_major_contents.minor, 
		vw_major_contents.elective, vw_major_contents.credit_hours, vw_major_contents.no_gpa, vw_major_contents.grade_id, 
		grades.grade_weight
	FROM majors
		INNER JOIN vw_major_contents ON majors.major_id = vw_major_contents.major_id
		INNER JOIN student_majors ON vw_major_contents.major_id = student_majors.major_id
		INNER JOIN student_degrees ON (student_majors.student_degree_id = student_degrees.student_degree_id) AND (vw_major_contents.bulletings_id = student_degrees.bulletings_id)
		INNER JOIN grades ON vw_major_contents.grade_id = grades.grade_id
		WHERE (student_majors.major = true) AND ((NOT student_majors.pre_major AND vw_major_contents.pre_major) = false) AND ((NOT student_majors.non_degree AND vw_major_contents.prerequisite) = false) AND (student_degrees.drop_out = false))
	UNION 
	(SELECT 2 AS order_id, student_degrees.student_id, student_degrees.student_degree_id, student_degrees.degree_id, 
		major_options.major_option_name AS description, vw_major_opt_contents.content_type_id, vw_major_opt_contents.content_type_name,
		vw_major_opt_contents.course_id, vw_major_opt_contents.course_title, 
		vw_major_opt_contents.minor, vw_major_opt_contents.elective, vw_major_opt_contents.credit_hours, 
		vw_major_opt_contents.no_gpa, vw_major_opt_contents.grade_id, grades.grade_weight
	FROM major_options
		INNER JOIN vw_major_opt_contents ON major_options.major_option_id = vw_major_opt_contents.major_option_id
		INNER JOIN student_majors ON student_majors.major_id = vw_major_opt_contents.major_id
		INNER JOIN student_degrees ON (student_majors.student_degree_id = student_degrees.student_degree_id) AND (vw_major_opt_contents.bulletings_id = student_degrees.bulletings_id)
		INNER JOIN grades ON vw_major_opt_contents.grade_id = grades.grade_id
	WHERE (student_majors.major = true) AND (NOT student_majors.pre_major AND vw_major_opt_contents.pre_major) = false AND (NOT student_majors.non_degree AND vw_major_opt_contents.prerequisite) = false AND (student_degrees.drop_out = false));

	--view course check lists--
CREATE VIEW vw_course_check_lists AS
	SELECT DISTINCT vw_course_outlines.order_id, vw_course_outlines.student_id, vw_course_outlines.student_degree_id, vw_course_outlines.degree_id, vw_course_outlines.description, vw_course_outlines.course_id,
		vw_course_outlines.course_title, vw_course_outlines.minor, vw_course_outlines.elective, vw_course_outlines.credit_hours, vw_course_outlines.no_gpa, vw_course_outlines.grade_id,
		vw_course_outlines.grade_weight, get_course_done(vw_course_outlines.student_id, vw_course_outlines.course_id) as courseweight,
		(CASE WHEN (get_course_done(vw_course_outlines.student_id, vw_course_outlines.course_id) >= vw_course_outlines.grade_weight) THEN true ELSE false END) as course_passed,
		get_prereq_passed(vw_course_outlines.student_id, vw_course_outlines.course_id, vw_course_outlines.student_degree_id) as prereq_passed
	FROM vw_course_outlines;
	
	--view students checklists--
CREATE VIEW vw_student_check_lists AS
	SELECT vw_course_check_lists.order_id, vw_course_check_lists.student_id, vw_course_check_lists.student_degree_id, vw_course_check_lists.degree_id, vw_course_check_lists.description, vw_course_check_lists.course_id,
		vw_course_check_lists.course_title, vw_course_check_lists.minor, vw_course_check_lists.elective, vw_course_check_lists.credit_hours, vw_course_check_lists.no_gpa, vw_course_check_lists.grade_id,
		vw_course_check_lists.courseweight, vw_course_check_lists.course_passed, vw_course_check_lists.prereq_passed,
		students.student_name
	FROM vw_course_check_lists 
		INNER JOIN students ON vw_course_check_lists.student_id = students.student_id;

	--view session course check pass--
CREATE VIEW vw_scourse_check_pass AS
	SELECT vw_course_check_lists.order_id, vw_course_check_lists.student_id, vw_course_check_lists.student_degree_id, vw_course_check_lists.degree_id, vw_course_check_lists.description,
		vw_course_check_lists.minor, vw_course_check_lists.elective, vw_course_check_lists.grade_id,
		vw_course_check_lists.grade_weight, vw_course_check_lists.courseweight, vw_course_check_lists.course_passed, vw_course_check_lists.prereq_passed,
		vw_scourses.org_id, vw_scourses.school_id, vw_scourses.school_name, vw_scourses.department_id, vw_scourses.department_name,
		vw_scourses.degree_level_id, vw_scourses.degree_level_name, vw_scourses.course_type_id, vw_scourses.course_type_name,
		vw_scourses.course_id,vw_scourses.course_title,  vw_scourses.credit_hours, vw_scourses.max_credit, vw_scourses.is_current,
		vw_scourses.no_gpa, vw_scourses.year_taken, 
		vw_scourses.instructor_id, vw_sc
		ourses.session_id, vw_scourses.scourse_id, vw_scourses.class_option, vw_scourses.max_class,
		vw_scourses.lab_course, vw_scourses.extra_charge, vw_scourses.approved, vw_scourses.attendance, 
		vw_scourses.full_attendance, vw_scourses.level_location_id, vw_scourses.level_location_name
	FROM vw_course_check_lists
		INNER JOIN vw_scourses ON vw_course_check_lists.course_id = vw_scourses.course_id
	WHERE (vw_scourses.active = true) AND (vw_scourses.approved = false) 
		AND (vw_course_check_lists.course_passed = false) AND (vw_course_check_lists.prereq_passed = true);

--view core grades--
CREATE VIEW vw_core_grades AS 
	SELECT vw_student_grades.school_id, vw_student_grades.school_name, vw_student_grades.student_id, vw_student_grades.student_name, vw_student_grades.sex,
		vw_student_grades.degree_id, vw_student_grades.degree_name, vw_student_grades.student_degree_id, vw_student_grades.session_id, vw_student_grades.session_year,
		vw_student_grades.sessions, vw_student_grades.course_type_id, vw_student_grades.course_type_name, vw_student_grades.course_id, vw_student_grades.no_gpa,
		vw_student_grades.instructor_id, vw_student_grades.scourse_id, vw_student_grades.class_option, vw_student_grades.lab_course,  vw_student_grades.grade_id, vw_student_grades.hours, vw_student_grades.credit, vw_student_grades.gpa,
		vw_student_grades.repeated, vw_student_grades.gpa_hours, vw_student_grades.charge_hours, 
		vw_core_course_outline.description, vw_core_course_outline.minor, vw_core_course_outline.elective,
		vw_core_course_outline.content_type_id, vw_core_course_outline.content_type_name
	FROM vw_core_course_outline INNER JOIN vw_student_grades ON (vw_core_course_outline.student_degree_id = vw_student_grades.student_degree_id) AND (vw_core_course_outline.course_id = vw_student_grades.course_id)
	WHERE (vw_student_grades.major_approval = true) AND (vw_core_course_outline.minor = false);
	
--view grades for majors--
CREATE VIEW vw_major_grade AS
	SELECT vw_student_degrees.student_id, vw_student_degrees.student_name, vw_student_degrees.sex, vw_student_degrees.degree_level_id, vw_student_degrees.degree_level_name, 
		vw_student_degrees.level_location_id, vw_student_degrees.level_location_name, vw_student_degrees.sub_level_id, vw_student_degrees.sub_level_name, 
		vw_student_degrees.degree_id, vw_student_degrees.degree_name, vw_student_degrees.student_degree_id, 
		student_majors.student_major_id, student_majors.major, student_majors.non_degree, student_majors.pre_major, 
		vw_major_contents.department_id, vw_major_contents.department_name, vw_major_contents.major_id, vw_major_contents.major_name, 
		vw_major_contents.course_id, vw_major_contents.course_title, vw_major_contents.content_type_id, vw_major_contents.content_type_name,
		vw_major_contents.elective, vw_major_contents.prerequisite, vw_major_contents.major_content_id,
		vw_major_contents.pre_major as pre_major_item, vw_major_contents.minor, vw_major_contents.grade_id as min_grade,
		vw_sgrades.session_id, vw_sgrades.grade_id, vw_sgrades.sstudent_id, vw_sgrades.gpa_hours, vw_sgrades.gpa
		
	FROM (((vw_student_degrees
			INNER JOIN student_majors ON vw_student_degrees.student_degree_id = student_majors.student_degree_id)
		INNER JOIN vw_major_contents ON vw_major_contents.major_id = student_majors.major_id)
		INNER JOIN sstudents ON sstudents.student_degree_id = vw_student_degrees.student_degree_id)
		INNER JOIN vw_sgrades ON (vw_sgrades.course_id = vw_major_contents.course_id) and (vw_sgrades.sstudent_id =   sstudents.sstudent_id)
	WHERE ((not student_majors.pre_major and vw_major_contents.pre_major)=false) AND ((not student_majors.non_degree and vw_major_contents.prerequisite)=false);


--function returning students bank payment details--
CREATE OR REPLACE FUNCTION get_bank_student_id(varchar(240)) RETURNS varchar(12) AS $$
DECLARE
	mystudent_id varchar(12);
	my_check_id varchar(240);
	mybankref varchar(240);
	myrec RECORD;
	myaccrec RECORD;
	i int;
BEGIN
	mystudent_id := '';
	mybankref := $1;

	FOR i IN 1..20 LOOP
		my_check_id := trim(upper(split_part(mybankref, ' ', i)));
		IF char_length(my_check_id) >  6 THEN
			SELECT INTO myrec student_id FROM students WHERE student_id = my_check_id;
			IF myrec.student_id is not null THEN
				mystudent_id := myrec.student_id;
			ELSE
				SELECT INTO myaccrec student_id FROM students WHERE account_number = my_check_id;
				IF myaccrec.student_id is not null THEN
					mystudent_id := myaccrec.student_id;
				END IF;
			END IF;
		END IF; 
	END LOOP;

    RETURN mystudent_id;
END;
$$ LANGUAGE plpgsql;	

--view grade count--
CREATE VIEW vw_grade_counts AS
	SELECT sstudents.student_degree_id,  scourses.course_id, count(scourses.scourse_id) as course_count
	FROM (sgrades INNER JOIN (scourses INNER JOIN courses ON scourses.course_id = courses.course_id) ON sgrades.scourse_id = scourses.scourse_id)
		INNER JOIN sstudents ON sgrades.sstudent_id = sstudents.sstudent_id
		INNER JOIN grades ON grades.grade_id=sgrades.grade_id
	WHERE (grades.grade_name <> 'W') AND (grades.grade_name <> 'AW') AND (grades.grade_name <> 'NG') AND (sgrades.dropped = false)
		AND (repeated = false) AND (sstudents.major_approval = true) AND (courses.no_repeats = false)
	GROUP BY sstudents.student_degree_id,  scourses.course_id;
	
--view current students residences--
CREATE VIEW vw_current_residences AS
	SELECT residences.residence_id, residences.residence_name, residences.capacity, residences.default_rate,
		residences.off_campus, residences.Sex, residences.residence_dean,
		sresidences.sresidence_id, sresidences.session_id, sresidences.residence_option, sresidences.charges, 
		sresidences.details, sresidences.org_id,
		
		students.student_id, students.student_name
	FROM ((residences INNER JOIN sresidences ON residences.residence_id = sresidences.residence_id)
	INNER JOIN vw_sessions ON sresidences.session_id = vw_sessions.session_id)
	INNER JOIN students ON ((residences.Sex = students.Sex) OR (residences.Sex='N')) 
		AND (residences.off_campus = students.off_campus) 
	WHERE (vw_sessions.active = true);
	
	--function returns first_session_id---
CREATE OR REPLACE FUNCTION get_first_session_id(varchar(12)) RETURNS varchar(12) AS $$
	SELECT min(session_id) 
	FROM sstudents INNER JOIN student_degrees ON sstudents.student_degree_id = student_degrees.student_degree_id
	WHERE (student_id = $1);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_first_session_id(integer) RETURNS varchar(12) AS $$
	SELECT min(session_id)
	FROM sstudents
	WHERE (student_degree_id = $1);
$$ LANGUAGE SQL;

--view students first session---
CREATE VIEW vw_student_first_sessions AS
	SELECT students.student_id, students.student_name, students.Nationality, students.Sex, students.marital_status, 
		student_degrees.student_degree_id, student_degrees.completed, student_degrees.started, student_degrees.graduated,
		degrees.degree_id, degrees.degree_name, get_first_session_id(students.student_id) as first_session_id,
		SUBSTRING(get_first_session_id(student_degrees.student_degree_id) from 1 for 9) as first_year,
		SUBSTRING(get_first_session_id(student_degrees.student_degree_id) from 11 for 1) as first_session
	FROM (students INNER JOIN student_degrees ON students.student_id = student_degrees.student_id)
		INNER JOIN degrees ON student_degrees.degree_id = degrees.degree_id;
		
--view dualcourselevels---
CREATE VIEW vw_dual_course_levels AS
	SELECT student_id, student_name, student_degree_id, degree_name, session_id, crs_degree_level_id, crs_degree_level_name
	FROM vw_student_grades
	GROUP BY student_id, student_name, student_degree_id, degree_name, session_id, crs_degree_level_id, crs_degree_level_name;
	
--VIEW student marks--
CREATE VIEW vw_student_marks AS
	SELECT marks.mark_id, marks.grade, marks.mark_weight, registrations.existing_id,
		get_first_session_id(registrations.existing_id) as first_session,
		students.student_name
	FROM (registrations INNER JOIN marks ON registrations.mark_id = marks.mark_id)
		INNER JOIN students ON registrations.existing_id = students.student_id;
		
CREATE VIEW vw_registrations AS
	SELECT registrations.registration_id, registrations.email, registrations.phone_number,
		registrations.submit_application, 
		registrations.is_accepted, registrations.is_reported, registrations.is_deferred, registrations.is_rejected,
		registrations.application_date, ca.sys_country_name as nationality,
		registrations.sex, registrations.surname, registrations.first_name, registrations.other_names, 
		(registrations.surname || ', ' ||  registrations.first_name || ' ' || registrations.other_names) as full_name,
		registrations.existing_id, registrations.first_choice_id, registrations.second_choice_id, registrations.off_campus,
		registrations.entry_form_id, registrations.admission_level,
		
		(CASE WHEN registrations.org_id = 0 THEN 'UNDERGRADUATE' ELSE 'POSTGRADUATE' END) as selection_name,
		(CASE WHEN registrations.af_success = '0' THEN 'The payment is completed' ELSE 'Payment has not been done' END) as payment_Status,
		
		registrations.acceptance_fees, registrations.af_date, registrations.af_amount, registrations.af_success,
		registrations.af_payment_code, registrations.af_trans_no, registrations.af_card_type, 
		registrations.af_picked, registrations.af_picked_date, registrations.account_number,
		
		applications.application_id,  applications.session_id,
		
		vw_majors.major_id, vw_majors.major_name, vw_majors.minor_minimum, vw_majors.major_minimal,
		vw_majors.department_id,  
		
		first_choice.major_name as first_choice, second_major.major_name as second_choice
	FROM registrations 
		INNER JOIN applications ON registrations.registration_id = applications.application_id
		LEFT JOIN vw_majors ON registrations.major_id = vw_majors.major_id
		INNER JOIN majors as first_choice ON registrations.first_choice_id = first_choice.major_id
		INNER JOIN majors as second_major ON registrations.second_choice_id = second_major.major_id
		INNER JOIN sys_countrys as ca ON registrations.nationality_id = ca.sys_country_id;

		
CREATE VIEW vw_sstudent_majors AS 
	SELECT vw_sstudents.session_id,vw_student_majors.major_id, vw_student_majors.sex, vw_sstudents.sstudent_id,major_name,
		vw_student_majors.student_degree_id, vw_student_majors.degree_name,vw_student_majors.student_id,vw_student_majors.student_name,vw_student_majors.school_id,
		vw_student_majors.school_name,vw_student_majors.department_id,vw_student_majors.department_name,vw_student_majors.sub_level_id,
		vw_student_majors.sub_level_name,vw_student_majors.primary_major,vw_student_majors.major,vw_student_majors.student_major_id,vw_sstudents.approved,vw_sstudents.curr_balance
		
	FROM vw_sstudents
	INNER JOIN vw_student_majors ON vw_student_majors.degree_id = vw_sstudents.degree_id;


CREATE VIEW vw_residence_rooms AS
	SELECT residence_id, residence_name, room_size, capacity, generate_series(1, capacity+1) as room_number
	FROM residences;

CREATE OR REPLACE FUNCTION room_count(integer, integer) RETURNS bigint AS $$
	SELECT count(sstudent_id) FROM sstudents WHERE (sresidence_id = $1) AND (room_number = $2);
$$ LANGUAGE SQL;

CREATE VIEW vw_sresidence_room AS
	SELECT vw_residence_rooms.residence_id, vw_residence_rooms.residence_name, vw_residence_rooms.room_size, vw_residence_rooms.capacity, vw_residence_rooms.room_number, 
		room_count(sresidences.sresidence_id, vw_residence_rooms.room_number) as room_count,
		vw_residence_rooms.room_size - room_count(sresidences.sresidence_id, vw_residence_rooms.room_number) as room_balance,
		sresidences.sresidence_id, sresidences.session_id, sresidences.org_id,
		(sresidences.sresidence_id || 'R' || vw_residence_rooms.room_number) as room_id
	FROM vw_residence_rooms INNER JOIN sresidences ON vw_residence_rooms.residence_id = sresidences.residence_id;

CREATE VIEW vw_sstudent_res_room AS
	SELECT students.student_id, students.student_name, students.Sex, sstudents.sstudent_id,
		vw_sresidence_room.residence_id, vw_sresidence_room.residence_name, vw_sresidence_room.room_size, vw_sresidence_room.capacity,
		vw_sresidence_room.room_number, vw_sresidence_room.room_count, vw_sresidence_room.room_balance, room_id,
		vw_sresidence_room.sresidence_id, vw_sresidence_room.session_id, vw_sresidence_room.org_id,
		sessions.active, sessions.session_name
	FROM (((students INNER JOIN student_degrees ON students.student_id = student_degrees.student_id)
		INNER JOIN sstudents ON student_degrees.student_degree_id = sstudents.student_degree_id)  
		INNER JOIN vw_sresidence_room ON sstudents.sresidence_id = vw_sresidence_room.sresidence_id)
		INNER JOIN sessions ON sstudents.session_id = sessions.session_id
	WHERE (sessions.active = true) AND (vw_sresidence_room.room_balance > 0);

CREATE VIEW vw_scurr_student_degrees AS 
	SELECT vw_sstudent_degrees.org_id, vw_sstudent_degrees.student_id, vw_sstudent_degrees.school_id, vw_sstudent_degrees.student_name, vw_sstudent_degrees.sex, 
		vw_sstudent_degrees.nationality, vw_sstudent_degrees.marital_status, vw_sstudent_degrees.birth_date, vw_sstudent_degrees.email, 
		vw_sstudent_degrees.student_degree_id, vw_sstudent_degrees.degree_id, vw_sstudent_degrees.sub_level_id, vw_sstudent_degrees.sstudent_id, 
		vw_sstudent_degrees.session_id, vw_sstudent_degrees.extra_charges, vw_sstudent_degrees.probation, vw_sstudent_degrees.room_number, 
		vw_sstudent_degrees.curr_balance, vw_sstudent_degrees.finance_approval,  
		vw_sstudent_degrees.finalised, vw_sstudent_degrees.major_approval, 
		 vw_sstudent_degrees.overload_approval, 
		vw_sstudent_degrees.student_dean_approval, vw_sstudent_degrees.overload_hours, vw_sstudent_degrees.inter_session, 
		 vw_sstudent_degrees.approved, vw_sstudent_degrees.no_approval, 
		vw_sstudent_degrees.exam_clear, vw_sstudent_degrees.exam_clear_date, vw_sstudent_degrees.exam_clear_balance,
		vw_sstudent_degrees.sresidence_id, vw_sstudent_degrees.residence_id, vw_sstudent_degrees.residence_name, vw_sstudent_degrees.room_id
		
		
	FROM vw_sstudent_degrees
	JOIN sessions ON vw_sstudent_degrees.session_id = sessions.session_id
	WHERE sessions.active = true;

CREATE VIEW vw_sstudent_scharges AS 
	SELECT vw_student_majors.denomination_id, vw_student_majors.denomination_name,
		vw_student_majors.student_id, vw_student_majors.student_name, vw_student_majors.Nationality, vw_student_majors.Nationality_country,
		vw_student_majors.Sex, vw_student_majors.Marital_Status, vw_student_majors.birth_date, 
		vw_student_majors.degree_level_id, vw_student_majors.degree_level_name, 
		vw_student_majors.degree_id, vw_student_majors.degree_name,
		vw_student_majors.student_degree_id, vw_student_majors.completed, vw_student_majors.started, vw_student_majors.cleared, vw_student_majors.clear_date,
		vw_student_majors.graduated, vw_student_majors.graduate_date, vw_student_majors.drop_out, vw_student_majors.transfer_in, vw_student_majors.transfer_out,
		vw_student_majors.school_id, vw_student_majors.school_name, vw_student_majors.department_id, vw_student_majors.department_name,
		vw_student_majors.major_id, vw_student_majors.major_name, vw_student_majors.elective_credit, vw_student_majors.do_major, vw_student_majors.do_minor,
		vw_student_majors.student_major_id, vw_student_majors.major, vw_student_majors.non_degree, 
		sstudents.sstudent_id, sstudents.session_id, sstudents.sresidence_id, sstudents.extra_charges, sstudents.probation, sstudents.off_campus,
		sstudents.block_name, sstudents.room_number, sstudents.curr_balance,
		sstudents.study_level, sstudents.finalised, sstudents.finance_approval,
		sstudents.major_approval, sstudents.chaplain_approval, sstudents.student_dean_approval, sstudents.overload_approval,
		sstudents.depart_approval, sstudents.overload_hours,sstudents.printed, 
		sstudents.approved, sstudents.finance_narrative, sstudents.no_approval, 
		 sstudents.Approved_Date, sstudents.Picked, sessions.active
	FROM vw_student_majors INNER JOIN sstudents ON vw_student_majors.student_degree_id = sstudents.student_degree_id
		INNER JOIN sessions ON sstudents.session_id = sessions.session_id		
		INNER JOIN scharges ON (vw_student_majors.degree_level_id = scharges.degree_level_id)	AND (sstudents.session_id = scharges.session_id);


CREATE VIEW vw_sstudent_balances AS
	SELECT vw_sstudent_scharges.student_id, vw_sstudent_scharges.student_name, vw_sstudent_scharges.Nationality,
		vw_sstudent_scharges.Nationality_country, vw_sstudent_scharges.Sex, vw_sstudent_scharges.Marital_Status, vw_sstudent_scharges.birth_date, 
		vw_sstudent_scharges.degree_level_id, vw_sstudent_scharges.degree_level_name,
		vw_sstudent_scharges.degree_id, vw_sstudent_scharges.degree_name,
		vw_sstudent_scharges.student_degree_id, vw_sstudent_scharges.school_id, vw_sstudent_scharges.school_name, vw_sstudent_scharges.department_id, vw_sstudent_scharges.department_name,
		vw_sstudent_scharges.major_id, vw_sstudent_scharges.major_name, 
		vw_sstudent_scharges.sstudent_id, vw_sstudent_scharges.session_id, vw_sstudent_scharges.sresidence_id, vw_sstudent_scharges.probation, vw_sstudent_scharges.off_campus,
		vw_sstudent_scharges.study_level, vw_sstudent_scharges.finalised, vw_sstudent_scharges.finance_approval,
		vw_sstudent_scharges.major_approval, vw_sstudent_scharges.chaplain_approval, vw_sstudent_scharges.student_dean_approval, vw_sstudent_scharges.overload_approval,
		vw_sstudent_scharges.depart_approval, vw_sstudent_scharges.overload_hours,   
		vw_sstudent_scharges.approved, vw_sstudent_scharges.finance_narrative, vw_sstudent_scharges.no_approval, 
		vw_sstudent_scharges.curr_balance,vw_sstudents_grades.final_balance,
		vw_sstudent_scharges.Approved_Date, vw_sstudent_scharges.Picked
	FROM vw_sstudent_scharges
	INNER JOIN vw_sstudents_grades ON vw_sstudents_grades.session_id = vw_sstudent_scharges.session_id;		




CREATE VIEW vw_current_residence AS 
	SELECT student_id,vw_sresidences.residence_id, vw_sresidences.residence_name, vw_sresidences.residence_option, vw_sresidences.off_campus, vw_sresidences.charges, vw_sresidences.sresidence_id,  vw_sresidences.org_id
	FROM vw_sresidences
	INNER JOIN vw_sstudents ON vw_sstudents.residence_id=vw_sresidences.residence_id




