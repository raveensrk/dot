import argparse
parser = argparse.ArgumentParser("Description of the code here...")
parser.add_argument("--my-arg", type=str, required=False, help="HALP...")
args = parser.parse_args()
my_arg = args.my_arg
