--create role "Porter" with login password 'Porter';
--create schema "Porter" authorization "Porter";
--create role "Handyman" with login password 'Handyman';
--create schema "Handyman" authorization "Handyman";
--create role "Student" with login password 'Student';
--create schema "Student" authorization "Student";

drop table if exists eviction cascade;
drop table if exists curfew_violation cascade;
drop table if exists room_inspection cascade;
drop table if exists damage_bill cascade;
drop table if exists "order" cascade;
drop table if exists student_room cascade;
drop table if exists menu cascade;
drop table if exists handyman cascade;
drop table if exists porter cascade;
drop table if exists room cascade;
drop table if exists student cascade;

create table student (
	student_id serial primary key,
	student_name varchar(50) not null,
	student_address varchar(100) not null,
	course varchar(50) not null,
	yearofcourse date not null,
	student_type varchar(50) not null,
	board_type varchar(50) not null,
	status varchar(50) not null
);

create table room (
	room_no serial primary key,
	room_type varchar(50) not null,
	location varchar(50) not null
);

create table porter (
	porter_id serial primary key,
	porter_name varchar(50) not null
);

create table handyman (
	handyman_id serial primary key,
	handyman_name varchar(50) not null
);

create table menu (
	menu_id serial primary key,
	description varchar(50) not null,
	cost_per_unit numeric(8,2) not null
);

create table student_room (
	student_id integer not null references student,
	room_no integer not null references room,
	start_date date not null,
	end_date date not null,
	primary key (student_id, room_no)
);

create table "order" (
	order_id serial primary key,
	student_id integer not null,
	room_no integer not null,
	menu_id integer not null references menu,
	date date not null,
	time time not null,
	quantity integer not null,
	foreign key(student_id, room_no) references student_room(student_id, room_no)
);

create table damage_bill (
	damage_id serial primary key,
	room_no integer not null references room,
	student_id integer not null references student,
	porter_id integer not null references porter,
	handyman_id integer not null references handyman,
	date date not null,
	description varchar(50) not null,
	repair_cost integer not null,
	due_date date not null
);

create table room_inspection (
	inspection_id serial primary key,
	room_no integer not null references room,
	porter_id integer not null references porter,
	date date not null,
	description varchar(50) not null,
	mark integer not null,
	due_date date not null
);

create table curfew_violation (
	violation_id serial primary key,
	student_id integer not null references student,
	porter_id integer not null references porter,
	room_no integer not null references room,
	violation_date date not null,
	violation_time time not null
);

create table eviction (
	eviction_id serial primary key,
	student_id integer not null references student,
	eviction_date date not null,
	description varchar(50) not null
);

insert into student (student_name, student_address, course, yearofcourse, student_type, board_type, status)
values
('Oliver Cassell', '123 Main St, Dublin', 'Computer Science', '2023-09-01', 'Postgraduate', 'Self-catering', 'Active'),
('Emma Byrne', '45 College Rd, Cork', 'Engineering', '2024-09-01', 'Undergraduate', 'Full board', 'Active'),
('Liam Murphy', '22 Greenway Ave, Galway', 'Business Studies', '2023-09-01', 'Undergraduate', 'Part board', 'Active'),
('Sarah O’Neill', '56 Oak Park, Limerick', 'Mathematics', '2022-09-01', 'Postgraduate', 'Self-catering', 'Active');

insert into room (room_type, location)
values
('Single', 'First Floor'),
('Double', 'Second Floor'),
('Single', 'Third Floor'),
('Double', 'Third Floor');

insert into porter (porter_name)
values
('John Porter'),
('Mary Walsh'),
('Patrick Doyle');

insert into handyman (handyman_name)
values
('Michael Repairman'),
('Tony Fixit');

insert into menu (description, cost_per_unit)
values
('Double Burger', 3.49),
('French Fries', 2.00),
('Side Salad', 2.00),
('Cola Can 500ml', 0.80),
('White Wine 750ml', 14.00);

insert into student_room (student_id, room_no, start_date, end_date)
values
(1, 3, '2025-01-01', '2025-06-01'),
(2, 2, '2025-01-01', '2025-06-01'),
(3, 1, '2025-01-01', '2025-06-01'),
(4, 4, '2025-01-01', '2025-06-01');

insert into "order" (student_id, room_no, menu_id, date, time, quantity)
values
(1, 3, 1, '2025-02-12', '20:00', 8),
(2, 2, 2, '2025-02-12', '20:00', 6),
(3, 1, 3, '2025-02-12', '20:00', 2),
(4, 4, 4, '2025-02-12', '20:00', 16),
(4, 4, 1, '2025-02-17', '20:00', 2),
(3, 1, 2, '2025-02-17', '20:00', 1),
(2, 2, 3, '2025-02-17', '20:00', 1),
(1, 3, 5, '2025-02-17', '20:00', 1),
(3, 1, 5, '2025-02-17', '21:30', 1);

