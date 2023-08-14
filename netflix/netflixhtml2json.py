#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import print_function
from __future__ import unicode_literals

import sys
from bs4 import BeautifulSoup as BS
import re
import json

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

def refine_from_metadata(item_dict, item_metadata):
    year=''
    rating=''
    duration=''

    season=''
    disc=''

    for val in item_metadata:
        if (re.search('\d\d\d\d', val)):
            year = val
        if (re.search('[A-Z][A-Z1-9 -]+', val)):
            rating = val
        if (re.search('(\d+h )?\d+m', val)):
            duration = val

    if (not year and not duration and len(item_metadata) == 3):
        season = item_metadata[0]
        disc = item_metadata[2]

    if (year):
        item_dict["year"] = year
    if (rating):
        item_dict["rating"] = rating
    if (duration):
        item_dict["duration"] = duration
    if (season):
        item_dict["season"] = season
    if (disc):
        item_dict["disc"] = disc
    return item_dict

def trim(str):
    return re.sub('^\s+', '',
    re.sub('\s+$', '',
    re.sub('\s+', ' ',
    str)))

def get_page(filename, section):
    with open(filename, 'r') as content_file:
        content = content_file.read()
    soup = BS(content, features="html.parser")
    active_list = soup.find("div", {"id": section})
    if active_list:
        titles = []
        title_divs = active_list.findAll("div", {"class": "title"})
        for title_div in title_divs:

            item_metadata = []
            item_dict = {}

            for metadata_p in title_div.findAll("p", {"class": "metadata"}):
                for metadata_span in metadata_p.findAll("span"):
                    item_metadata.append(trim(metadata_span.text))

            for anchor in title_div.findAll("a"):
                if (anchor.has_key('href')
                        and anchor.text
                        and anchor['href'].startswith('https://dvd.netflix.com/Movie/')):
                    item_dict["title"] = trim(anchor.text)
                    item_dict = refine_from_metadata(item_dict, item_metadata)
                    item_dict["metadata"] = item_metadata
                    titles.append(item_dict)
                    # print(anchor.parent.parent.parent.parent.parent)

        return titles


def get_all(filename, section):
    titles = get_page(filename, section)
    if titles:
        print("Got {} titles".format(len(titles)), file=sys.stderr)
        return titles


def dump(titles):
    print(json.dumps(titles))
    # print(json.dumps({'title': title.text, 'url':title['href']}))
    print("Total of {} titles".format(len(titles)), file=sys.stderr)


def squash_whitespace(title):
    if title:
        return re.sub('\s+', ' ', title)


all_titles=get_all(filename, section)
if all_titles:
    titles = [title for title in all_titles]
    dump(titles)
