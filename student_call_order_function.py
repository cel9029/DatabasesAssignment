"""
Student Residence Database - STUDENT ROLE
Student: Vengie Legaspi (C20366171)
Date: 3 November 2025
Student order/transaction program 
"""
import psycopg2
import pandas as pd
from psycopg2 import Error

def main():
    # Database connection
    conn = psycopg2.connect(
        host="147.252.250.51",
        port=5432,
        dbname="postgres",
        user="C20366171",
        password="postgres",
        options='-c search_path="C22455366",public'
    )
    cur = conn.cursor()
    
    # Display menu first
    print("\n           === MENU ===")
    cur.execute("SELECT menu_id, description, cost_per_unit FROM menu ORDER BY menu_id")
    menu_df = pd.DataFrame(
        cur.fetchall(),
        columns=['Menu ID', 'Item', 'Price (€)']
    )
    print(menu_df.to_string(index=False))
    print()
    
    # Get user input
    student_id = int(input("Enter Student ID (1-4): "))
    menu_id    = int(input("Enter Menu Item ID (1-5): "))
    quantity   = int(input("Enter Quantity (1-20): "))
    
    try:
        # Call the function
        cur.execute(
            "SELECT place_student_order(%s, %s, %s)",
            (student_id, menu_id, quantity)
        )
        result = cur.fetchone()[0]
        conn.commit()
        print("\n           ===Added to Database===")
        print("Result:", result)
        
        # Show recent orders
        print("\n       === RECENT ORDERS (Last 10) ===")
        cur.execute('''
            SELECT o.order_id, o.student_id, o.room_no, 
                   m.description, o.quantity, o.date, o.time,
                   (o.quantity * m.cost_per_unit) as total_cost
            FROM "order" o 
            JOIN menu m ON o.menu_id = m.menu_id
            ORDER BY o.order_id DESC LIMIT 10
        ''')
        recent_df = pd.DataFrame(
            cur.fetchall(),
            columns=['Order ID', 'Student', 'Room', 'Item', 'Qty', 'Date', 'Time', 'Cost (€)']
        )
        print(recent_df.to_string(index=False))
        
        # Show all students that ordered
        print("\n       === ALL STUDENTS WHO ORDERED ===")
        cur.execute('''
            SELECT o.student_id,
                   COUNT(o.order_id) as total_orders,
                   SUM(o.quantity) as total_items
            FROM "order" o
            GROUP BY o.student_id
            ORDER BY o.student_id
        ''')
        students_df = pd.DataFrame(
            cur.fetchall(),
            columns=['Student ID', 'Total Orders', 'Total Items']
        )
        print(students_df.to_string(index=False))
        
        # Show totals
        print("\n       === TOTALS ===")
        cur.execute('''
            SELECT 
                COUNT(DISTINCT student_id) as total_students,
                COUNT(order_id) as total_orders,
                SUM(quantity) as total_items,
                SUM(quantity * (SELECT cost_per_unit FROM menu WHERE menu_id = o.menu_id)) as total_revenue
            FROM "order" o
        ''')
        totals = cur.fetchone()
        print(f"Total Students Who Ordered: {totals[0]}")
        print(f"Total Orders Placed: {totals[1]}")
        print(f"Total Items Ordered: {totals[2]}")
        print(f"Total students spent: €{totals[3]:.2f}")
        
    except Exception as e:
        conn.rollback()
        print("Error:", e)
    finally:
        cur.close()
        conn.close()

# Run code
if __name__ == "__main__":
    main()