insert into damage_bill (room_no, student_id, porter_id, handyman_id, date, description, repair_cost, due_date)
values
(2, 2, 1, 1, '2025-02-10', 'Broken chair and wall marks', 75, '2025-03-10'),
(4, 3, 2, 2, '2025-01-15', 'Flooded bathroom', 120, '2025-02-15');

insert into room_inspection (room_no, porter_id, date, description, mark, due_date)
values
(1, 1, '2025-01-05', 'Clean and tidy', 9, '2025-02-05'),
(2, 2, '2025-01-06', 'Messy with food waste', 4, '2025-02-06'),
(3, 3, '2025-01-07', 'Furniture broken', 2, '2025-02-07');

insert into curfew_violation (student_id, porter_id, room_no, violation_date, violation_time)
values
(2, 1, 2, '2025-02-01', '23:45'),
(2, 1, 2, '2025-02-10', '00:15'),
(3, 2, 1, '2025-01-30', '23:30'),
(3, 2, 1, '2025-02-05', '00:10');

insert into eviction (student_id, eviction_date, description)
values
(3, '2025-02-20', 'Exceeded curfew violation limit'),
(2, '2025-03-20', 'Unpaid damage bill');

--select * from student;
--select * from room;
--select * from porter;
--select * from handyman;
--select * from student_room;

select s.student_id, s.student_name, r.room_no, 
r.location, o.date, o.time, m.menu_id, 
m.description, o.quantity, m.cost_per_unit,
(m.cost_per_unit * o.quantity) as total_cost
from "order" o
join student s using (student_id)
join room r using (room_no)
join menu m using (menu_id);

--select * from damage_bill;
--select * from room_inspection; 
--select * from curfew_violation;
--select * from eviction;


create or replace procedure add_curfew_violation (
	p_student_id curfew_violation.student_id%type,
	p_porter_id curfew_violation.porter_id%type,
	p_room_no curfew_violation.room_no%type
)
language plpgsql
as $$
declare
	v_student int;
	v_porter int;
	v_valid_room int;
	v_violations int;
begin
	-- Check if Student exists
	select count(*) into v_student
	from student
	where student_id = p_student_id;
	
	if v_student = 0 then
		raise info 'No such Student';
	end if;
	
	-- Check if Porter exists
	select count(*) into v_porter
	from porter
	where porter_id = p_porter_id;
	
	if v_porter = 0 then
		raise info 'No such Porter';
	end if;

	-- Check if students lives in a room
	select count(*) into v_valid_room
	from student_room
	where student_id = p_student_id
	and room_no = p_room_no;
	
	if v_valid_room = 0 then
		raise info 'No such Student lives in room';
	end if;
	
	-- Add curfew violation
	insert into curfew_violation (student_id, porter_id, room_no, violation_date, violation_time)
	values (p_student_id, p_porter_id, p_room_no, current_date, localtime);
	
	raise info 'Curfew Violation recorded successfully';

exception
	when others then
		rollback;
		raise info 'An Error occurred';
end;
$$;

create or replace function prevent_excessive_violations()
returns trigger
language plpgsql
as $$
declare
    v_count integer;
begin
    -- Count violations for this student in the same month
    select COUNT(*)
    into v_count
    from curfew_violation
    where student_id = new.student_id;

    -- If already 5, block the new insert
    if v_count >= 5 then
        raise exception
            'Student % already has 5 curfew violations this month. Insert blocked.',
            new.student_id;
    end if;

    return new;
end;
$$;

create trigger check_violation_limit
after insert on curfew_violation
for each row
execute function prevent_excessive_violations();



--Drop Procedure before creating
DROP PROCEDURE IF EXISTS record_damage_bill;
DROP FUNCTION IF EXISTS check_damage_bill_valid() CASCADE;
DROP TRIGGER IF EXISTS trg_check_damage_bill_valid ON damage_bill;

