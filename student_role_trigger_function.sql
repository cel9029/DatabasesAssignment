-- 3.curfew_trigger.sql
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
INSERT INTO curfew_violation (student_id, porter_id, room_no, violation_date, violation_time)
VALUES (2, 1, 2, '2025-02-15', '23:50'); -- Should trigger eviction for student 2 (3rd violation)



