import psycopg2, getpass, pandas as pd
from psycopg2 import Error
try:
    username = input('Enter your Username: ')
    pw = input('Enter your password: ')
    connection = psycopg2.connect(
    host="localhost", user = username,
    password=pw,
    port="54321", database="postgres")
    cursor = connection.cursor()
    if username == 'Porter':
        p_student_id = input('Enter Student ID: ')
        p_porter_id = input('Enter Porter ID: ')
        p_room_no = input('Enter Room Number: ')
        cursor.execute("CALL add_curfew_violation(%s, %s, %s)", (p_student_id, p_porter_id, p_room_no))
        connection.commit()

        posgreSQL_select_Query = 'select * from curfew_violation'
        cursor.execute(posgreSQL_select_Query)
        df = pd.DataFrame(
            cursor.fetchall(),
            columns=['violation_id', 'student_id', 'porter_id', 'room_no', 'violation_date', 'violation_time']
        )
    elif username == 'Handyman':
    # Insert Handyman code
        p_student_id = input('Enter Student ID: ')
        p_porter_id = input('Enter Porter ID: ')
        p_room_no = input('Enter Room Number: ')
        cursor.execute("CALL add_curfew_violation(%s, %s, %s)", (p_student_id, p_porter_id, p_room_no))
        connection.commit()
        
        posgreSQL_select_Query = 'select * from curfew_violation'
        cursor.execute(posgreSQL_select_Query)
        df = pd.DataFrame(
            cursor.fetchall(),
            columns=['violation_id', 'student_id', 'porter_id', 'room_no', 'violation_date', 'violation_time']
        )
    elif username == 'Student':
    # Insert Student code
        p_student_id = input('Enter Student ID: ')
        p_porter_id = input('Enter Porter ID: ')
        p_room_no = input('Enter Room Number: ')
        cursor.execute("CALL add_curfew_violation(%s, %s, %s)", (p_student_id, p_porter_id, p_room_no))
        connection.commit()
        
        posgreSQL_select_Query = 'select * from curfew_violation'
        cursor.execute(posgreSQL_select_Query)
        df = pd.DataFrame(
            cursor.fetchall(),
            columns=['violation_id', 'student_id', 'porter_id', 'room_no', 'violation_date', 'violation_time']
        )

    print(df)
except (Exception, Error) as error:
    print("Error while connecting to PostgreSQL", error)
finally:
    if (connection):
        cursor.close()
        connection.close()
        print("PostgreSQL connection is closed")
    else:
        print("Terminating")