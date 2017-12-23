#!/usr/bin/python3
from sys import argv as arguments
import os

def createFileWithIgnored(ignoredList, mode):
    try:
        gitignoreFile = open(".gitignore", mode)
        for item in ignoredList:
            gitignoreFile.write(item + "\n")
        gitignoreFile.close()
    except:
        print("Failed to create .gitignore")


ignore = {
        "git": ['.git'],
        "laravel": ['vendor','.env'],
        "npm": ['node_modules','cache'],
        "vscode": ['.vscode'],
        "jetbrains": ['.idea']
}

for argument in arguments:
    if argument in ignore:
        createFileWithIgnored(ignore.get(argument, gitignoreExist))

