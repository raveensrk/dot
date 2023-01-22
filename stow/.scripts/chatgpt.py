#!/usr/bin/env python3

import subprocess
import os
import argparse
import sys
import json

def install(module):
    # Try to import the module
    try:
        __import__(module)
    except ImportError:
        # The module is not present, so install it using pip
        subprocess.run(["pip3", "install", module])

# Install the "requests" module if it is not present
install("requests")

# Now the requests module should be available for use
import requests

install("openai")
import openai

install("colorama")
import colorama
from colorama import Fore

# Initialize the colorama library
colorama.init()

# Create an ArgumentParser object
parser = argparse.ArgumentParser(
        prog = 'Mini ChatGPT',
        description = 'This is take input string as argument or as stdin and gets response from OpenAI text completion AI models. set your OPENAI_API_KEY with export OPENAI_API_KEY="xxxxxxxx"',
        epilog = 'Try to use less tokens as possible.'
        )

# Add an argument to the parser
parser.add_argument("string", nargs="*", help="Input string")
parser.add_argument("--test", default=0, type=int, help="If test is set to 1, it will enter testing mode and does not make any response", required=False)
parser.add_argument("--verbose", default=0, type=int, help="If test is set to 1, it will verbose", required=False)
parser.add_argument("--max_tokens", default=15, type=int, help="Maximum number of response tokens, default 15, increase if the response is incomplete or short and as required.", required=False)
parser.add_argument("--openai_api_key", default=None, help="OpenAI API Key, Get OPENAI_API_KEY at https://beta.openai.com/account/api-keys", required=False)

# Parse the command line arguments
args = parser.parse_args()
test = args.test
max_tokens = args.max_tokens
openai_api_key=args.openai_api_key
verbose=args.verbose

if openai_api_key is None:
    if os.getenv("OPENAI_API_KEY") is None:
        print(Fore.RED)
        print('OpenAI API Key environment variable is not set')
        print(Fore.RESET)
        sys.exit(2)
    else:
        openai.api_key = os.getenv("OPENAI_API_KEY")
else:
        openai.api_key = openai_api_key


if test == 1:
    print(Fore.YELLOW)
    print('IN TEST MODE...')
    print(Fore.RESET)
    print('OPENAI_API_KEY: ', openai_api_key)
    print('Maximum Tokens: ', max_tokens)

if verbose == 1:
    print(Fore.BLUE)
    print("You Entered:")
    print(Fore.RESET)

# Check if the optional argument was passed
if args.string:
    # Print the argument
    line = " ".join(args.string)
    # print(line)
else:
    # Read a line of input from stdin
    line = sys.stdin.readline()
    # Print the input
    # print(line)


prompt=line


def complete(line, test, max_tokens):
    if verbose == 1:
        print(Fore.GREEN)
        print("Resonse:")
        print(Fore.RESET)
    if test==1:
        with open("./example_chatgpt_output.json", "r") as f:
            line=f.read()
            data = json.loads(line)
            for item in data["choices"]:
                print(item['text'])
    else:
        response = openai.Completion.create(
                model="text-davinci-003",
                prompt=line,
                max_tokens=max_tokens,
                temperature=0
                )
        text = response['choices'][0]['text']
        print(text)


complete(prompt,test,max_tokens)
# print(result, 1)


