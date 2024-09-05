#!/bin/sh

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
	SWIFTFORMAT_OPTIONS="--strict"
else 
	SWIFTFORMAT_OPTIONS=""
fi

/opt/homebrew/bin/mint bootstrap

echo "LINT Mode is $LINT_MODE"

if [ "$LINT_MODE" == "INSTALL" ]; then
	exit
fi

if [ -z "$CI" ]; then
	$MINT_RUN swift-format format --recursive --parallel --in-place $PACKAGE_DIR/Sources
else 
	set -e
fi

$PACKAGE_DIR/scripts/header.sh -d  $PACKAGE_DIR/Sources -c "Leo Dion" -o "BrightDigit" -p "DataThespian"
$MINT_RUN swift-format lint --recursive --parallel $SWIFTFORMAT_OPTIONS $PACKAGE_DIR/Sources

pushd $PACKAGE_DIR
$MINT_RUN periphery scan $PERIPHERY_OPTIONS --disable-update-check
popd