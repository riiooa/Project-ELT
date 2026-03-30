import subprocess

print("Transfering data....")

# Use pg_dump to dump the source database to a SQL file
dump_command = [
    'pg_dump',
    '-h', 'source_postgres',
    '-U', 'postgres',
    '-d', 'source_db',
    '-f', 'data_dump.sql',
    '-w'  # Do not prompt for password
]

# Set the PGPASSWORD environment variable to avoid password prompt
subprocess.run(dump_command, env={'PGPASSWORD': 'secret'}, check=True)

# Use psql to load the dumped SQL file into the destination database
load_command = [
    'psql',
    '-h', 'destination_postgres',
    '-U', 'postgres',
    '-d', 'destination_db',
    '-a', '-f', 'data_dump.sql'
]

# Set the PGPASSWORD environment variable for the destination database
subprocess.run(load_command, env={'PGPASSWORD': 'secret'}, check=True)

print("Ending transfer...")