#!/usr/bin/env python3

import sys, os, os.path
import re
import subprocess


def exit_usage(command):
    if(command and command.lower() != "help"):
        print(f"Unknown command: {command}")
    
    print("""Usage:
    dg PP-1234                          # download metadata and cover image from Le Petit Prince Collection (Jean-Marc Probst) with ID 1234
    dg covers DIRECTORY OF IMAGES       # upload artifacts (covers) to S3, save the metadata to a file
    dg pdfs DIRECTORY OF DIRECTORIES    # upload PDF file(s) (and optionally a cover image), output metadata to a file
""", file=sys.stderr)
    sys.exit(-1)


if len(sys.argv) < 2:
    exit_usage(None)

binpath = repr(os.path.dirname(os.path.realpath(sys.argv[0])))
binpath = binpath.strip('"\'')
sourcepath = f"{binpath}/../sources"

# print("SOURCEPATH " + sourcepath)

for i in range(1, len(sys.argv)):
    command = sys.argv[i]
    
    match = re.search(r"""^PP-(\d+)$""", command)
    if match and match.group(1):
        ppid = match.group(1)
        print("Command: Scrape from Little Prince Collection PP id " + ppid, file=sys.stderr)
        process = subprocess.run([f"{sourcepath}/pp/scrape", ppid])
        sys.exit(process.returncode)

    elif command == 'covers':
        print("Command: Upload covers", file=sys.stderr)
        process = subprocess.run(f"{sourcepath}/covers/upload")
        sys.exit(process.returncode)

    elif command == 'pdfs':
        print("Command: Upload PDFs", file=sys.stderr)
        command = [f"{sourcepath}/pdfs/pdfs.py", *sys.argv[2::len(sys.argv)]]
        # print("COMMAND: ", command)
        process = subprocess.run(command)
        sys.exit(process.returncode)

    else:
        exit_usage(sys.argv[1])
