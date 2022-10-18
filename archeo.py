#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import plac
import os
import json
import bz2
from pathlib import Path
from typing import Dict, List, Tuple, Set


def build_reverse_index(manifest: List[Dict]) -> Dict[str, Tuple[str, str]]:
    d: Dict[str, Tuple[str, str]] = {}

    lib_to_files: Dict
    for lib_to_files in manifest:
        lib: str = lib_to_files["lib"]
        files: List[Dict] = lib_to_files["files"]

        file_attrs: Dict
        for file_attrs in files:
            fname: str = file_attrs["file"]
            sha1: str = file_attrs["sha1"]
            d[fname] = (lib, sha1)
    return d


def main(
    boost_folder : ("Directory with boost include headers.", 'option', 'd', str),
    version : ("Assumed boost version, e.g. 1.80.0.", 'option', 'v', str),
    ):

    if not boost_folder:
        print("[!] boost_folder parameter is mandatory.")
        return -1

    if not version:
        print("[!] boost version parameter is mandatory.")
        return -1

    if not os.path.exists(boost_folder):
        print(f"[!] boost include headers' directory {boost_folder} does not exist.")
        return -1

    this_dir: str = Path(globals().get("__file__", "./_")).absolute().parent
    manifest_dir: str = os.path.join(this_dir, "manifests")

    if not os.path.exists(manifest_dir):
        print(f"[!] manifest folder {manifest_dir} does not exist.")
        return -1

    manifest_fname: str = os.path.join(manifest_dir, f"manifest-{version}.json.bz2")
    if not os.path.exists(manifest_fname):
        print(f"[!] manifest file {manifest_fname} does not exist.")
        return -1

    with bz2.open(manifest_fname, "rt") as ifile:
        manifest: List = json.loads(ifile.read())

    rev_index: Dict[str, Tuple[str, str]] = build_reverse_index(manifest)

    unknowns: List = []
    libs: Set = set()

    for path, subdirs, files in os.walk(boost_folder):
        rel_path: str = os.path.relpath(path, boost_folder)
        if rel_path == '.':
            rel_path = ''
        for fname in files:
            path: str = os.path.join(rel_path, fname)
            if path in rev_index:
                lib: str
                sha1: str
                lib, sha1 = rev_index[path]
                libs.add(lib)
            else:
                unknowns.append(path)
            pass
        pass

    if len(libs) == 0:
        print("[i] No boost libraries were identified.")
    else:
        print("[i] Identified official boost libraries:")
        for lib in sorted(list(libs)):
            print(lib)

    if len(unknowns) != 0:
        print("[i] Files without associated official boost libraries:")
        for fname in unknowns:
            print(fname)

    return 0

if __name__ == '__main__':
    sys.exit(plac.call(main))