CREATE OR REPLACE PROCEDURE record_damage_bill(
    p_room_no        INT,
    p_student_id     INT,
    p_porter_id      INT,
    p_handyman_id    INT,
    p_description    VARCHAR(50),
    p_repair_cost    INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists_student   INT;
    v_exists_room      INT;
    v_exists_porter    INT;
    v_exists_handyman  INT;
    v_due_date         DATE := CURRENT_DATE + INTERVAL '30 days';
BEGIN
    SELECT COUNT(*) INTO v_exists_student
    FROM student
    WHERE student_id = p_student_id;
    IF v_exists_student = 0 THEN
        RAISE EXCEPTION 'No such student %', p_student_id;
    END IF;

    SELECT COUNT(*) INTO v_exists_room
    FROM room
    WHERE room_no = p_room_no;
    IF v_exists_room = 0 THEN
        RAISE EXCEPTION 'No such room %', p_room_no;
    END IF;

    SELECT COUNT(*) INTO v_exists_porter
    FROM porter
    WHERE porter_id = p_porter_id;
    IF v_exists_porter = 0 THEN
        RAISE EXCEPTION 'No such porter %', p_porter_id;
    END IF;

    SELECT COUNT(*) INTO v_exists_handyman
    FROM handyman
    WHERE handyman_id = p_handyman_id;
    IF v_exists_handyman = 0 THEN
        RAISE EXCEPTION 'No such handyman %', p_handyman_id;
    END IF;

    IF p_repair_cost IS NULL OR p_repair_cost <= 0 THEN
        RAISE EXCEPTION 'Invalid repair cost %', p_repair_cost;
    END IF;

    IF p_repair_cost > 5000 THEN
        RAISE EXCEPTION 'Cost % too high. Escalate to management', p_repair_cost;
    END IF;

    INSERT INTO damage_bill(
        room_no,
        student_id,
        porter_id,
        handyman_id,
        date,
        description,
        repair_cost,
        due_date
    )
    VALUES(
        p_room_no,
        p_student_id,
        p_porter_id,
        p_handyman_id,
        CURRENT_DATE,
        p_description,
        p_repair_cost,
        v_due_date
    );

    RAISE NOTICE
        'Damage bill created: student %, room %, cost % due on %',
        p_student_id, p_room_no, p_repair_cost, v_due_date;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error: % (%).', SQLERRM, SQLSTATE;
        RAISE;
END;
$$;

--Trigger function
CREATE OR REPLACE FUNCTION check_damage_bill_valid()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.description IS NULL OR length(trim(NEW.description)) = 0 THEN
        RAISE EXCEPTION 'Description cannot be empty';
    END IF;

    IF NEW.repair_cost IS NULL OR NEW.repair_cost <= 0 THEN
        RAISE EXCEPTION 'Invalid repair_cost %', NEW.repair_cost;
    END IF;

    IF NEW.due_date <= NEW.date THEN
        RAISE EXCEPTION
            'Invalid due_date %. Must be after bill date %',
            NEW.due_date, NEW.date;
    END IF;

    RETURN NEW;
END;
$$;

-- Create trigger for data protection
CREATE TRIGGER trg_check_damage_bill_valid
BEFORE INSERT ON damage_bill
FOR EACH ROW
EXECUTE FUNCTION check_damage_bill_valid();

-- place_student_order.sql
-- Programmed Transaction for Student Role
-- PL/pgSQL function to place food orders with comprehensive error checking

CREATE OR REPLACE FUNCTION place_student_order(
    p_student_id INTEGER,
    p_menu_id INTEGER,
    p_quantity INTEGER
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_student_name VARCHAR(50);
    v_menu_description VARCHAR(50);
    v_menu_cost NUMERIC(8,2);
    v_room_no INTEGER;
    v_current_date DATE := CURRENT_DATE;
    v_current_time TIME := CURRENT_TIME;
    v_total_cost NUMERIC(8,2);
    v_student_status VARCHAR(50);
BEGIN
    -- First check if student exists and is active
    SELECT student_name, status 
    INTO v_student_name, v_student_status
    FROM student 
    WHERE student_id = p_student_id;

    IF NOT FOUND THEN
        RETURN 'Error: Student ID ' || p_student_id || ' not found.';
    END IF;
    
    IF v_student_status != 'Active' THEN
        RETURN 'Error: Student is not active. Current status: ' || v_student_status;
    END IF;

    -- Validate student has a room assignment (ignore date range for testing)
    SELECT sr.room_no
    INTO v_room_no
    FROM student_room sr
    WHERE sr.student_id = p_student_id
    -- Remove date checking for testing with future dates:
    -- AND sr.start_date <= v_current_date
    -- AND sr.end_date >= v_current_date
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN 'Error: Student ID ' || p_student_id || ' does not have a room assignment.';
    END IF;

    -- Validate menu item exists
    SELECT description, cost_per_unit
    INTO v_menu_description, v_menu_cost
    FROM menu
    WHERE menu_id = p_menu_id;

    IF NOT FOUND THEN
        RETURN 'Error: Menu Item ID ' || p_menu_id || ' does not exist.';
    END IF;

    -- Validate quantity
    IF p_quantity <= 0 THEN
        RETURN 'Error: Order quantity must be at least 1.';
    END IF;
    
    IF p_quantity > 20 THEN
        RETURN 'Error: Order quantity cannot exceed 20 items.';
    END IF;

    -- Calculate total cost
    v_total_cost := v_menu_cost * p_quantity;

    -- Perform the transaction
    INSERT INTO "order" (student_id, room_no, menu_id, date, time, quantity)
    VALUES (p_student_id, v_room_no, p_menu_id, v_current_date, v_current_time, p_quantity);

    -- Return success message
    RETURN 'Order successful! ' || v_student_name || ' ordered ' || p_quantity || 
           ' x ' || v_menu_description || ' for €' || v_total_cost || 
           ' (Room ' || v_room_no || ').';

EXCEPTION
    WHEN others THEN
        RETURN 'Error: Database error occurred - ' || SQLERRM;
END;
$$;

-- curfew_trigger.sql
-- Constraint Trigger for Automatic Eviction
-- PL/pgSQL trigger function that enforces curfew violation limits

CREATE OR REPLACE FUNCTION check_curfew_auto_evict()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_violation_count INTEGER;
BEGIN
    -- Count current violations for this student (including the new one)
    SELECT COUNT(*) INTO v_violation_count
    FROM curfew_violation
    WHERE student_id = NEW.student_id;

    -- Auto-evict after 3 violations 
    IF v_violation_count >= 3 THEN
        -- Record the eviction
        INSERT INTO eviction (student_id, eviction_date, description)
        VALUES (
            NEW.student_id, 
            CURRENT_DATE, 
            'Exceeded curfew violation limit (' || v_violation_count || ' violations)'
        );
        
        -- End their current room assignment
        UPDATE student_room 
        SET end_date = CURRENT_DATE 
        WHERE student_id = NEW.student_id 
        AND end_date > CURRENT_DATE;
        
        -- Update student status
        UPDATE student 
        SET status = 'Evicted' 
        WHERE student_id = NEW.student_id;
        
        RAISE NOTICE 'Student ID % evicted due to % curfew violations.', 
                     NEW.student_id, v_violation_count;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Create the trigger 
DROP TRIGGER IF EXISTS auto_evict_curfew_violators ON curfew_violation;
CREATE CONSTRAINT TRIGGER auto_evict_curfew_violators
    AFTER INSERT ON curfew_violation
    FOR EACH ROW
    EXECUTE FUNCTION check_curfew_auto_evict();

-- Test the trigger
--INSERT INTO curfew_violation (student_id, porter_id, room_no, violation_date, violation_time)
--VALUES (2, 1, 2, '2025-02-15', '23:50'); -- Should trigger eviction for student 2 (3rd violation)

--INSERT INTO curfew_violation (student_id, porter_id, room_no, violation_date, violation_time)
--VALUES (1, 2, 3, '2025-02-15', '23:50'); -- 




--Grants
GRANT USAGE ON SCHEMA public TO "Handyman";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "Handyman";
GRANT INSERT ON damage_bill TO "Handyman";
GRANT USAGE ON SEQUENCE damage_bill_damage_id_seq TO "Handyman";
GRANT EXECUTE ON PROCEDURE record_damage_bill(INT, INT, INT, INT, VARCHAR, INT) TO "Handyman";
grant select on table student to "Porter";
grant select on table student_room to "Porter";
grant select on table porter to "Porter";
grant select on table curfew_violation to "Porter";
grant insert on table curfew_violation to "Porter";
grant execute on procedure add_curfew_violation to "Porter";
grant usage on schema public to "Porter";
grant update on sequence curfew_violation_violation_id_seq to "Porter";

GRANT SELECT ON student TO student;
GRANT SELECT ON room TO student;
GRANT SELECT ON student_room TO student;
GRANT SELECT ON menu TO student;
GRANT SELECT ON "order" TO student;
GRANT SELECT ON damage_bill TO student;
GRANT SELECT ON room_inspection TO student;
GRANT SELECT ON curfew_violation TO student;
GRANT SELECT ON eviction TO student;
GRANT SELECT ON porter TO student;
GRANT SELECT ON handyman TO student;
-- Grant specific INSERT privileges
GRANT INSERT ON "order" TO student;
-- Grant sequence usage for auto-increment columns
GRANT USAGE ON SEQUENCE order_order_id_seq TO student;

select * from curfew_violation;
SELECT * FROM damage_bill;


