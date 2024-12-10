#!/usr/bin/env python3

import os
import sys
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt
import seaborn as sns

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
pd.set_option('display.width', None)
pd.set_option('display.max_colwidth', None)

def grab_estimates(inds, het):
	print('Grabbing estimates', flush = True)
	for i,file in enumerate(os.listdir()):
		if file.endswith('folded.est.ml'):
			ind = os.path.splitext(file)[0]
			name = ind.replace('.folded.est','')
			print('Reading file for ' + name, flush = True)
			est = pd.read_csv(file, delim_whitespace = True, header = None, low_memory = False)
			est['theta'] = est[1]/(est[0] + est[1])
			est.to_csv(name + ".theta.folded.est.ml")
			avg = est['theta'].mean()
			print('Average estimated for ' + name, flush = True)
			inds.append(name)
			het.append(avg)


#First - - get estimate of theta
#then, re-plot this
#then, get another dataset with theta estimates per individual  that can be plotted across the genome (?)

#MERGE WITH POP INFO FOR PLOTTING!!!	

def plot_estimates(inds, het, pop_info_list):
	print('Plotting estimates', flush = True)
	estimates = list(zip(inds, het))
	estimates = pd.DataFrame(estimates, columns = ['Ind', 'het'])
	print('Reading pop info', flush = True)
	print(pop_info_list, flush = True)
	pop_info = pd.read_csv(pop_info_list, delim_whitespace = True, header = 0)
	print('Merging datasets', flush = True)
	full_estimates = estimates.merge(pop_info, on = 'Ind')
	full_estimates = full_estimates.sort_values('Sea')
	print('Outputting csv', flush = True)
	print(full_estimates.head(), flush = True)
	full_estimates.to_csv('Heterozygosity.folded.estimates.csv', sep = '\t', index = False)
	#fig,ax = plt.subplots()
	print('Plotting results', flush = True)
	#color_labels = full_estimates['Sea'].unique()
	#rgb_values = sns.color_palette("Set2")
	#print(color_labels, flush = True)
	#print(rgb_values, flush = True)
	#color_map = dict(zip(color_labels, rgb_values))
	ax = sns.scatterplot(x = 'Ind', y = 'het', data = full_estimates, hue = "Sea")
	ax.set_xticklabels(estimates['Ind'], rotation = 45)
	ax.set_title("Folded heterozygosity estimate (angsd)")	
	ax.set_xlabel('Sample')
	ax.set_ylabel('Average single-sample het')
	ax.legend(loc='lower right')
	print('Outputting plot', flush = True)
	ax.figure.savefig('Folded_het_est.pdf')
	

def main():
	pop_info_list = str(sys.argv[1])
	inds = []
	het = []
	
	grab_estimates(inds, het)
	plot_estimates(inds, het, pop_info_list)
	

if __name__ == '__main__':
	main()
