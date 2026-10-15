# Capes MTG (Server-Side Capes)

Adds smooth, dynamic 3D cosmetic capes with realistic movement physics and global wind simulation to Luanti/Minetest!

Ported and rewritten to run purely **server-side**, meaning no client modifications or CSMs are required for players to enjoy animated physics.

---

## Features

* **Physics-Based Animation:** Features smooth sway, movement inertia, walking balance (bobbing), and turn-inclination.
* **Idle Breathing:** Natural idle waving movement even when standing still.
* **Global Wind Simulation:** Dynamic world wind vectors that affect the direction and intensity of cape movement.
* **Hidden in First Person:** Clean first-person view without clipping or blocking the player's camera.
* **Server-Side Native:** Fully synchronized across all connected players automatically.

---

## Future Commands

* `/cape <texture_name.png>`: Allows players to change their cape texture on the fly.

---

## License & Credits

* **Code License:** MIT License (by Sushi7270)
* **Media License:** MIT License

### Media & Assets Covered (MIT License)
* Models: `models/cape_cosmetic.obj`, `models/placehold.obj`
* Textures: `textures/cape_texture.png`, `textures/crown_cape.png`, `textures/placehold.png`

### Credits & Attributions
* **ProunceDev (Eclipse Client Team):** Original 3D cape models (`cape_cosmetic.obj`, `placehold.obj`), base textures (`cape_texture.png`, `crown_cape.png`, `placehold.png`), and client-side physics logic (`cosmetics.lua`).
  * **Original License:** MIT License
  * **Source Link:** [EclipseClient Repository](https://github.com/TeamAcedia/EclipseClient/tree/master/builtin/eclipse)
* **Sushi7270:** Porting, rewriting, and adapting physics to Luanti/Minetest server-side API (`minetest.register_globalstep`, `minetest.register_entity`, and `set_attach`).
