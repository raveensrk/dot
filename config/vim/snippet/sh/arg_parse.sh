help() {
	cat <<-HERE
		Usage
		-----------------

	HERE
	exit 0
}

while [ "$#" -ne 0 ]; do
	case "$1" in
	--help | -h)
		help
		;;
	--input | -i)
		shift
		input="$1"
		;;
	--output | -o)
		shift
		output="$1"
		;;
	*)
		echo "Unknown Argument: $1!"
		exit 2
		;;
	esac
	shift
done
