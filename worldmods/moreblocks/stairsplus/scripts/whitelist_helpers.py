import argparse
import json
import multiprocessing
import pathlib
import queue
import time


def existing_file(path: str) -> pathlib.Path:
    file_path = pathlib.Path(path)
    if not file_path.exists():
        raise argparse.ArgumentTypeError(f'{path!r} does not exist.')
    if not file_path.is_file():
        raise argparse.ArgumentTypeError(f'{path!r} is not a file.')
    return file_path


def get_cursor(args):
    if args.pg_connection:
        import psycopg2
        conn = psycopg2.connect(args.pg_connection)
        cursor = conn.cursor(name='blocks')
        cursor.itersize = args.chunk_size

    else:
        import sqlite3
        conn = sqlite3.connect(args.sqlite_file)
        cursor = conn.cursor()

    return cursor


def create_filter(stairsplus_dump: pathlib.Path):
    print('creating filter from dump...')
    start = time.time()
    f = {}
    with stairsplus_dump.open() as fh:
        data = json.load(fh)

    for shaped_node in data['shaped_nodes'].keys():
        f[shaped_node.encode()] = shaped_node.encode()

    for alias, shaped_node in data['aliases'].items():
        f[alias.encode()] = shaped_node.encode()
    print(f'created in {time.time() - start}')

    return f


def count_blocks(args):
    cursor = get_cursor(args)

    # just shy of 12 minutes for postgres w/ a 150GiB map dump, an opteron 6376, and 4 encrypted raid6 5400 RPM disks
    print('counting mapblocks - this can take a while...')
    start = time.time()
    cursor.execute('SELECT COUNT(data) FROM blocks')
    num_blocks = cursor.fetchone()[0]
    elapsed = time.time() - start
    print(f'num_blocks: {num_blocks} (fetched in {elapsed}s)')
    return num_blocks, elapsed


def create_whitelist(filter_, all_nodes):
    print('creating whitelist')
    return set(
        shaped_node for shaped_node in map(filter_.get, all_nodes) if shaped_node
    )


def write_whitelist(args, whitelist):
    if args.output:
        output = args.output
    else:
        output = args.stairsplus_dump.parent / 'stairsplus.whitelist'

    with output.open('wb') as fh:
        print(f'writing whitelist to {output!r}')
        fh.write(b'\n'.join(sorted(whitelist)))


def get_all_nodes(results: multiprocessing.Queue):
    all_nodes = set()
    try:
        while True:
            all_nodes.update(results.get(False))
    except queue.Empty:
        return all_nodes
