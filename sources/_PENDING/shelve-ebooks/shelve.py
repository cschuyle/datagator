# Shelve files (e-books) - basically a move to a destination implied by the file names, followed by a cleanup
# Usage: shelve [files] [-d destination]

import os
import sys
import re
import subprocess

mydata_root = os.environ["DRAGNON_MYDATA_ROOT"]
destination_root = f"{mydata_root}/Dropbox/curated/Books"

def canonical(s):
    return re.sub(r"\W+", '', s).lower()

def run_command(command):
    p = subprocess.Popen(command,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT)
    return iter(p.stdout.readline, b'')

def get_filenames(dir):
    task = subprocess.Popen(f"\\ls '{dir}'", shell=True, stdout=subprocess.PIPE)
    data = task.stdout.read()
    assert task.wait() == 0
    filenames = [filename for filename in data.decode().split('\n')]


def match_dir(destination_root, file):

    #--- First see if there are files that look identical except for "_v2" in them
    
    # TODO Left off here
    dir_files = {dirname: files_in(dirname) for dirname}

    filenames = get_filenames(destination_root)
    file_cans = {file_key: canonical(file_key) for file_key in filenames}
    # Find all files in all directories
    # remove _v2 substring
    # find the directory name that contains that file
    # If it's unique, return it



    file = file.rsplit( ".", 1 )[ 0 ]
    file = canonical(file)
    # file = re.sub(r'\.[^\.]+$]', '', file)
    # print(f"CANONICAL FILE   {file}")

    #--- Second, try to find the directory name corresponding to the file
    # Just a simple substring match, after canonicalizing the filenames and directory name

    filenames = get_filenames(destination_root)
    file_cans = {file_key: canonical(file_key) for file_key in filenames}
    # files = map(canonical, data.decode().split('\n'))
    # print(f"FILES CANONICAL MAP {file_cans}")
    
    matches = [ filename for filename, file_can in file_cans.items() if re.search(file, file_can) ]
    if len(matches) == 1:
        return matches[0]
    print(f"""No unique match. Here are the possibilities:
          {'\n'.join(matches)}
    """)


    return None

def move(file, dest_dir):
    os.rename(file, f"{dest_dir}")
    
for file in sys.argv[1:]:
    dest_dir = match_dir(destination_root, file)
    # print(f"DEST DIR {dest_dir}")
    if dest_dir:
        print(file, f"Move {file} to {destination_root}/{dest_dir}")
             
