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


GRANT EXECUTE ON PROCEDURE record_damage_bill(INT, INT, INT, INT, VARCHAR, INT) TO handyman;
GRANT INSERT, SELECT ON damage_bill TO handyman;
GRANT USAGE ON SEQUENCE damage_bill_damage_id_seq TO handyman;


CALL record_damage_bill(
    2,    -- room_no
    2,    -- student_id
    1,    -- porter_id
    1,    -- handyman_id
    'Broken wardrobe door',
    150
);

--Check result
SELECT * FROM damage_bill ORDER BY damage_id DESC LIMIT 5;

-- Invalid test (should fail )
 --INSERT INTO damage_bill(room_no, student_id, porter_id, handyman_id, date, description, repair_cost, due_date)
 --VALUES (3, 3, 2, 2, '2025-02-10', '', -50, '2025-02-05');


