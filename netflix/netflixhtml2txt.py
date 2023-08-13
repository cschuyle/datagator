#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import print_function
from __future__ import unicode_literals

import sys

# reload(sys)
# sys.setdefaultencoding('utf-8')

from bs4 import BeautifulSoup as BS
import sys

import re

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

if len(sys.argv) < 3:
    eprint("Usage: "+ sys.argv[0] + " SECTION FILENAME.\n" \
          "\n" \
          "Known SECTIONs are athomeList, inqueueList, savedList\n")
    sys.exit(1)

section = sys.argv[1]
filename = sys.argv[2]


def quote(s):
    s.replace("'", "''")


def get_page(filename, section):
    with open(filename, 'r') as content_file:
        content = content_file.read()
    soup = BS(content)
    active_list = soup.find("div", {"id": section})
    titles = []
    title_divs = active_list.findAll("div", {"class": "title"})
    for title_div in title_divs:
        for anchor in title_div.findAll("a"):
            if (anchor.has_key('href')
                    and anchor.text
                    and anchor['href'].startswith('https://dvd.netflix.com/Movie/')):
                titles.append(anchor.text)
                # print(anchor.parent.parent.parent.parent.parent)

    return titles


def get_all(filename, section):
    titles = get_page(filename, section)
    print("Got {} titles".format(len(titles)), file=sys.stderr)
    return titles


def dump(titles):
    for title in sorted(titles):
        print(title)
        # print(json.dumps({'title': title.text, 'url':title['href']}))
    print("Total of {} titles".format(len(titles)), file=sys.stderr)


def squash_whitespace(title):
    return re.sub('\s+', ' ', title)


titles = [squash_whitespace(title) for title in get_all(filename, section)]
dump(titles)
