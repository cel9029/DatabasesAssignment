-- Create roles and grant privileges for
-- Revoke all existing privileges first
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM student, porter, handyman;

-- Create roles (without IF NOT EXISTS)
DO $$ 
BEGIN
    -- create roles, ignore if they already exist
    CREATE ROLE student;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ 
BEGIN
    CREATE ROLE porter;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ 
BEGIN
    CREATE ROLE handyman;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ===== GRANT PRIVILEGES =====
-- Grant SELECT on all tables to all roles
GRANT SELECT ON student TO student, porter, handyman;
GRANT SELECT ON room TO student, porter, handyman;
GRANT SELECT ON student_room TO student, porter, handyman;
GRANT SELECT ON menu TO student, porter, handyman;
GRANT SELECT ON "order" TO student, porter, handyman;
GRANT SELECT ON damage_bill TO student, porter, handyman;
GRANT SELECT ON room_inspection TO student, porter, handyman;
GRANT SELECT ON curfew_violation TO student, porter, handyman;
GRANT SELECT ON eviction TO student, porter, handyman;
GRANT SELECT ON porter TO student, porter, handyman;
GRANT SELECT ON handyman TO student, porter, handyman;

-- Grant specific INSERT privileges
GRANT INSERT ON "order" TO student;
GRANT INSERT ON room_inspection TO porter;
GRANT INSERT ON curfew_violation TO porter;
GRANT INSERT ON damage_bill TO handyman;

-- Grant sequence usage for auto-increment columns
GRANT USAGE ON SEQUENCE order_order_id_seq TO student;
GRANT USAGE ON SEQUENCE room_inspection_inspection_id_seq TO porter;
GRANT USAGE ON SEQUENCE curfew_violation_violation_id_seq TO porter;
GRANT USAGE ON SEQUENCE damage_bill_damage_id_seq TO handyman;
-- ===== END GRANTS =====


-- Test student role with sequence access
--SET ROLE student;

-- Should work 
--INSERT INTO "order" (student_id, room_no, menu_id, date, time, quantity) 
--VALUES (1, 3, 1, '2025-02-15', '20:00', 1);

-- Check if it worked
--SELECT * FROM "order" ORDER BY order_id DESC LIMIT 1;

--RESET ROLE;

