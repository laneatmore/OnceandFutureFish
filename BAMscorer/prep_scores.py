#!/usr/bin/env python

#this script will take the output files from WRAPbams_iter.sh and put them in a format
#that can be used in R to assess confidence in scoring

#Check individual lists, read lists, and cut-offs to make sure it fits with your data
#you will also have to change the file output names!

import pandas as pd
import csv
import re
import os
from pathlib import Path
import fileinput
import subprocess

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
pd.set_option('display.width', None)
pd.set_option('display.max_colwidth', None)

def add_column():
	 #first list the individuals in the folder
	inds = ['M-HER066', 'M-HER037', 'M-HER016', 'M-HER001', 'HER_NorthSea34', 'M-HER054','HER_AK1_Downs','HER_Gavle98']
        #what were the various downsampled read lengths?
	reads = ['00500','01000','01500','02000','02500','03000','03500','04000','04500','05000','05500','06000','06500',
	'07000','07500','08000','08500','09000','09500','10000','20000','30000','40000','50000','60000','70000','80000','90000','99999']

        #cut-offs tested
	#cut_offs = ['1','1_top','1_bottom','5', '5_top', '5_bottom', '10', '10_top', '10_bottom','20', '20_top','20_bottom','25','25_top','25_bottom','50']

	cut_offs = ['ALL']

	for i in inds:
		for c in cut_offs:
			if os.path.exists(str(i) + '_' + str(c) + '_scores.txt'):
				file = pd.read_csv(str(i) + '_' + str(c) + '_scores.txt', sep = '\t', header = 0)
				print(file.head(), flush = True)
				if not 'Prob AB' in file:
					file.insert(3, 'Prob AB', '0')
				print(file.head(), flush = True)
				file.to_csv(str(i) + '_' + str(c) + '_scores_AB_added.txt', sep = '\t', header = True, index = False)
				os.system('mv ' + str(i) + '_' + str(c) + '_scores_AB_added.txt ' + str(i) + '_' + str(c) + '_scores.txt') 
			else:
				continue

def separate_scores_by_read():
	#first list the individuals in the folder
	inds = ['M-HER066', 'M-HER037', 'M-HER016', 'M-HER001', 'HER_NorthSea34', 'M-HER054','HER_AK1_Downs','HER_Gavle98']
	#what were the various downsampled read lengths?
	reads = ['00500','01000','01500','02000','02500','03000','03500','04000','04500','05000','05500','06000','06500',
	'07000','07500','08000','08500','09000','09500','10000','20000','30000','40000','50000','60000','70000','80000','90000','99999']

	#cut-offs tested 
	#cut_offs = ['1','1_top','1_bottom','5', '5_top', '5_bottom', '10', '10_top', '10_bottom','20', '20_top','20_bottom','25',
	#'25_top','25_bottom','50']
	
	#cut_offs = ['1','5','10']

	cut_offs = ['ALL']

	#for each individual
	for i in inds:
		#go by each cut-off file
		for c in cut_offs:
			with open(str(i) + '_' + str(c) + '_scores.txt', 'rt') as f:
				lines = f.readlines()
				#for each read depth sampled in the file
				for j in reads:
					results = []
					pattern1 = re.compile(str(j), re.IGNORECASE)
							#pull the 20 bootstrapped files that were sampled at that read depth
					for line in lines:
						if pattern1.search(line) != None:
							results.append(line)
							#convert the list back to a df
							results_df = pd.DataFrame(results)
							results_df[0] = results_df[0].map(lambda x: x.rstrip('\n'))
							results_df[1] = j
							results_df[2] = c
						
							results_df = results_df.replace({'"':''}, regex = True)
							#print out each read depth to a new file
							results_df.to_csv('no_head_' + str(i) + '_' + str(c) + '_' + str(j) + '_scores.txt', sep = '\t', index = False, header = False)
	print('scores separated', flush = True)

