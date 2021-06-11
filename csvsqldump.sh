#!/bin/bash
DBNAME=dv
USERNAME=root
PASSWORD=root
OUTPUTDIR=/tmp
TEMPFILE=/tmp/tempfile.csv
for table in `mysql -u ${USERNAME} -p${PASSWORD} -B -N -e "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = '${DBNAME}'"`; do
    echo $table
    fname=${OUTPUTDIR}/$(date +%Y.%m.%d)-$DBNAME-$table.csv
    mysql -u ${USERNAME} -p${PASSWORD} ${DBNAME} -B -N -e "SELECT DISTINCT COLUMN_NAME FROM information_schema.COLUMNS C WHERE table_name = '${table}';" | paste -s -d, - > $fname
    #echo "" >> $fname
    mysql -u ${USERNAME} -p${PASSWORD} ${DBNAME} -B -N -e "SELECT * INTO OUTFILE '${TEMPFILE}' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' FROM ${table};"
    cat ${TEMPFILE} >> $fname
    rm -rf ${TEMPFILE}
done;
