#!/bin/bash

download_jmx_script() {
    JMX_NAME=$1
    JMX_LOCATION=`aws s3 ls s3://<S3BucketLocation>/PE_Scripts --recursive | grep $JMX_NAME | cut -c 32-`
    aws s3 cp s3://<S3BucketLocation>/$JMX_LOCATION /opt/scripts/ >/dev/null 2>&1
}

download_test_data() {
    for FILE_NAME in "${DOWNLOAD_TEST_DATA[@]}"; do
        TEST_DATA_LOCATION=`aws s3 ls s3://<S3BucketLocation>/ --recursive | grep $FILE_NAME | cut -c 32-`
        aws s3 cp s3://<S3BucketLocation>/$TEST_DATA_LOCATION /opt/scripts/ >/dev/null 2>&1
        if [ ${FILE_NAME: -4} == ".zip" ]
        then
            unzip /opt/scripts/$FILE_NAME -d /opt/scripts/
        fi
    done
}

JMETER_COMMAND="/opt/jmeter/bin/jmeter -n -t"
JMETER_SCRIPT_PATH="/opt/scripts/"
JKS_COMMAND="-Djavax.net.ssl.keyStoreType=jks -Djavax.net.ssl.keyStorePassword=D1sney@123 -Djavax.net.ssl.keyStore="

# Check if there more than 0 params
if [ "$#" -gt 0 ]
then
    # Check which params were passed in
    while (( "$#" )); do
        case "$1" in
            --jmx) # URL parameter
                # Store the GitHub download link
                SCRIPT_NAME=$2
                shift 2
            ;;
            --download)
                shift 1
                DOWNLOAD_TEST_DATA=($@)
                shift $#
            ;;
            -J*) # JMeter parameters
                # Store the JMeter params
                JMETER_PARAMETERS+="$1 "
                shift
            ;;
            *|-*|--*=) # Unsupported flags and parameters
                echo "Error: Unsupported flag $1" >&2
                exit 1
            ;;
        esac
    done

    # Appends the script name to the path
    JMETER_SCRIPT_PATH+=$SCRIPT_NAME

    # Calls function to download the JMX from S3
    download_jmx_script $SCRIPT_NAME

    download_test_data

    # Creates name of log file to be used for the JTL and the log file to redirect JMeter STDOUT output
    LOG_NAME="${SCRIPT_NAME//[.jmx]/}"


    # Creates the JTL file
    JTL_LOCATION=/opt/runlogs/${LOG_NAME}.jtl
    touch $JTL_LOCATION
else
    echo "Error: Ensure that the correct parameters were passed in"
fi
