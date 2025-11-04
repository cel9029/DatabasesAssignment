import psycopg2, getpass, pandas as pd
from psycopg2 import Error
def main():
    conn = psycopg2.connect(
        host="147.252.250.51",
        port=5432,
        dbname="postgres",
        user="C23748139",
        password="C23748139",
        options='-c search_path="C22455366",public' #Might need to be changed
    )

    cur = conn.cursor()

    room_no     = int(input("Enter Room Number: "))
    student_id  = int(input("Enter Student ID: "))
    porter_id   = int(input("Enter Porter ID: "))
    handyman_id = int(input("Enter Handyman ID: "))
    description = input("Enter Description of Damage: ")
    repair_cost = int(input("Enter Repair Cost: "))

    try:
        cur.execute(
            
            "CALL record_damage_bill(%s, %s, %s, %s, %s, %s)",
            (room_no, student_id, porter_id, handyman_id, description, repair_cost)
        )
        conn.commit()
        print("Added to Database")
        posgreSQL_select_Query = 'select * from damage_bill'
        cur.execute(posgreSQL_select_Query)
        df = pd.DataFrame(
            cur.fetchall(),
            columns=['damage_id', 'room_no', 'student_id', 'porter_id', 'handyman_id', 'date', 'description', 'repair_cost', 'due_date' ]
        )
        print(df)
    except Exception as e:
        conn.rollback()
        print("Error:", e)

    cur.close()
    conn.close()

#Run code
main()
