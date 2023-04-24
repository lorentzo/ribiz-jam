
This folder contains:
* Tile textures: floor, 2 walls, 4 corners.
* `tileset.tres` -> Godot resource containing configured tiles for creating tilemap.
* `TilemMapTemplate.tscn` -> Godot scene containing configured TileMap object with `Tilemap.tres`

`TileMapTemplate.tscn` servers as an example of how `tilemap` object can be created and configured.

When creating new `tilemap` object with textures in this folder perform following:
1. Add `Tilemap` child node
2. In `Tilemap` inspector, set:
    * `Mode` to `Isometric`
    * `Tile Set` load `tileset.tres`
    * `Cell -> Size` to x: 256, y:180
3. Set `Y Sort` to `On`.
4. Start creating `tilemap` in editor.