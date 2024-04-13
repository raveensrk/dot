help() {
	cat <<-HERE
	Usage
	-----------------

	HERE
}

while [ "$#" -ne 0 ]; do
      case "$1" in
           --help|-h)
                help
                exit 0
                ;;
           --input|-i)
                shift
                input="$1"
                ;;
           --output|-o)
                shift
                output="$1"
                ;;
      esac
      shift
done
