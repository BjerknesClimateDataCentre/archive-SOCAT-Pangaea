#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 28 09:40:47 2018

@author: rpr061
"""
import os


# Create 1 data file per basis for SOCATv6
# Split into New and Updated

# THIS IS WHAT BASH DOES / DID ?
## Working directory
#wd = ('/Users/rpr061/Documents/DATAMANAGEMENT/Pangaea/Archive_SOCATv6/'
#      'SOCATv6Only_SOCATBundles/')
#
## List of directories (aka basis)
#directory_list = list()
#for root, dirs, files in os.walk(wd, topdown=False):
#    for name in dirs:
#        directory_list.append(os.path.join(root, name))
##print (directory_list)
#
#root1, basis, files = next(os.walk(wd))
#
##del root, files
#
## Loop through basis and list files
##for base in basis():
#root2, events, files = next(os.walk(os.path.join(root1,basis))
##del root, files
#
##for event in events():
#for root, dirs, datafiles in (os.walk(wd + basis[0] + '/' + events[0] + '/')):
#    for datafile in datafiles:
#        if datafile.endswith(".tsv"):
#            print(os.path.join(root,datafile))

#

wd1 = ('/Users/rpr061/Documents/DATAMANAGEMENT/Pangaea/Archive_SOCATv6/'
  'Preparatory_docs/')
wd = ('/Users/rpr061/Documents/DATAMANAGEMENT/Pangaea/Archive_SOCATv6/'
  'SOCATv6Only_SOCATBundles/')

# Variables that contains New and Updated expocodes
NewDatasets = list()
with open(wd1 + 'ListNew.tsv') as f:
    for line in f:
        line = line.strip()
        NewDatasets.append(line)
    f.closed

UpdatedDatasets = list()
with open(wd1 + 'ListUpdated.tsv') as f:
    for line in f:
        line = line.strip()
        UpdatedDatasets.append(line)
    f.closed
    
# Create list of the lists of files per basis
listof_filelist = list()
for file in os.listdir(wd):
    if file.endswith(".txt"):
        listof_filelist.append(os.path.join(wd,file))
        
# Per basis, import list of files and manipulate
#for basislist in listof_filelist:
basislist = listof_filelist[0]

BasisFiles = list()
BasisHeaderLines = list()
with open(basislist) as f:
    for line in f:
        line = line.strip()
        columns = line.split()
        BasisFiles.append(columns[0])
        BasisHeaderLines.append(columns[1])
#        BasisFilesInfo = f.readlines()   
    f.closed

        
        