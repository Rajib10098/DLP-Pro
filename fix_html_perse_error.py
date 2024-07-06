import re
import sys

input_value = None


if len(sys.argv) > 1:
    input_value = sys.argv[1]



# print(input_value)

   
# REMOVE: "*:<>?|\/


and_symbol = re.sub(r'&amp;', '&', input_value)




print(and_symbol)  # Output: Hi, world! Hi, everyone!
