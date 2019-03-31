# This is a generated file! Please edit source .ksy file and use kaitai-struct-compiler to rebuild

from pkg_resources import parse_version
from kaitaistruct import __version__ as ks_version, KaitaiStruct, KaitaiStream, BytesIO
from enum import Enum


if parse_version(ks_version) < parse_version('0.7'):
    raise Exception("Incompatible Kaitai Struct Python API: 0.7 or later is required, but you have %s" % (ks_version))

class WebsocketDataframe(KaitaiStruct):
    """The WebSocket protocol establishes a two-way communication channel via TCP.
    Messages are made up of one or more dataframes, and are delineated by
    frames with the `fin` bit set.
    """

    class Opcode(Enum):
        continuation = 0
        text = 1
        binary = 2
        reserved_3 = 3
        reserved_4 = 4
        reserved_5 = 5
        reserved_6 = 6
        reserved_7 = 7
        close = 8
        ping = 9
        pong = 10
        reserved_control_b = 11
        reserved_control_c = 12
        reserved_control_d = 13
        reserved_control_e = 14
        reserved_control_f = 15
    def __init__(self, _io, _parent=None, _root=None):
        self._io = _io
        self._parent = _parent
        self._root = _root if _root else self
        self._read()

    def _read(self):
        self.finished = self._io.read_bits_int(1) != 0
        self.reserved = self._io.read_bits_int(3)
        self.opcode = self._root.Opcode(self._io.read_bits_int(4))
        self.is_masked = self._io.read_bits_int(1) != 0
        self.len_payload_primary = self._io.read_bits_int(7)
        self._io.align_to_byte()
        if self.len_payload_primary == 126:
            self.len_payload_extended_1 = self._io.read_u2be()

        if self.len_payload_primary == 127:
            self.len_payload_extended_2 = self._io.read_u4be()

        if self.is_masked:
            self.mask_key = self._io.read_u4be()

        self.payload = self._io.read_bytes(self.len_payload)

    @property
    def len_payload(self):
        if hasattr(self, '_m_len_payload'):
            return self._m_len_payload if hasattr(self, '_m_len_payload') else None

        self._m_len_payload = (self.len_payload_primary if self.len_payload_primary <= 125 else (self.len_payload_extended_1 if self.len_payload_primary == 126 else self.len_payload_extended_2))
        return self._m_len_payload if hasattr(self, '_m_len_payload') else None


