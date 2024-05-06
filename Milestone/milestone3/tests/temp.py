class Person:
    def __init__(self, id_number: int):
        self.id_number : int = id_number

    def check_in(self) -> None:
        print("Person with ID:")
        print(self.id_number)
        print("checked in.")

class Passenger(Person):
    def __init__(self, id_number: int, name: str):
        self.id_number = id_number
        self.name: str = name
    
    def booked_ticket(self, ticket_number: int) -> None:
        print("Ticket booked for")
        print(self.name)

class Crew(Person):
    def __init__(self, id_number: int, name:str, role: str):
        self.id_number = id_number
        self.name: str = name
        self.role: str = role

    def on_duty(self, flight_number: int) -> None:
        print("Crew member")
        print(self.name)
        print("is on duty as")
        print(self.role)
        print("on flight number")
        print(flight_number)

class Flight:
    def __init__(self, flight_number: int, departure: str, destination: str, capacity: int) -> None:
        self.flight_number: int = flight_number
        self.departure: str = departure
        self.destination: str = destination
        self.capacity: int = capacity

class Ticket:
    def __init__(self, flight_number: int, price: int, ticket_number: int) -> None:
        self.flight: int = flight_number
        self.ticket_number: int = ticket_number
        self.price: int = price

    def update_price(self, new_price: int) -> None:
        self.price = new_price
        print("New ticket price for")
        print(self.price)



def main():
    
    flight1: Flight = Flight(12, "New York", "Los Angeles", 5)
    flight2: Flight = Flight(13, "Los Angeles", "New York", 5)


    Passenger1: Passenger = Passenger(1, "Jane Austen")
    Passenger1.check_in()
    Ticket1: Ticket = Ticket(12, 350, 1)
    Passenger1.booked_ticket(1)

    print("-------------------------")

    Passenger2: Passenger = Passenger(2, "John Doe")
    Passenger2.check_in()
    Ticket2: Ticket = Ticket(13, 450, 2)
    Passenger2.booked_ticket(2)

    print("-------------------------")

    Passenger3: Passenger = Passenger(3, "Alice Smith")
    Passenger3.check_in()
    Ticket3: Ticket = Ticket(12, 350, 3)
    Passenger3.booked_ticket(3)

    print("-------------------------")

    Crew1: Crew = Crew(4, "Shawn Dawson", "Pilot")
    Crew1.check_in()
    Crew1.on_duty(flight1.flight_number)

    print("-------------------------")

    Crew2: Crew = Crew(5, "Lily Smith", "Pilot")
    Crew2.check_in()
    Crew2.on_duty(flight2.flight_number)

    print("-------------------------")

    if Ticket2.flight == flight2.flight_number:
        Ticket2.update_price(300)


if __name__ == "__main__":
  main()
