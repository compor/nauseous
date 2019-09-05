#!/usr/bin/env python
"""

"""

from __future__ import print_function

import sys
import os
import json
import intervals

from argparse import ArgumentParser
from collections import defaultdict

#

if __name__ == '__main__':
    parser = ArgumentParser(
        description='Manipulate Polly JSCoP location field')
    parser.add_argument(
        '-f',
        '--files',
        dest='jsonfiles',
        nargs='*',
        required=True,
        help='input JSON files')
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        '-s', '--split', action='store_true', help='split location fields')
    group.add_argument(
        '-i',
        '--intervals',
        action='store_true',
        help='join location line intervals')

    args = parser.parse_args()

    #

    d = defaultdict(list)

    for f in args.jsonfiles:
        with open(f, "rb") as infile:
            j = json.load(infile)
            loc = j['location']

            if args.split or args.intervals:
                filename, lines = loc.split(':')
                ls, le = lines.split('-')

                if args.intervals:
                    d[filename].append(intervals.closed(int(ls), int(le)))
                else:
                    print('{} {} {}'.format(filename, ls, le))
            else:
                print(loc)

    if args.intervals:
        for f, ivs in d.items():
            uiv = intervals.empty()
            for iv in ivs:
                uiv = uiv | iv
            print('{} {}'.format(f, intervals.to_string(uiv, disj=',')))

    sys.exit(0)
