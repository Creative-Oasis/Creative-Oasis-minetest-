# compression_api Documentation

## Functions
`compression.darken_tiles(tiles, count)`: Darkens every tile in the `tiles` table `count` times.

`compression.register_compressed_tiers(node)`: Registers compressed versions of the provided `node`; If the provided node has been compressed previously, `groups.compressed` must be set to however many times it has been compressed. (eg. `moreblocks:cobble_compressed` must have a `groups.compressed` value of `1`.)

`compression.register_compressed_nodes(nodes)`: Registers every node in the provided table. (eg. `{"default:cobble", "default:desert_cobble"}`)

## Settings
`max_compression_level`: The maximum compression tier; Default is 10.
