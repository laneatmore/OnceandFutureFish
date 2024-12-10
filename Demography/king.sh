#!/bin/bash

prefix=$1

king -b $prefix.bed --related 
king -b $prefix.bed --kinship
