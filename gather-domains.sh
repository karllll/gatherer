#!/bin/sh
###
# Gather hostnames and do any necessary scrubbing of the data.
###

HOME_DIR=/home/gatherer
OUTPUT_DIR=$HOME_DIR/shared/artifacts
INCLUDE_DIR=$HOME_DIR/include

# Create the output directory, if necessary
if [ ! -d $OUTPUT_DIR ]
then
    mkdir $OUTPUT_DIR
fi

cp $OUTPUT_DIR/alldomains.csv gathered.csv

#
# Remove extra columns
cut -d"," -f1 gathered.csv  > scanme.csv

# Remove characters that might break parsing
sed -i '/^ *$/d;/@/d;s/ //g;s/\"//g;s/'\''//g' scanme.csv

# The latest Censys snapshot contains a host name that contains a few
# carriage return characters in the middle of it.  Let's get rid of
# those.
sed -i 's/\r//g' scanme.csv

# We collect a few host names that contain consecutive dots.  These
# seem to always be typos, so replace multiple dots in host names with
# a single dot.
sed -i 's/\.\+/\./g' scanme.csv

# Move the scanme to the output directory
mv scanme.csv $OUTPUT_DIR/scanme.csv

# Let redis know we're done
redis-cli -h redis set gathering_complete true
