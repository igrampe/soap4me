#!/bin/sh

while getopts a:u:b: option
do
	case "${option}" in
		a) API_TOKEN=${OPTARG};;
		u) USER=${OPTARG};;
		b) BUILD_DIR=${OPTARG};;
	esac
done

rm -f $BUILD_DIR/build_notes.txt
GIT_LOG_FORMAT="\n%s\n"

LAST_SUCCESS_URL_SUFFIX="lastSuccessfulBuild/api/xml"
URL="$JOB_URL$LAST_SUCCESS_URL_SUFFIX"
LAST_SUCCESS_REV=$(curl --silent --user $USER:$API_TOKEN $URL | grep "<lastBuiltRevision>" | sed 's|.*<lastBuiltRevision>.*<SHA1>\(.*\)</SHA1>.*<branch>.*|\1|')
# Pulls all commit comments since the last successfully built revision
LOG=$(git log --pretty="$GIT_LOG_FORMAT" $LAST_SUCCESS_REV..HEAD)

echo $LOG | sed '/./,$!d' >> $BUILD_DIR/build_notes.txt