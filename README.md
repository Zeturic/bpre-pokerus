## Pokérus

Due to the lack of a RTC in FR, [Pokérus](https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9rus) was scaled back. It can't be randomly caught, spread, or cured. Its EV-doubling effect does still work, if you trade something with Pokérus to FR, but that's pretty much it.

This adds the relevant functions from [pokeemerald](github.com/pret/pokeemerald) back in, allowing for it to be randomly caught, spread, and cured.

### Build Instructions

See [here](https://gist.github.com/Zeturic/db1611cc7b17c3140f9b9af32e1b596b) for the prequisites and help in installing them.

#### Cloning the repo and building the tools

Open your terminal to whatever folder you want to download this repo into. Then, do the following to download the repo:

```shell
$ git clone https://github.com/Zeturic/bpre-pokerus.git
$ cd bpre-pokerus
$ ./build_tools.sh
```

#### Adding your ROM

Copy your ROM to this directory and rename it `rom.gba`.

#### Configuration

Open `config.mk` in a text editor to set some compile-time configuration.

The build system is smart enough to find enough free space on its own, but if you want it to be inserted at a particular address, you can specify it by updating the definition of `START_AT`.

If the given address is acceptable (i.e. is word-aligned and has enough bytes of free space), it will be inserted there. Otherwise, it will just use `START_AT` to determine where in the ROM it should start looking for free space.

There is a special in RSE that checks if a Pokémon in your party has Pokérus. It's used in the Nurse Joy script. This special doesn't normally exist in FR, but it is included in this repo.

If you don't want said special to be inserted, make sure to set `Special_IsPokerusInParty` to `-1`. If you do want it, set it to an unused special id. It's currently set to `0x133`, which is unused by default, but if that doesn't work for you, feel free to change it.

Curing Pokérus is normally tied to the RTC. Basically, it has a "days left" counter and every day, all the Pokémon in the player's party with Pokérus have that counter decremented. Because not every FR hack includes an RTC, this feature wasn't included here. An additional issue is the fact that there are multiple RTC implementations which would have to be supported separately.

Instead, every 128 steps the player walks has a small chance to decrement the counter. If you don't want this (and thus it will never be cured), make sure to set `CHANCE_REDUCE_POKERUS_128_STEPS` to `-1`. If you do want it, `CHANCE_REDUCE_POKERUS_128_STEPS` defaults to `5` percent, but feel free to change it.

#### Building the project itself

Once you're ready, run the following to build the project:

```shell
make
```

This won't actually modify `rom.gba`, instead your output will be in `test.gba`. Naturally, test it in an emulator.

### Additional Notes

Nurse Joy's script doesn't include any sort of message about Pokérus. If you inserted the special, you can modify her script to do so. Check the Nurse Joy script in Emerald to see how to use the special; in Emerald, `Special_IsPokerusInParty` is `0x136`.

### Credits

The project structure and some of the build tools are from [pokeemerald](https://github.com/pret/pokeemerald).

Several Pokérus-related functions were lifted directly (or with minor changes) from [pokeemerald](https://github.com/pret/pokeemerald) as well.
