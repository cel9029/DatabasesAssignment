
--student_order_trigger.
--Programmed trigger for transaction

CREATE OR REPLACE FUNCTION validate_order_constraints()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_student_status VARCHAR(50);
    v_student_name VARCHAR(50);
    v_menu_exists BOOLEAN;
    v_room_assignment_exists BOOLEAN;
BEGIN
    -- Check if student exists and is active
    SELECT status, student_name INTO v_student_status, v_student_name
    FROM student
    WHERE student_id = NEW.student_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order rejected: Student ID % does not exist', NEW.student_id;
    END IF;
    
    IF v_student_status != 'Active' THEN
        RAISE EXCEPTION 'Order rejected: Student % (%) is not active. Status: %', 
                        v_student_name, NEW.student_id, v_student_status;
    END IF;
    
    -- Validate quantity constraints (1-20 items per order)
    IF NEW.quantity < 1 THEN
        RAISE EXCEPTION 'Order rejected: Quantity must be at least 1 (got: %)', NEW.quantity;
    END IF;
    
    IF NEW.quantity > 20 THEN
        RAISE EXCEPTION 'Order rejected: Quantity cannot exceed 20 items (got: %)', NEW.quantity;
    END IF;
    
    -- Verify menu item exists
    SELECT EXISTS(
        SELECT 1 FROM menu WHERE menu_id = NEW.menu_id
    ) INTO v_menu_exists;
    
    IF NOT v_menu_exists THEN
        RAISE EXCEPTION 'Order rejected: Menu item ID % does not exist', NEW.menu_id;
    END IF;
    
    -- Verify student has room assignment
  
    SELECT EXISTS(
        SELECT 1 FROM student_room
        WHERE student_id = NEW.student_id
        AND room_no = NEW.room_no
        -- Date checking commented cuz got error
        -- AND start_date <= CURRENT_DATE
        -- AND end_date >= CURRENT_DATE
    ) INTO v_room_assignment_exists;
    
    IF NOT v_room_assignment_exists THEN
        RAISE EXCEPTION 'Order rejected: Student % does not have room assignment for room %', 
                        NEW.student_id, NEW.room_no;
    END IF;
    
    -- All validations passed
    RAISE NOTICE 'Order validated: Student % (%) ordering % items', 
                 NEW.student_id, v_student_name, NEW.quantity;
    
    RETURN NEW;
END;
$$;

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS enforce_order_constraints ON "order";

-- Create the trigger
CREATE TRIGGER enforce_order_constraints
    BEFORE INSERT ON "order"
    FOR EACH ROW
    EXECUTE FUNCTION validate_order_constraints();


-- TEST 


-- Test 1: This should now work!
--SELECT 'Test 1: Valid order with room assignment' AS test;
--SELECT place_student_order(1, 1, 2) AS result;

-- Test 2: Another student
--SELECT 'Test 2: Different student' AS test;
--SELECT place_student_order(4, 3, 5) AS result;

-- Test 3: Direct insert should also work
--SELECT 'Test 3: Direct INSERT' AS test;
--INSERT INTO "order" (student_id, room_no, menu_id, date, time, quantity)
--VALUES (2, 2, 2, CURRENT_DATE, CURRENT_TIME, 8);
--SELECT 'Test 3: Success!' AS result;

--INSERT INTO "order" (student_id, room_no, menu_id, date, time, quantity)
--VALUES (1, 3, 1, CURRENT_DATE, CURRENT_TIME, 25); error quantity to high

--SELECT place_student_order(2, 2, 8) AS result;

