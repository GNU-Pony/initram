#!/usr/bin/env python3
# -*- coding: utf-8 -*-
'''

USAGE:  find (root_directory) | ./cpiolist.py (root_directory) > (cpio_list)

'''
import sys
import os


def main(root):
    while True:
        try:
            location = input()
            name = location[len(root):]
            if (name == '/') or (name == ''):
                continue
            
            stat = os.stat(location, follow_symlinks=False)
            uid = stat.st_uid
            gid = stat.st_gid
            mode = stat.st_mode
            mod = oct(mode)[-4:]
            
            if os.path.islink(location):
                link = os.readlink(location)
                if link.startswith(root):
                    link = link[len(root):]
                if not link.startswith("/"):
                    link = "/" + link
                print("slink %s %s %s %i %i" % (name, link, mod, uid, gid))
            elif os.path.isdir(location):
                print("dir %s %s %i %i" % (name, mod, uid, gid))
            elif os.path.isfile(location):
                print("file %s %s %s %i %i" % (name, location, mod, uid, gid))
            else:
                t = oct(mode)[2:-4]
                if t == '1':
                    print("pipe %s %s %i %i" % (name, mod, uid, gid))
                elif t == '14':
                    print("sock %s %s %i %i" % (name, mod, uid, gid))
                else:
                    major = os.major(stat.st_rdev)
                    minor = os.minor(stat.st_rdev)
                    if t == '2':
                        print("nod %s %s %i %i c %i %i" % (name, mod, uid, gid, major, minor))
                    elif t == '6':
                        print("nod %s %s %i %i b %i %i" % (name, mod, uid, gid, major, minor))
        except EOFError:
            break


if __name__ == '__main__':
    root = sys.argv[1]
    main(root[:-1] if root.endswith('/') else root)

