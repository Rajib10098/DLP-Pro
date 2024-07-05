import re
import sys

input_value = None


if len(sys.argv) > 1:
    input_value = sys.argv[1]



# print(input_value)

   
# REMOVE: "*:<>?|\/

Backslash = re.sub(r"\\", '⧹', input_value)
slash = re.sub(r"\/", '⧸', Backslash)
asterisk = re.sub(r"\*", '✷', slash)
quotation = re.sub(r'"', '“', asterisk)
colon = re.sub(r':', 'ː', quotation)
verticle_bar = re.sub(r'\|', '🭲', colon)
less_then = re.sub(r'<', '＜', verticle_bar)
greater_then = re.sub(r'>', '＞', less_then)
question_mark = re.sub(r'\?', '？', greater_then)




print(question_mark)  # Output: Hi, world! Hi, everyone!