def compile_AA_BB_scores():
	BB_ind = ['HER_Gavle98', 'M-HER016', 'M-HER054']
	AA_ind = ['HER_NorthSea34','HER_AK1_Downs', 'M-HER066', 'M-HER037', 'M-HER001']

	#cut_offs = ['1','1_top','1_bottom','5', '5_top', '5_bottom', '10', '10_top', '10_bottom','20', '20_top','20_bottom','25',
	#'25_top','25_bottom','50']

	#cut_offs = ['1','5','10']


	cut_offs = ['ALL']

	reads = ['00500','01000','01500','02000','02500','03000','03500','04000','04500','05000','05500','06000','06500',
	'07000','07500','08000','08500','09000','09500','10000','20000','30000','40000','50000','60000','70000','80000','90000','99999']


	for i in AA_ind:
		for c in cut_offs:
			AA_scores = []
			for j in reads:
				if os.path.exists('no_head_' + str(i) + '_' + str(c) + '_' + str(j) + '_scores.txt'):
					with open('no_head_' + str(i) + '_' + str(c) + '_' + str(j) + '_scores.txt', 'rt') as f:
						lines = f.readlines()
						pattern2 = re.compile(str(c), re.IGNORECASE)
						for line in lines:
							if pattern2.search(line) != None:
								AA_scores.append(line)
	
			AA_scores_df = pd.DataFrame(AA_scores)
			if not AA_scores_df.empty:
				AA_scores_df[0] = AA_scores_df[0].map(lambda x: x.rstrip('\n'))	
				AA_scores_df = AA_scores_df.replace({'"':''}, regex = True)
				AA_scores_df[1] = 'AA'
				AA_scores_df.to_csv('scores_spawning_' + str(i) + '_' + str(c) + '_AA.tmp.txt', index = False, header = False)
				AA_scores_only = pd.read_csv('scores_spawning_' + str(i) + '_' + str(c) + '_AA.tmp.txt', sep = '\t|,',  header = None, usecols = [0,1,4,5,6,7])
				AA_scores_only.to_csv('scores_spawning_' + str(i) + '_' + str(c) + '_AA.tmp2.txt', sep = '\t', index = False, header = False)

	for c in cut_offs:	
		files = []
		for f in os.listdir():
			if f.endswith('_' + str(c) + '_AA.tmp2.txt'):
				files.append(f)
		
		with open('scores_spawning_' + str(c) + '_AA.txt', 'w') as outfile:
			for fname in files:
				with open(fname) as infile:
					outfile.write(infile.read())
					
	print('AA compiled', flush = True)
	
	for i in BB_ind:
		for c in cut_offs:
			
			BB_scores = []
			for j in reads:
				if os.path.exists('no_head_' + str(i) + '_' + str(c) + '_' + str(j) + '_scores.txt'):
					with open('no_head_' + str(i) + '_' + str(c) + '_' + str(j) + '_scores.txt', 'rt') as f:
						lines = f.readlines()
						pattern3 = re.compile(str(c), re.IGNORECASE)
						for line in lines:
							if pattern3.search(line) != None:
								BB_scores.append(line)
	
			BB_scores_df = pd.DataFrame(BB_scores)
			if not BB_scores_df.empty:	
				BB_scores_df[0] = BB_scores_df[0].map(lambda x: x.rstrip('\n'))	
				BB_scores_df = BB_scores_df.replace({'"':''}, regex = True)
				BB_scores_df[1] = 'BB'
				BB_scores_df.to_csv('scores_spawning_' + str(i) + '_' + str(c) + '_BB.tmp.txt', index = False, header = False)
				BB_scores_only = pd.read_csv('scores_spawning_' + str(i) + '_' + str(c) + '_BB.tmp.txt',  sep = '\t|,', header = None, usecols = [0,2,4,5,6,7])
				BB_scores_only.to_csv('scores_spawning_' + str(i) + '_' + str(c) + '_BB.tmp2.txt', sep = '\t', index = False, header = False)
			else:
				continue

	for c in cut_offs:	
		files = []
		for f in os.listdir():
			if f.endswith('_' + str(c) + '_BB.tmp2.txt'):
				files.append(f)
		
		
		with open('scores_spawning_' + str(c) + '_BB.txt', 'w') as outfile:
			for fname in files:
				with open(fname) as infile:
					outfile.write(infile.read())
					
	print('BB compiled', flush = True)
	
	#for i in AB_ind:
	#	for c in cut_offs:
	#		if os.path.exists('no_head_' + str(i) + '_M-HER_15_high_FST_' + str(c) + '*_scores.txt'):
	#			AB_scores = []
	#			for j in reads:
	#				with open('no_head_' + str(i) + '_M-HER_15_no_outliers_ind_removed_' + str(c) + '_' + str(j) + '_scores.txt', 'rt') as f:
	#					lines = f.readlines()
	#					pattern3 = re.compile(str(c), re.IGNORECASE)
	#					for line in lines:
	#						if pattern3.search(line) != None:
	#							AB_scores.append(line)
	#
	#			AB_scores_df = pd.DataFrame(AB_scores)
	#			AB_scores_df[0] = AB_scores_df[0].map(lambda x: x.rstrip('\n'))	
	#			AB_scores_df = AB_scores_df.replace({'"':''}, regex = True)
	#			AB_scores_df[1] = 'AB'
	#			AB_scores_df.to_csv('scores_chr15_pc2_ocean_' + str(i) + '_' + str(c) + '_AB.tmp.txt', index = False, header = False)
	#			AB_scores_only = pd.read_csv('scores_chr15_pc2_ocean_' + str(i) + '_' + str(c) + '_AB.tmp.txt',  sep = '\t|,', header = None, usecols = [0,3,4,5,6,7])
	#			AB_scores_only.to_csv('scores_chr15_pc2_ocean_' + str(i) + '_' + str(c) + '_AB.tmp2.txt', sep = '\t', index = False, header = False)
	#		else:
	#			continue

	#for c in cut_offs:	
	#	files = []
	#	for f in os.listdir():
	#		if f.endswith('_' + str(c) + '_AB.tmp2.txt'):
	#			files.append(f)
	#	if f:
	#		with open('scores_chr15_pc2_ocean_' + str(c) + '_AB.txt', 'w') as outfile:
	#			for fname in files:
	#				with open(fname) as infile:
	#					outfile.write(infile.read())
	#				
	#print('AB compiled', flush = True)

