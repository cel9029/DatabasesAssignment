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

select * from student;
select * from room;
select * from porter;
select * from handyman;
select * from student_room;

select s.student_id, s.student_name, r.room_no, 
r.location, o.date, o.time, m.menu_id, 
m.description, o.quantity, m.cost_per_unit,
(m.cost_per_unit * o.quantity) as total_cost
from "order" o
join student s using (student_id)
join room r using (room_no)
join menu m using (menu_id);

select * from damage_bill;
select * from room_inspection; 
select * from curfew_violation;
select * from eviction;