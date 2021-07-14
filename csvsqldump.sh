#!/bin/bash
usage() { 
    echo "Dump SQL data to CSV format with column names in a header row." 1>&2;
    echo "Usage: $0 -u <username> -p <password> -d <database> [-h <host>] [-t <table>] [-o <outputdir>]" 1>&2; 
    echo "Defaults:
    host        localhost
    table       all tables from specified database
    outputdir   /tmp
    " 1>&2; 
    exit 1; 
}

while getopts ":u:p:h:d:t:o:" option; do
    case "${option}" in
        u)
            USERNAME=${OPTARG}
            ;;
        p)
            PASSWORD=${OPTARG}
            ;;
        h)
            HOST=${OPTARG}
            ;;
        d)
            DBNAME=${OPTARG}
            ;;
        t)
            tables=${OPTARG}
            ;;
        o)
            OUTPUTDIR=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${USERNAME}" ] || 
    [ -z "${PASSWORD}" ] ||
    [ -z "${DBNAME}" ]; then
    usage
fi

if [ -z "${HOST}" ]; then
    HOST=localhost
fi

if [ -z "${OUTPUTDIR}" ]; then
    OUTPUTDIR=/tmp
fi

if [ -z "${tables}" ]; then
    tables=$(mysql -u ${USERNAME} -p${PASSWORD} -B -N -e "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = '${DBNAME}'")
fi

# DBNAME=mysql
# USERNAME=root
# PASSWORD=root
TEMPFILE=${OUTPUTDIR}/tempfile.csv

for table in $tables; do
    echo "Processing table ${table}"
    fname=${OUTPUTDIR}/$(date +%Y.%m.%d)-$DBNAME-$table.csv
    if [ -x $fname ]; then
        echo "Do you wish to overwrite?"
    fi
    STATUS=$(mysql -u ${USERNAME} -p${PASSWORD} ${DBNAME} -B -N -e "SELECT DISTINCT COLUMN_NAME FROM information_schema.COLUMNS C WHERE table_name = '${table}';" ) 2>&1 | paste -s -d, - > $fname
    if [ ${PIPESTATUS[0]} -ne "0" ]; then echo "Error encountered ... ${STATUS}"; rm -rf $fname; exit 1; fi
    STATUS=$((mysql -u ${USERNAME} -p${PASSWORD} ${DBNAME} -B -N -e "SELECT * INTO OUTFILE '${TEMPFILE}' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' FROM ${table};" ) 2>&1)
    if [ ${PIPESTATUS[0]} -ne "0" ]; then echo "Error encountered ... ${STATUS}"; rm -rf $fname; continue; fi
    cat ${TEMPFILE} >> $fname
    rm -rf ${TEMPFILE}
done;
