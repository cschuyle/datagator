#!/usr/bin/env python3

import sys, os, os.path
import re
import subprocess


def exit_usage(command):
    exitcode = -1
    if(command):
        if(command.lower() == "help"):
            exitcode = 0
        else:
            print(f"Unknown command: {command}")
    
    print("""Usage:
    dg PP-1234 ...                      # Download metadata and cover image from Le Petit Prince Collection (Jean-Marc Probst) with ID 1234
    dg covers [DIRECTORY OF IMAGES]     # Upload artifacts (covers) to S3, save the metadata to a file
    dg pdfs [DIRECTORY OF DIRECTORIES]  # Upload PDF file(s) (and optionally a cover image), output metadata to a file
    dg tintenfass                       # Get Little Prince titles from Verlag Editorial Tintenfaß
""", file=sys.stderr)
    sys.exit(exitcode)


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
        print("Command: Get metadata from Little Prince Foundation (of Jean-Marc Probst), for PP id " + ppid, file=sys.stderr)
        process = subprocess.run([f"{sourcepath}/pp/scrape.sh", ppid])

    elif command == 'PP':
        print("Command: PP (download any Little Prince Foundation data by examining filenames for PP-*)", file=sys.stderr)
        command = f"{sourcepath}/pp/scrape-from-filenames.sh", *sys.argv[2::len(sys.argv)]
        process = subprocess.run(command)
        sys.exit(process.returncode)

    elif command == 'covers':
        print("Command: Upload covers", file=sys.stderr)
        command = f"{sourcepath}/covers/upload.sh", *sys.argv[2::len(sys.argv)]
        process = subprocess.run(command)
        sys.exit(process.returncode)

    elif command == 'pdfs':
        print("Command: Upload PDFs", file=sys.stderr)
        command = [f"{sourcepath}/pdfs/pdfs.py", *sys.argv[2::len(sys.argv)]]
        # print("COMMAND: ", command)
        process = subprocess.run(command)
        sys.exit(process.returncode)

    elif command == 'tintenfass':
        print("Command: Get Little Prince titles from Verlag Editorial Tintenfaß", file=sys.stderr)
        command = [f"{sourcepath}/tintenfass/get-little-prince-list.sh"]
        # print("COMMAND: ", command)
        process = subprocess.run(command)
        sys.exit(process.returncode)

    else:
        exit_usage(sys.argv[1])
