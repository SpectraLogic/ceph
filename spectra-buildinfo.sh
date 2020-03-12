#!/bin/bash
#
# Generate some build information that my be useful
#
PROG=$(basename $0)
OUTPUT="${1:-none}"	# Output file is assumed to be in the artifacts directory
BLDNUM="${2:-0}"	# Jenkins build number
shift 2
ARTIFACTS="$@"		# Files and directories that are our "artifacts" relative to dirname $OUTPUT
PFMT="%-15s %s\n"


error()
{
	printf "${PROG}: $@\n" >&2
	exit 3
}

[ "$OUTPUT" == "none" ] && error "no output file specified"
[ "$BLDNUM" == "none" ] && error "no build number specified"

GIT_COMMIT="$(git rev-parse HEAD)"
GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

dir=$(dirname $OUTPUT)
file=$(basename $OUTPUT)
cd $dir || error "cd $dir failed"

printf "$PFMT" "DATE:" "$(date +%Y%m%d.%H:%M)" > $file || error "failed to create $OUTPUT"
printf "$PFMT" "BUILD_NUMBER:" "$BLDNUM" >> $file
printf "$PFMT" "GIT_BRANCH:" "$GIT_BRANCH" >> $file
printf "$PFMT" "GIT_COMMIT:" "$GIT_COMMIT" >> $file
printf "$PFMT" "FILES:" >> $file
find $ARTIFACTS >> $file

exit 0
