import csv
import random
import string
from faker import Faker

fake = Faker('en_US') # Use US locale for realistic names and emails

def generate_distinct_users(num_users):
    users = []
    user_ids = set()
    emails = set()

    while len(users) < num_users:
        user_id = ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))
        if user_id in user_ids:
            continue

        last_name = fake.last_name()
        first_name = fake.first_name()

        # Generate email, ensuring uniqueness
        email_base = f"{first_name.lower()}.{last_name.lower()}"
        email_domain = random.choice(['example.com', 'acmecorp.org', 'globex.net', 'inovatech.co'])
        work_email = f"{email_base}@{email_domain}"

        # Handle potential email clashes if base email already exists
        counter = 1
        original_email = work_email
        while work_email in emails:
            work_email = f"{email_base}{counter}@{email_domain}"
            counter += 1
            if counter > 50: # Avoid infinite loops for highly duplicate names
                email_base = fake.uuid4().split('-')[0] # Fallback to a random string
                work_email = f"{email_base}@{email_domain}"


        user_ids.add(user_id)
        emails.add(work_email)

        users.append({
            'User ID': user_id,
            'Last Name': last_name,
            'First Name': first_name,
            'Work Email': work_email
        })
    return users

# Generate 1000 users
num_records = 1000
user_data = generate_distinct_users(num_records)

# Prepare CSV content
csv_lines = []
headers = ['User ID', 'Last Name', 'First Name', 'Work Email']
csv_lines.append(','.join(headers)) # Add header row

for user in user_data:
    row = [
        user['User ID'],
        user['Last Name'],
        user['First Name'],
        user['Work Email']
    ]
    csv_lines.append(','.join(row))

# Print the CSV content (you can copy this)
print('\n'.join(csv_lines))

#To save to a file directly if you run this script:
with open('users.csv', 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=headers)
    writer.writeheader()
    writer.writerows(user_data)
print(f"\nCSV file 'users.csv' with {num_records} users generated successfully.")
