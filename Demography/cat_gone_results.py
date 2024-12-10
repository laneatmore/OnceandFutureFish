#!/usr/bin/python3

import pandas as pd
import csv
import sys
import os
import fileinput
import matplotlib
import matplotlib.pyplot as plt
#import swifter
#import statsmodels.stats.api as sms

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
pd.set_option('display.width', None)
pd.set_option('display.max_colwidth', None)

#create empty dataframe to fill
Estimates = pd.DataFrame()

def grab_Ne_estimates():
	os.chdir('results/')
	global Estimates
	#start counter
	i=0
	#iterate over all Ne estimate files
	
	for f in os.listdir():
		if f.startswith('Output_Ne'):
			file=open(f,'r')
			#cut off unnecessary headers
			lines_after_2=file.readlines()[2:]
			ne = []
			#append Ne estimates to list
			for x in lines_after_2:
				ne.append(x.split('\t')[1].rstrip('\n'))
			file.close()
			#update counter
			i=i+1
			#append Ne estimate list as column in Estimates DF as float 
			Estimates['ne' + '.'+ str(i)] = pd.Series(ne).astype('float64')
	
	#get rid of generations that were not estimated across all runs
	Estimates = Estimates.dropna()
	median = Estimates.median(axis = 1)
	Estimates['median'] = median
	Estimates['gen'] = Estimates.index + 1
	#return df outside of function
	return Estimates 

#Estimates_final = pd.DataFrame()

#def medianCI():
	#grab Estimates df
#	global Estimates
	
	#calculate confidence interval
	#Estimates['CI'] = Estimates.swifter.apply(lambda x: sms.DescrStatsW(x).tconfint_mean(), axis=1)
	#calculate median value
#	Estimates['median'] = Estimates.median(axis=1)
	#Split CI tuple
	#Estimates[['lowCI','highCI']] = pd.DataFrame(Estimates['CI'].tolist(),index=Estimates.index)
	#add generation column
#	Estimates['gen'] = Estimates.index + 1
	#remove unnecessary columns
	#Estimates_final = Estimates[['gen','median','lowCI','highCI']]
	
#	return Estimates_final

def main():
	#parse args
	prefix = sys.argv[1]
	#gen_time = int(sys.argv[2])
	#run functions to get estimates df
	grab_Ne_estimates()
	#medianCI()
	#grab global dataframe
	global Estimates
	#reorder for printing
	Estimates.insert(0, 'gen', Estimates.pop('gen'))
	Estimates.insert(1, 'median', Estimates.pop('median'))
	Estimates.to_csv(prefix + '_aggregated.txt', sep='\t', index = False)
	
	#plot example NEs
	fig = plt.figure(figsize=(10,8))
	ax = plt.gca()
	
	for col in Estimates.columns[2:]:
		ax.plot(Estimates['gen'], Estimates[col], color = '#929591', alpha = 0.3)

	ax.plot(Estimates['gen'], Estimates['median'], color = 'red')
	ax.set_title('')
	ax.set_xlabel('Generations in the Past')
	ax.set_ylabel('Ne Estimation')
	ax.figure.savefig(prefix + '_Ne_estimates.pdf')

if __name__ == '__main__':
	main()
