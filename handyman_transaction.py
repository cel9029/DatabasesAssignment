import psycopg2

def record_damage(room_no, student_id, porter_id, handyman_id, description, repair_cost):
    try:
        # Connecting to database
        #Need to be changed for TUD Database
        conn = psycopg2.connect(
            host="localhost",
            port=54322,              
            dbname="postgres",       
            user="postgres",         
            password="postgres"      
        )

        # Starting transaction
        cur = conn.cursor()

        try:
            print("Starting transaction...")

            #Calling procedure
            cur.execute("""
                CALL record_damage_bill(%s, %s, %s, %s, %s, %s);
            """, (room_no, student_id, porter_id, handyman_id, description, repair_cost))

            #If everything ok - commit
            conn.commit()
            print("Commit successfull, data recorded")

        except Exception as e:
            conn.rollback()
            print("Error:", e)
        finally:
            cur.close()
            conn.close()

    except psycopg2.Error as conn_err:
        print("Database connection error:", conn_err)


#First record with correct data
record_damage(
    room_no=2,
    student_id=2,
    porter_id=1,
    handyman_id=1,
    description="Door hinges broken",
    repair_cost=200
)

#Second record with invalid description(Trigger test)
record_damage(
    room_no=2,
    student_id=2,
    porter_id=1,
    handyman_id=1,
    description="",
    repair_cost=150
)
