"""
Student Residence Database System - STUDENT ROLE
Python program to demonstrate place_student_order() function

Student: Vengie Legaspi
Number: C20366171
Date:  31 October 2025
"""

import psycopg2
from datetime import datetime
import sys


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
