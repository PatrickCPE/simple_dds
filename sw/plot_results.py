#!/bin/usr/python3

import re
import glob
import os
from matplotlib import pyplot as plt

values = []
list_of_files = glob.glob('/home/patrick/ws/school/verilog_and_vhdl/simple_dds/sim/rtl_sim/log/simple_dds*') # * means all if need specific format then *.csv
latest_file = max(list_of_files, key=os.path.getctime)
print("Graphing " + latest_file)


regex = re.compile("value:.*")
with open(latest_file) as f:
    for line in f:
        result = regex.search(line);
        if result is not None:
            print(result.group(0))
            print(result.group(0)[6:].lstrip())
            values.append(int(result.group(0)[6:].lstrip()))


plt.plot(values)
plt.xlabel("Sample")
plt.ylabel("Value")
plt.title("Simple DDS Output")
plt.savefig("plot.png")
plt.show()

