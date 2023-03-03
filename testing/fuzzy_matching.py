
import difflib

string1 = "apple"
string2 = "appel"

string1 = "dddda"
string2 = "appel"



matcher = difflib.SequenceMatcher(None, string1, string2)
ratio = matcher.ratio() * 100

print(ratio)
