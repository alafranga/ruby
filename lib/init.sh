# shellcheck shell=bash

set -Eeuo pipefail; shopt -s nullglob; unset CDPATH; IFS=$' \t\n'

export LC_ALL=C.UTF-8 LANG=C.UTF-8

abort() {
	echo -e "\e[1m\e[38;5;9m✗\e[0m \e[1m$*\e[0m" >&2
	exit 1
}

doing() {
	echo -e "\e[1m\e[38;5;14m>\e[0m \e[1m$*\e[0m" >&2
}

warn() {
	echo -e "\e[1m\e[38;5;11m!\e[0m $*\e[0m" >&2
}

init() {
	local dir

	if [[ -d ${LOCAL_DIR:-} ]]; then
		dir="$LOCAL_DIR"
	else
		dir="${BASH_SOURCE[0]%/*}"/../..
	fi 

	cd "$dir" || abort "Failed to chdir: $dir"

	for BUNDLE_GEMFILE in Gemfile .local/etc/Gemfile; do
		if [[ -f $BUNDLE_GEMFILE ]]; then
			break
		fi

		unset BUNDLE_GEMFILE
	done

	# Only chance for customization
	[[ ! -f .local/etc/environment ]] || builtin source .local/etc/environment

	# Simple case; no Gemfile, no Bundler
	if [[ -z ${BUNDLE_GEMFILE:-} ]]; then
		[[ -d .local ]] || warn "No .local directory found at: ${PWD:-}"

		bexec() {
			"$@"
		}

		ruby() {
			command ruby "$@"
		}

		export -f bexec ruby

		return 0
	fi

	export BUNDLE_GEMFILE=$PWD/$BUNDLE_GEMFILE BUNDLE_PATH=$PWD/.local/var BUNDLE_BIN=$PWD/.local/var/bin BUNDLE_JOBS=4
	export PATH=$BUNDLE_BIN:$PATH

	# Needs for aggressively restricted Github actions, i.e. education/autograding
	[[ -n "${HOME:-}" ]] || export HOME=$PWD/.local/tmp

	# Conveniency helpers for scripting
	bexec() {
		bundle exec "$@"
	}

	ruby() {
		bundle exec ruby "$@"
	}

	export -f bexec ruby
}

init
