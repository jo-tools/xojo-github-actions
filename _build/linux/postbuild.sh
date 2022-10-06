#!/bin/sh
#
clear

# get input
BUILD_FOLDER_PARENT=$1
BUILD_FOLDER_NAME=$2
TGZ_NAME=$3

function exit_with_error ()
{
	echo "\033[1;31m**************************\033[0m"
	echo "\033[1;31m* Linux Post Build Error *\033[0m"
	echo "\033[1;31m**************************\033[0m"
	printf "\033[1;31m$1\033[0m\n\n"
	exit 10;
}

# get current directory
SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# sanity checks: script
if [ ! -d "${SCRIPT_DIRECTORY}" ]; then
	exit_with_error "SCRIPT_DIRECTORY doesn't exist."
fi

cd ${SCRIPT_DIRECTORY}

# sanity checks: github actions/runner environment
if [ -z ${GITHUB_WORKSPACE} ]; then
	exit_with_error "GITHUB_WORKSPACE isn't defined."
fi
if [ ! -d ${GITHUB_WORKSPACE} ]; then
	exit_with_error "GITHUB_WORKSPACE doesn't exist."
fi

cd ${GITHUB_WORKSPACE}

# sanity check: build
if [ -z "${BUILD_FOLDER_PARENT}" ]; then
	exit_with_error "BUILD_FOLDER_PARENT isn't defined."
fi
if [ -z "${BUILD_FOLDER_NAME}" ]; then
	exit_with_error "BUILD_FOLDER_NAME isn't defined."
fi
if [ -z "${TGZ_NAME}" ]; then
	exit_with_error "TGZ_NAME isn't defined."
fi
if [ ! -d "./${BUILD_FOLDER_PARENT}" ]; then
	exit_with_error "BUILD_FOLDER_PARENT doesn't exist."
fi
if [ ! -d "${BUILD_FOLDER_PARENT}/${BUILD_FOLDER_NAME}" ]; then
	exit_with_error "BUILD_FOLDER_PARENT/BUILD_FOLDER_NAME doesn't exist."
fi

# cleanup build folder
cd "${BUILD_FOLDER_PARENT}"
find "./${BUILD_FOLDER_NAME}" -name '._*' -type f -delete
find "./${BUILD_FOLDER_NAME}" -name '.DS_Store' -type f -delete
find "./${BUILD_FOLDER_NAME}" -name 'Thumbs.db' -type f -delete

# create .tgz
tar cvfz ./"${TGZ_NAME}" "./${BUILD_FOLDER_NAME}"


# sanity check: tgz
if [ ! -f ./"${TGZ_NAME}" ]; then
	exit_with_error "TGZ doesn't exist."
fi

exit 0