#!/usr/bin/env python3

import sys, os, os.path
import re


if len(sys.argv) < 2:
    print("Usage: dg [PP-xxxx]")
    exit(-1)

# print(sys.argv)

binpath = repr(os.path.dirname(os.path.realpath(sys.argv[0])))
# print("BINPATH: " + binpath)
sourcepath = f"{binpath}/../sources"

for i in range(1, len(sys.argv)):
    command = sys.argv[i]
    
    match = re.search(r"""^PP-(\d+)$""", command)
    if match and match.group(1):
        ppid = match.group(1)
        print("Command: Scrape from Little Prince Collection PP id " + ppid)
        os.system(f"{sourcepath}/pp/scrape {ppid}")

    elif command == 'covers':
        print("Command: Upload covers")
        os.system(f"{sourcepath}/covers/upload")


    else:
        print(f"""Unknown command: {command}
    Usage:
    dg PP-1234  # download metadata and cover image from Le Petit Prince Collection (Jean-Marc Probst)
    dg covers   # upload artifacts (covers) to S3 and save the URLs to a file
""")
