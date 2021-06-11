# CSV SQL Dump

This is a quick script to dump MySQL/MariaDB databases to a .csv file complete with column headers

## Usage:
./csvsqldump.sh -u *username* -p *password* -d *database* -t *table* [ -o *outfile* ]

if *outfile* is not specified, dump will go to stdout
