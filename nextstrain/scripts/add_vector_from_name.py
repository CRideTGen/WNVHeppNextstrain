# import os
#
# os.chdir("/home/chase/DissertationProjects/nextstrain/WNV_Nextstrain_Analysis/")
#
# with open("nextstrain/data/metadata.tsv", "r") as meta_file:
#
#     while line := meta_file.readline():
#         print(line)
#
import seaborn as sns

x = sns.color_palette("hls", 10)
y = sns.color_palette("terrain_r", 10)
print(x.as_hex())
print(y.as_hex())
#db5f57
#dbae57
#b9db57
#69db57
#57db94
#57d3db
#5784db
#7957db
#c957db
#db579e
#d1c4c1
#a38984
#8a695a
#baa774
#e8e28d
#d1f690
#75e37d
#15d06a
#00a8d0
#1470d6