def remove_low_reads():
	pattern4 = 'Too few reads'
	#cut_offs = ['1','1_top','1_bottom','5', '5_top', '5_bottom', '10', '10_top', '10_bottom','20', '20_top','20_bottom','25',
	#'25_top','25_bottom','50']
	
	#cut_offs = ['1','5','10']


	cut_offs = ['ALL']

	for c in cut_offs:
		for f in os.listdir():
			if f.endswith('_' + str(c) + '_AA.txt'):
				with open(f,"r+") as f:
   					new_f = f.readlines()
   					f.seek(0)
   					for line in new_f:
   						if pattern4 not in line:
   							f.write(line)
   							f.truncate()
			elif f.endswith('_' + str(c) + '_BB.txt'):
				with open(f,"r+") as f:
   					new_f = f.readlines()
   					f.seek(0)
   					for line in new_f:
   						if pattern4 not in line:
   							f.write(line)
   							f.truncate()
			elif f.endswith('_' + str(c) + '_AB.txt'):
				with open(f,"r+") as f:
					new_f = f.readlines()
					f.seek(0)
					for line in new_f:
						if pattern4 not in line:
							f.write(line)
							f.truncate()

		os.system('cat scores_spawning_' + str(c) + '_AA.txt scores_spawning_' + str(c) + '_BB.txt >> scores_spawning_' + str(c) + '.txt')
	print('too few reads removed', flush = True)
					
	print('haplotypes compiled', flush = True)
	
	

def clean_up():
	for f in os.listdir():
		if f.startswith('no_head_'):
			os.remove(f)
		elif f.endswith('.tmp.txt'):
			os.remove(f)
		elif f.endswith('.tmp2.txt'):
			os.remove(f)
		else:
			pass

	
	reads = ['00500','01000','01500','02000','02500','03000','03500','04000','04500','05000','05500','06000','06500',
	'07000','07500','08000','08500','09000','09500','10000','20000','30000','40000','50000','60000','70000','80000','90000','99999']

	for j in reads:
		for f in os.listdir():
			if f.endswith(str(j) + '_scores.txt'):
				os.remove(f)

	print('files removed', flush = True)

def main():
	add_column()
	separate_scores_by_read()
	compile_AA_BB_scores()
	remove_low_reads()
	clean_up()

if __name__ == '__main__':
	main()
	

