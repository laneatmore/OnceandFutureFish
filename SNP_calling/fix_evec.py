#!/usr/bin/python3

import pandas as pd
import sys

prefix = sys.argv[1]

evec = pd.read_csv(prefix + '.pca.evec', delim_whitespace = True, names = ['ind','pc1','pc2'])
print(evec.head())

evec['sep_ind'] = evec['ind'].str.split(':').map(lambda x: x[0])
print(evec.head())
print(evec.keys)

evec[['sep_ind','pc1','pc2']].to_csv(prefix + '_fixed.pca.evec', sep = '\t', header = None, index = None)
print(evec.head())
