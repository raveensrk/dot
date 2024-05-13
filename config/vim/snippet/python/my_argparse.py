import argparse
parser = argparse.ArgumentParser("Description of the code here...")
parser.add_argument("--my-arg", type=str, required=False, default=True, help="HALP...")
parser.add_argument("--my-arg2", action="store_true", required=False, help="HALP...")
args = parser.parse_args()
my_arg = args.my_arg
my_arg2 = args.my_arg2
