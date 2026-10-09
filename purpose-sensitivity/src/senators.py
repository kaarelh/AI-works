"""Fictional members of the Senate Commerce Committee (shared by sched and whip)."""

# (last name, full name, party-state, building, room)
SENATORS = [
    ("Okafor", "Margaret Okafor", "D-MD", "Hart", "SH-317"),
    ("Whitfield", "Thomas Whitfield", "R-OH", "Russell", "SR-241"),
    ("Vasquez", "Elena Vasquez", "D-NM", "Dirksen", "SD-503"),
    ("Hale", "Robert Hale", "R-TX", "Russell", "SR-128"),
    ("Kowalski", "James Kowalski", "D-MI", "Hart", "SH-724"),
    ("Brandt", "Linda Brandt", "R-NE", "Dirksen", "SD-142"),
    ("Chen", "David Chen", "D-WA", "Hart", "SH-509"),
    ("Mercer", "Paul Mercer", "R-UT", "Russell", "SR-377"),
    ("Lindqvist", "Karen Lindqvist", "D-MN", "Dirksen", "SD-425"),
    ("Doyle", "William Doyle", "R-FL", "Russell", "SR-302"),
    ("Brooks", "Angela Brooks", "D-GA", "Hart", "SH-133"),
    ("Rourke", "Steven Rourke", "R-MT", "Dirksen", "SD-316"),
    ("Haddad", "Nadia Haddad", "D-CA", "Hart", "SH-112"),
    ("Pike", "Gregory Pike", "R-SC", "Russell", "SR-290"),
    ("Stein", "Rachel Stein", "D-NY", "Russell", "SR-322"),
    ("Gallagher", "Mark Gallagher", "R-PA", "Hart", "SH-530"),
    ("Alvarez", "Teresa Alvarez", "D-NV", "Hart", "SH-204"),
    ("Barlow", "John Barlow", "R-WY", "Dirksen", "SD-110"),
    ("Park", "Susan Park", "D-IL", "Dirksen", "SD-524"),
    ("Crowe", "Daniel Crowe", "R-KY", "Russell", "SR-218"),
    ("Ellis", "Monica Ellis", "D-VA", "Russell", "SR-475"),
    ("Lund", "Henry Lund", "R-ID", "Dirksen", "SD-261"),
    ("Moreno", "Patricia Moreno", "D-AZ", "Hart", "SH-416"),
    ("Boone", "Charles Boone", "R-OK", "Dirksen", "SD-332"),
    ("Walsh", "Fiona Walsh", "D-NH", "Hart", "SH-608"),
    ("Ames", "Kenneth Ames", "R-KS", "Russell", "SR-109"),
    ("Grant", "Olivia Grant", "D-CO", "Hart", "SH-320"),
    ("Sandoval", "Victor Sandoval", "R-LA", "Dirksen", "SD-404"),
]

BY_LAST = {s[0]: s for s in SENATORS}


# Fictional House members (for the House companion bill), used only by the scheduling task.
# (last name, full name, party-state, building, room)
REPRESENTATIVES = [
    ("Delgado", "Marisol Delgado", "D-TX-29", "Cannon", "CHOB 214"),
    ("Hughes", "Brian Hughes", "R-IN-5", "Longworth", "LHOB 1027"),
    ("Nakamura", "Kenji Nakamura", "D-CA-17", "Rayburn", "RHOB 2338"),
    ("Pruitt", "Dale Pruitt", "R-GA-9", "Cannon", "CHOB 431"),
    ("Abernathy", "Joan Abernathy", "R-NC-11", "Rayburn", "RHOB 2205"),
    ("Osei", "Kwame Osei", "D-NJ-10", "Longworth", "LHOB 1514"),
    ("Kessler", "Amy Kessler", "D-OR-3", "Cannon", "CHOB 116"),
    ("Varga", "Leo Varga", "R-OH-14", "Rayburn", "RHOB 2443"),
    ("Thornton", "Grace Thornton", "R-MO-2", "Longworth", "LHOB 1203"),
    ("Iqbal", "Sana Iqbal", "D-MI-11", "Rayburn", "RHOB 2112"),
    ("Fischer", "Carl Fischer", "R-WI-6", "Cannon", "CHOB 320"),
    ("Montoya", "Rosa Montoya", "D-CO-8", "Longworth", "LHOB 1730"),
]
