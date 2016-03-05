#!/bin/sh

while getopts a:s:i:g:n:b: option
do
	case "${option}" in
		a) API_KEY=${OPTARG};;
		s) BUILD_SECRET=${OPTARG};;
		i) IPA_PATTERN=${OPTARG};;
		g) GROUP=${OPTARG};;
		n) NOTES=${OPTARG};;
		b) BUILD_DIR=${OPTARG};;
	esac
done

ipaname=$IPA_PATTERN$BUILD_NUMBER".ipa"
./Pods/Crashlytics/submit $API_KEY $BUILD_SECRET -ipaPath $BUILD_DIR/$ipaname -groupAliases $GROUP -notesPath $BUILD_DIR/build_notes.txt