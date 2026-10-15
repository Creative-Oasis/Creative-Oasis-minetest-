import struct


class StreamReader:
    def __init__(self, data: bytes):
        self._data = data
        self._start = 0

    def u8(self) -> int:
        sformat = '>B'
        ssize = struct.calcsize(sformat)
        rv = struct.unpack(sformat, self._data[self._start:self._start + ssize])
        self._start = self._start + ssize
        return rv[0]

    def u16(self) -> int:
        sformat = '>H'
        ssize = struct.calcsize(sformat)
        rv = struct.unpack(sformat, self._data[self._start:self._start + ssize])
        self._start = self._start + ssize
        return rv[0]

    def s32(self) -> int:
        sformat = '>i'
        ssize = struct.calcsize(sformat)
        rv = struct.unpack(sformat, self._data[self._start:self._start + ssize])
        self._start = self._start + ssize
        return rv[0]

    def u32(self) -> int:
        sformat = '>I'
        ssize = struct.calcsize(sformat)
        rv = struct.unpack(sformat, self._data[self._start:self._start + ssize])
        self._start = self._start + ssize
        return rv[0]

    def bytes(self, count: int) -> bytes:
        rv = self._data[self._start:self._start + count]
        self._start = self._start + count
        return rv

    def inventory_bytes(self) -> bytes:
        start_of_end = self._data.find(b'EndInventory\n', self._start)
        if start_of_end == -1:
            return
        actual_end = start_of_end + len(b'EndInventory\n')
        rv = self._data[self._start:actual_end]
        self._start = actual_end
        return rv

    def rest(self) -> bytes:
        return self._data[self._start:]


class StreamWriter:
    def __init__(self, fh):
        self._fh = fh

    def u8(self, value):
        sformat = '>B'
        self._fh.write(struct.pack(sformat, value))

    def u16(self, value):
        sformat = '>H'
        self._fh.write(struct.pack(sformat, value))

    def u32(self, value):
        sformat = '>I'
        self._fh.write(struct.pack(sformat, value))

    def bytes(self, value: bytes):
        self._fh.write(value)
