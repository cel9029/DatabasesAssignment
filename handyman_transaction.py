import psycopg2

def main():
    conn = psycopg2.connect(
        host="localhost",
        port=54325,
        dbname="postgres",
        user="Handyman",
        password="Handyman"
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
    except Exception as e:
        conn.rollback()
        print("Error:", e)

    cur.close()
    conn.close()

#Run code
main()
