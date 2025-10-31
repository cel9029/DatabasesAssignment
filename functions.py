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

    
        
        p_room_no = input("Enter Room Number: ")
        p_student_id = input("Enter Student ID: ")
        p_porter_id = input("Enter Porter ID: ")
        p_handyman_id = input("Enter Handyman ID: ")
        p_description = input("Enter Description of Damage: ")
        p_repair_cost = input("Enter Repair Cost: ")

        try:
            cursor.execute(
                "CALL record_damage_bill(%s, %s, %s, %s, %s, %s)",
                (p_room_no, p_student_id, p_porter_id, p_handyman_id, p_description, p_repair_cost)
            )
            connection.commit()
            print("Added to Damage_Bill\n")

        except Exception as e:
            connection.rollback()
            print("Error:", e)

        cursor.execute("SELECT * FROM damage_bill ORDER BY damage_id DESC LIMIT 5")
        df = pd.DataFrame(
            cursor.fetchall(),
            columns=['damage_id','room_no','student_id','porter_id','handyman_id','date','description','repair_cost','due_date']
        )

    elif username == 'Student':
    # Insert Student code
    """Student Residence Database System - STUDENT ROLE
    Python program to demonstrate place_student_order() function"""
    
    class StudentOrderSystem:
    """Handles student food orders with database integration"""
    
    def __init__(self, dbname, user, password, host='localhost', port='5432'):
        self.db_config = {
            'dbname': dbname, 'user': user, 'password': password,
            'host': host, 'port': port
        }
        self.conn = None
        self.cursor = None
    
    def connect(self):
        """Establish database connection"""
        try:
            print("Connecting to database...")
            self.conn = psycopg2.connect(**self.db_config)
            self.conn.autocommit = False
            self.cursor = self.conn.cursor()
            
            print(f"SUCCESS: Connected to {self.db_config['dbname']}")
            return True
            
        except psycopg2.OperationalError as e:
            print(f"ERROR: Connection failed - {e}")
            return False
    
    def place_order(self, student_id, menu_id, quantity):
        """Place food order using PL/pgSQL function"""
        try:
            self.cursor.execute(
                "SELECT place_student_order(%s, %s, %s);",
                (student_id, menu_id, quantity)
            )
            result = self.cursor.fetchone()[0]
            self.conn.commit()
            return result
            
        except psycopg2.Error as e:
            self.conn.rollback()
            return f"Database error: {e}"
    
    def display_menu(self):
        """Show available menu items"""
        try:
            print("\n" + "="*50)
            print("AVAILABLE MENU ITEMS")
            print("="*50)
            
            self.cursor.execute("SELECT menu_id, description, cost_per_unit FROM menu ORDER BY menu_id;")
            
            print(f"\n{'ID':<4} {'Item':<25} {'Price':<10}")
            print("-"*50)
            
            for item in self.cursor.fetchall():
                print(f"{item[0]:<4} {item[1]:<25} €{item[2]:.2f}")
            
            print("="*50)
            
        except psycopg2.Error as e:
            print(f"ERROR loading menu: {e}")
    
    def view_orders(self, student_id):
        """Show student's order history"""
        try:
            print(f"\nORDER HISTORY - Student {student_id}")
            print("="*60)
            
            self.cursor.execute("""
                SELECT o.order_id, o.date, o.time, m.description, 
                       o.quantity, m.cost_per_unit, (o.quantity * m.cost_per_unit) as total
                FROM "order" o JOIN menu m ON o.menu_id = m.menu_id
                WHERE o.student_id = %s
                ORDER BY o.date DESC, o.time DESC;
            """, (student_id,))
            
            orders = self.cursor.fetchall()
            
            if orders:
                print(f"{'ID':<6} {'Date':<12} {'Item':<20} {'Qty':<4} {'Total':<8}")
                print("-"*60)
                
                for order in orders:
                    print(f"{order[0]:<6} {order[1]} {order[3]:<20} {order[4]:<4} €{order[6]:.2f}")
            else:
                print("No orders found")
            
            print("="*60)
            
        except psycopg2.Error as e:
            print(f"ERROR loading orders: {e}")
    
    def get_total_spent(self, student_id):
        """Calculate total amount spent by a student"""
        try:
            self.cursor.execute("""
                SELECT COALESCE(SUM(o.quantity * m.cost_per_unit), 0) as total_spent
                FROM "order" o 
                JOIN menu m ON o.menu_id = m.menu_id
                WHERE o.student_id = %s;
            """, (student_id,))
            
            result = self.cursor.fetchone()
            return result[0] if result else 0
            
        except psycopg2.Error as e:
            print(f"ERROR calculating total spent: {e}")
            return 0
    
    def close(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
        print("\nConnection closed")


def run_test(system, test_num, description, student_id, menu_id, quantity):
    """Run a single test case"""
    print(f"\nTEST {test_num}: {description}")
    print(f"   Parameters: student_id={student_id}, menu_id={menu_id}, quantity={quantity}")
    
    result = system.place_order(student_id, menu_id, quantity)
    
    if result.startswith('Order successful'):
        print(f"   SUCCESS: {result}")
    else:
        print(f"   FAILED: {result}")
    
    return result


def main():
    """Main program with test demonstrations"""
    
    # Header
    print("\n" + "="*60)
    print("STUDENT RESIDENCE - FOOD ORDERING SYSTEM")
    print("Role: STUDENT | Function: place_student_order()")
    print("="*60)
    
    # Database configuration
    DB_CONFIG = {
        'dbname': 'newstud',
        'user': 'postgres', 
        'password': 'postgres',
        'host': 'localhost',
        'port': '5432'
    }
    
    # Initialize system
    system = StudentOrderSystem(**DB_CONFIG)
    
    if not system.connect():
        sys.exit(1)
    
    try:
        # Show menu first
        system.display_menu()
        
        print("\nDEMONSTRATING ORDER FUNCTION")
        print("="*50)
        
        # Test cases
        tests = [
            (1, "Valid Order", 1, 1, 2),
            (2, "Invalid Student", 999, 1, 2),
            (3, "Invalid Menu Item", 1, 999, 2),
            (4, "Zero Quantity", 1, 1, 0),
            (5, "Excessive Quantity", 1, 1, 25),
            (6, "Another Valid Order", 4, 5, 1),
            (7, "Maximum Quantity", 1, 2, 20)
        ]
        
        # Run all tests
        for test in tests:
            run_test(system, *test)
        
        # Show order history
        system.view_orders(student_id=1)
        
        # Summary with total spent
        print("\n" + "="*60)
        print("SPENDING SUMMARY")
        print("="*60)
        
        # Get totals for all students tested
        student_totals = []
        for student_id in [1, 4]:  # Students we placed orders for
            total = system.get_total_spent(student_id)
            student_totals.append((student_id, total))
        
        # Display individual student totals
        for student_id, total in student_totals:
            print(f"Student {student_id}: €{total:.2f}")
        
        # Calculate overall total
        overall_total = sum(total for _, total in student_totals)
        print("-" * 60)
        print(f"OVERALL TOTAL SPENT: €{overall_total:.2f}")
        print("=" * 60)
        
        # Functionality summary
        print("\nFUNCTIONALITY VERIFIED")
        print("="*40)
        print("Database connection & transactions")
        print("Student validation & room assignment") 
        print("Menu item validation")
        print("Quantity validation (1-20 items)")
        print("Automatic cost calculation")
        print("Error handling & rollback")
        
    except Exception as e:
        print(f"Unexpected error: {e}")
    finally:
        system.close()


if __name__ == "__main__":
    main()


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
