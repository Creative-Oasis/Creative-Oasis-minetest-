# https://github.com/minetest/minetest/blob/master/doc/world_format.txt#L301
# https://docs.python.org/3/library/struct.html
import collections

import pyzstd

from stream import StreamReader

MAP_BLOCKSIZE = 16


vector = collections.namedtuple('vector', ('x', 'y', 'z'))


def unpack_pos(packed_pos):
    # 16*(16*z + y) + x
    zy, x = divmod(packed_pos, 16)
    z, y = divmod(zy, 16)
    return vector(x, y, z)


class Inventory:
    def __init__(self):
        pass

    @staticmethod
    def from_bytes(data: bytes):
        inv = Inventory()
        return inv


class MetaData:
    def __init__(self):
        self._meta = {}
        self._private = set()

    def __getitem__(self, key: bytes):
        return self._meta[key]

    def __setitem__(self, key: bytes, value: bytes):
        self._meta[key] = value

    def mark_as_private(self, key: bytes, private: bool):
        if private:
            self._private.add(key)
        else:
            self._private.discard(key)


class StaticObject:
    def __init__(self, type_, pos, data):
        self._type = type_
        self._pos = pos
        self._data = data


class Timer:
    def __init__(self, timeout: int, elapsed: int):
        self._timeout = timeout
        self._elapsed = elapsed


class MapBlock:
    def __init__(self):
        self._flags = 0
        self._lighting_complete = 0
        self._timestamp = 0
        self._nodes = tuple(
            tuple(
                ["ignore" for _ in range(MAP_BLOCKSIZE)]
                for _ in range(MAP_BLOCKSIZE)
            ) for _ in range(MAP_BLOCKSIZE)
        )
        self._param1 = tuple(
            tuple(
                [0 for _ in range(MAP_BLOCKSIZE)]
                for _ in range(MAP_BLOCKSIZE)
            ) for _ in range(MAP_BLOCKSIZE)
        )
        self._param2 = tuple(
            tuple(
                [0 for _ in range(MAP_BLOCKSIZE)]
                for _ in range(MAP_BLOCKSIZE)
            ) for _ in range(MAP_BLOCKSIZE)
        )
        self._metadata = tuple(
            tuple(
                [None for _ in range(MAP_BLOCKSIZE)]
                for _ in range(MAP_BLOCKSIZE)
            ) for _ in range(MAP_BLOCKSIZE)
        )
        self._inventory = tuple(
            tuple(
                [None for _ in range(MAP_BLOCKSIZE)]
                for _ in range(MAP_BLOCKSIZE)
            ) for _ in range(MAP_BLOCKSIZE)
        )
        self._timer = tuple(
            tuple(
                [None for _ in range(MAP_BLOCKSIZE)]
                for _ in range(MAP_BLOCKSIZE)
            ) for _ in range(MAP_BLOCKSIZE)
        )

    def iter_nodes(self):
        for plane in self._nodes:
            for row in plane:
                yield from row

    @staticmethod
    def import_from_serialized(serialized_data: bytes):
        mapblock = MapBlock()
        version = serialized_data[0]  # struct.unpack('>b', serialized_data)
        if version != 29:
            raise RuntimeError(f'can\'t parse version {version}')

        stream = StreamReader(pyzstd.decompress(serialized_data[1:]))
        mapblock._flags = stream.u8()
        mapblock._lighting_complete = stream.u16()
        mapblock._timestamp = stream.u32()
        name_id_mapping_version = stream.u8()
        num_name_id_mappings = stream.u16()

        if name_id_mapping_version != 0:
            raise RuntimeError(f'can\'t grok name_id_mapping_version {name_id_mapping_version}')

        name_by_id = {}
        for _ in range(num_name_id_mappings):
            id_ = stream.u16()
            name_len = stream.u16()

            name_by_id[id_] = stream.bytes(name_len)

        content_width = stream.u8()
        if content_width != 2:
            raise RuntimeError(f'invalid content_width {content_width}')

        params_width = stream.u8()

        if params_width != 2:
            raise RuntimeError(f'invalid params_width {params_width}')

        for z in range(MAP_BLOCKSIZE):
            for y in range(MAP_BLOCKSIZE):
                for x in range(MAP_BLOCKSIZE):
                    mapblock._nodes[z][y][x] = name_by_id[stream.u16()]

        for z in range(MAP_BLOCKSIZE):
            for y in range(MAP_BLOCKSIZE):
                for x in range(MAP_BLOCKSIZE):
                    mapblock._param1[z][y][x] = stream.u8()

        for z in range(MAP_BLOCKSIZE):
            for y in range(MAP_BLOCKSIZE):
                for x in range(MAP_BLOCKSIZE):
                    mapblock._param2[z][y][x] = stream.u8()

        ib = ''
        node_metadata_version = stream.u8()
        if node_metadata_version > 0:

            if node_metadata_version != 2:
                raise RuntimeError(f'unexpected node_metadata_version {node_metadata_version}')

            node_metadata_count = stream.u16()

            for _ in range(node_metadata_count):
                pos = unpack_pos(stream.u16())
                meta = MetaData()
                num_vars = stream.u32()
                for _ in range(num_vars):
                    key_len = stream.u16()
                    key = stream.bytes(key_len)
                    val_len = stream.u32()
                    meta[key] = stream.bytes(val_len)
                    meta.mark_as_private(key, stream.u8() == 1)

                mapblock._metadata[pos.z][pos.y][pos.x] = meta
                mapblock._inventory[pos.z][pos.y][pos.x] = Inventory.from_bytes(stream.inventory_bytes())

        static_object_version = stream.u8()

        if static_object_version != 0:
            raise RuntimeError(f'unexpected static_object_version {static_object_version} {ib} {stream._data}')

        static_object_count = stream.u16()
        static_objects = []

        for _ in range(static_object_count):
            type_ = stream.u8()
            pos_x_nodes = stream.s32() / 1e5
            pos_y_nodes = stream.s32() / 1e5
            pos_z_nodes = stream.s32() / 1e5
            data_size = stream.u16()
            data = stream.bytes(data_size)
            static_objects.append(StaticObject(type_, vector(pos_x_nodes, pos_y_nodes, pos_z_nodes), data))

        timers_length = stream.u8()
        if timers_length != 10:
            raise RuntimeError(f'unexpected timers_length {timers_length}')
        num_of_timers = stream.u16()
        for _ in range(num_of_timers):
            pos = unpack_pos(stream.u16())
            timeout = stream.s32()
            elapsed = stream.s32()
            mapblock._timer[pos.z][pos.y][pos.x] = Timer(timeout, elapsed)

        return mapblock


class MapBlockSimple:
    def __init__(self):
        self.node_names = []

    @staticmethod
    def import_from_serialized(serialized_data: bytes):
        mapblock = MapBlockSimple()
        version = serialized_data[0]
        if type(version) is bytes:
            version = ord(version)
        if version != 29:
            raise RuntimeError(f'can\'t parse version {version}')

        stream = StreamReader(pyzstd.decompress(serialized_data[1:]))
        stream.u8()  # flags
        stream.u16()  # lighting_complete
        stream.u32()  # timestamp
        name_id_mapping_version = stream.u8()
        num_name_id_mappings = stream.u16()

        if name_id_mapping_version != 0:
            raise RuntimeError(f'can\'t grok name_id_mapping_version {name_id_mapping_version}')

        for _ in range(num_name_id_mappings):
            stream.u16()  # id
            name_len = stream.u16()
            mapblock.node_names.append(stream.bytes(name_len))

        return mapblock
