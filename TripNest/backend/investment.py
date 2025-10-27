import datetime

def calculate_projected_yield(current_balance: float, target_date: datetime.datetime, annual_rate: float = 0.02):
    """
    Calculates the projected yield of a given balance by a target date.
    This is a simplified simulation assuming no further contributions.
    """
    now = datetime.datetime.utcnow()
    years_to_grow = (target_date - now).days / 365.25

    if years_to_grow <= 0:
        return current_balance, 0

    # Using a simple interest calculation for the MVP
    # A = P(1 + rt)
    final_balance = current_balance * (1 + annual_rate * years_to_grow)
    estimated_yield = final_balance - current_balance

    return final_balance, estimated_yield
