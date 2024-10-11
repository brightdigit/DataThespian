#!/bin/sh

set -o pipefail

ERRORS=0

run_command() {
		if [ "$LINT_MODE" == "STRICT" ]; then
				"$@" || ERRORS=$((ERRORS + 1))
		else
				"$@"
		fi
}

if [ "$ACTION" == "install" ]; then 
	if [ -n "$SRCROOT" ]; then
		exit
	fi
fi

export MINT_PATH="$PWD/.mint"
MINT_ARGS="-n -m Mintfile --silent"
MINT_RUN="/opt/homebrew/bin/mint run $MINT_ARGS"

if [ -z "$SRCROOT" ] || [ -n "$CHILD_PACKAGE" ]; then
	SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
	PACKAGE_DIR="${SCRIPT_DIR}/.."
	PERIPHERY_OPTIONS=""
else
	PACKAGE_DIR="${SRCROOT}" 
	PERIPHERY_OPTIONS=""
fi


if [ "$LINT_MODE" == "NONE" ]; then
	exit
elif [ "$LINT_MODE" == "STRICT" ]; then
	SWIFTFORMAT_OPTIONS="--strict --configuration .swift-format"
	SWIFTLINT_OPTIONS="--strict"
else 
	SWIFTFORMAT_OPTIONS="--configuration .swift-format"
	SWIFTLINT_OPTIONS=""
fi

/opt/homebrew/bin/mint bootstrap

echo "LINT Mode is $LINT_MODE"

if [ "$LINT_MODE" == "INSTALL" ]; then
	exit
fi

if [ -z "$CI" ]; then
	run_command $MINT_RUN swiftlint --fix
	pushd $PACKAGE_DIR
	run_command $MINT_RUN swift-format format $SWIFTFORMAT_OPTIONS  --recursive --parallel --in-place Sources Tests Example/Sources
	popd
else 
	set -e
fi

$PACKAGE_DIR/scripts/header.sh -d  $PACKAGE_DIR/Sources -c "Leo Dion" -o "BrightDigit" -p "DataThespian"
run_command $MINT_RUN swiftlint lint $SWIFTLINT_OPTIONS

pushd $PACKAGE_DIR
run_command $MINT_RUN swift-format lint --recursive --parallel $SWIFTFORMAT_OPTIONS Sources Tests Example/Sources
#run_command $MINT_RUN periphery scan $PERIPHERY_OPTIONS --disable-update-check
popd