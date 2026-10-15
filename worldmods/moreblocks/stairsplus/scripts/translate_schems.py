# https://gitlab.com/bztsrc/mtsedit/blob/master/docs/mts_format.md

import argparse
import json
import pathlib

import lupa

from stream import StreamReader, StreamWriter

lua = lupa.LuaRuntime(unpack_returned_tuples=True)


def is_schem(file: pathlib.Path):
    return file.suffix == '.mts'


def convert_schem(child, alias_map):
    print(f'processing {child}')
    with child.open('rb') as fh:
        contents = fh.read()

    reader = StreamReader(contents)
    magic = reader.bytes(4)
    if magic != b'MTSM':
        raise RuntimeError(f'invalid magic number {magic}')
    version = reader.u16()
    if version != 4:
        raise RuntimeError(f'unexpected version {version}')
    x = reader.u16()
    y = reader.u16()
    z = reader.u16()
    layer_probability_values = reader.bytes(y)
    name_id_length = reader.u16()
    names = []
    any_changed = False
    for _ in range(name_id_length):
        name = reader.bytes(reader.u16())
        alias = alias_map.get(name.decode())
        if alias:
            any_changed = True
            names.append(alias.encode())
        else:
            names.append(name)

    if any_changed:
        print('writing changes...')
        rest = reader.rest()
        with child.open('wb') as fh:
            writer = StreamWriter(fh)
            writer.bytes(b'MTSM')
            writer.u16(4)
            writer.u16(x)
            writer.u16(y)
            writer.u16(z)
            writer.bytes(layer_probability_values)
            writer.u16(name_id_length)
            for name in names:
                writer.u16(len(name))
                writer.bytes(name)
            writer.bytes(rest)


def is_we(file: pathlib.Path):
    return file.suffix == '.we'


def lua_dump(value):
    if type(value) is str:
        return repr(value)
    elif type(value) in {int, float}:
        return str(value)
    elif type(value) in {list, tuple}:
        return f'{{{", ".join(map(lua_dump, value))}}}'
    elif type(value) is dict:
        return '{' + ', '.join(f'[{lua_dump(k)}] = {lua_dump(v)}' for k, v in value.items()) + '}'
    elif value is None:
        return 'nil'
    elif value is True:
        return 'true'
    elif value is False:
        return 'false'
    elif lupa.lua_type(value) == 'table':
        return lua_dump(dict(value.items()))
    else:
        raise RuntimeError(f'value {value!r} w/ unexpected type {type(value)}')


def convert_we(child, alias_map):
    print(f'processing {child}')
    with child.open('r') as fh:
        contents = fh.read()

    assert(contents[:9] == '5:return ')
    table = lua.eval(contents[9:])
    data = tuple(map(dict, table.values()))
    any_changed = False
    for point in data:
        alias = alias_map.get(point['name'])
        if alias:
            point['name'] = alias
            any_changed = True

    if any_changed:
        print('writing changes...')
        output = f'5:return {lua_dump(data)}'
        with child.open('w') as fh:
            fh.write(output)


def create_alias_map(stairsplus_dump: pathlib.Path):
    print('reading aliases from dump')
    aliases = {}
    with stairsplus_dump.open() as fh:
        data = json.load(fh)

    for alias, shaped_node in data['aliases'].items():
        aliases[alias] = shaped_node

    return aliases


def main(args):
    alias_map = create_alias_map(args.stairsplus_dump)

    for child in args.schems.iterdir():
        if child.is_file():
            if is_schem(child):
                convert_schem(child, alias_map)
            elif is_we(child):
                convert_we(child, alias_map)
            else:
                print(f'unknown file type {child.suffix}')


def existing_file(path: str) -> pathlib.Path:
    file_path = pathlib.Path(path)
    if not file_path.exists():
        raise argparse.ArgumentTypeError(f'{path!r} does not exist.')
    if not file_path.is_file():
        raise argparse.ArgumentTypeError(f'{path!r} is not a file.')
    return file_path


def existing_directory(path: str) -> pathlib.Path:
    file_path = pathlib.Path(path)
    if not file_path.exists():
        raise argparse.ArgumentTypeError(f'{path!r} does not exist.')
    if not file_path.is_dir():
        raise argparse.ArgumentTypeError(f'{path!r} is not a directory.')
    return file_path


def parse_args(args=None, namespace=None):
    p = argparse.ArgumentParser()
    p.add_argument('stairsplus_dump', type=existing_file)
    p.add_argument('schems', type=existing_directory)
    return p.parse_args(args=args, namespace=namespace)


if __name__ == "__main__":
    main(parse_args())
