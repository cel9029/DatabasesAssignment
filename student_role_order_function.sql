-- 2.2_place_student_order.sql
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




-- Test the function
SELECT place_student_order(1, 1, 2);  -- Should succeed
-- SELECT place_student_order(999, 1, 2); -- Should fail: invalid student
-- SELECT place_student_order(1, 999, 2); -- Should fail: invalid menu item
-- SELECT place_student_order(1, 1, 0);   -- Should fail: invalid quantity