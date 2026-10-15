import argparse
import math
import multiprocessing
import pathlib
import time

import progressbar

import pymtdb
from whitelist_helpers import create_whitelist, write_whitelist, create_filter, count_blocks, existing_file, get_cursor, \
    get_all_nodes


def process_chunk(args, offset, limit, completed, results):
    cursor = get_cursor(args)
    cursor.execute(f'SELECT data FROM blocks LIMIT {limit} OFFSET {offset}')
    node_names = set()
    i = 0
    for i, row in enumerate(cursor, 1):
        node_names.update(pymtdb.MapBlockSimple.import_from_serialized(row[0]).node_names)
        if i % args.chunk_size == 0:
            completed.value = i
    completed.value = i
    results.put(node_names, False)


def main(args):
    num_blocks, count_blocks_elapsed = count_blocks(args)  # 345104538, 13*60
    work_size = math.ceil(num_blocks / args.workers)
    offsets = range(0, num_blocks, work_size)
    completeds = tuple(multiprocessing.Value('Q', 0, lock=False) for _ in range(args.workers))
    # because we want to terminate the processes before we remove the results from the queue, use a manager
    # see warnings in https://docs.python.org/3/library/multiprocessing.html#pipes-and-queues
    results = multiprocessing.Manager().Queue()
    processes = tuple(
        multiprocessing.Process(target=process_chunk, name=f'processor {i}',
                                args=(args, offsets[i], work_size, completeds[i], results))
        for i in range(args.workers)
    )
    for process in processes:
        process.start()

    print(f'NOTICE: not all jobs will start at the same time due to the nature of ranged queries. actual runtime will '
          f'be closer to 1/{min(args.workers, multiprocessing.cpu_count())}th the early estimate, plus '
          f'{count_blocks_elapsed}s.')
    # TODO: if we know how long it takes to count the blocks, and how many workers there are, we can estimate how long
    #       before a process starts producing results, and resize the jobs to maximize processor usage.
    #       proper estimation requires differential equations, ugh.

    with progressbar.ProgressBar(max_value=num_blocks) as bar:
        while True:
            time.sleep(1)
            total_completed = sum(completed.value for completed in completeds)
            bar.update(total_completed)
            if total_completed == num_blocks:
                break

    print('joining...')
    for process in processes:
        process.join()

    print('compiling results...')
    all_nodes = get_all_nodes(results)

    filter_ = create_filter(args.stairsplus_dump)
    whitelist = create_whitelist(filter_, all_nodes)
    write_whitelist(args, whitelist)


def parse_args(args=None, namespace=None):
    p = argparse.ArgumentParser()
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument('--pg_connection', '-c')
    g.add_argument('--sqlite_file', '-s', type=existing_file)
    p.add_argument('--chunk_size', type=int, default=64)
    p.add_argument('--workers', type=int, default=multiprocessing.cpu_count())
    p.add_argument('--output', '-o', type=pathlib.Path)
    p.add_argument('stairsplus_dump', type=existing_file)
    return p.parse_args(args=args, namespace=namespace)


if __name__ == "__main__":
    main(parse_args())
