#pragma once

#include "constants/pokemon.h"

struct packed Pokemon {
    u8 _[100];
};

extern struct Pokemon gPlayerParty[];

u32 GetMonData(struct Pokemon *mon, s32 field, u8 *data);
void SetMonData(struct Pokemon *mon, s32 field, const void *dataArg);
u8 CheckPartyHasHadPokerus(struct Pokemon *party, u8 selection);
u8 CheckPartyPokerus(struct Pokemon *party, u8 selection);
void AdjustFriendship(struct Pokemon *mon, u8 event);
