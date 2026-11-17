from django.db import connection


def _fetch_all(query, params=None):
    with connection.cursor() as cursor:
        cursor.execute(query, params or [])
        columns = [column[0] for column in cursor.description]
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def customer_total_spent(customer_id):
    with connection.cursor() as cursor:
        cursor.execute("select get_customer_total_spent(%s)", [customer_id])
        return cursor.fetchone()[0]


def films_by_length(len_from, len_to):
    return _fetch_all(
        "select * from get_films_by_length(%s::smallint, %s::smallint)",
        [len_from, len_to],
    )


# {
#   "customer_id": 1,
#   "inventory_id": 1,
#   "staff_id": 1,
#   "amount": "4.99"
# }
def register_rental_with_payment(customer_id, inventory_id, staff_id, amount):
    with connection.cursor() as cursor:
        cursor.execute(
            "call register_rental_with_payment(%s::smallint, %s::smallint, %s::smallint, %s::numeric)",
            [customer_id, inventory_id, staff_id, amount],
        )
