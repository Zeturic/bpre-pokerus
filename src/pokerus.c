#include "global.h"
#include "pokemon.h"
#include "random.h"
#include "util.h"

// https://github.com/pret/pokeemerald/blob/9a6c2c25d08ef157cc4800014651bd0c679f6fc5/src/pokemon.c#L5895
void RandomlyGivePartyPokerus(struct Pokemon *party)
{
    u16 rnd = Random();
    if (rnd == 0x4000 || rnd == 0x8000 || rnd == 0xC000)
    {
        struct Pokemon *mon;

        do
        {
            do
            {
                rnd = Random() % PARTY_SIZE;
                mon = &party[rnd];
            }
            while (!GetMonData(mon, MON_DATA_SPECIES, 0));
        }
        while (GetMonData(mon, MON_DATA_IS_EGG, 0));

        if (!(CheckPartyHasHadPokerus(party, gBitTable[rnd])))
        {
            u8 rnd2;

            do
            {
                rnd2 = Random();
            }
            while ((rnd2 & 0x7) == 0);

            if (rnd2 & 0xF0)
                rnd2 &= 0x7;

            rnd2 |= (rnd2 << 4);
            rnd2 &= 0xF3;
            rnd2++;

            SetMonData(&party[rnd], MON_DATA_POKERUS, &rnd2);
        }
    }
}

// https://github.com/pret/pokeemerald/blob/9a6c2c25d08ef157cc4800014651bd0c679f6fc5/src/pokemon.c#L6015
void PartySpreadPokerus(struct Pokemon *party)
{
    if ((Random() % 3) == 0)
    {
        int i;
        for (i = 0; i < PARTY_SIZE; i++)
        {
            if (GetMonData(&party[i], MON_DATA_SPECIES, 0))
            {
                u8 pokerus = GetMonData(&party[i], MON_DATA_POKERUS, 0);
                u8 curPokerus = pokerus;
                if (pokerus)
                {
                    if (pokerus & 0xF)
                    {
                        // Spread to adjacent party members.
                        if (i != 0 && !(GetMonData(&party[i - 1], MON_DATA_POKERUS, 0) & 0xF0))
                            SetMonData(&party[i - 1], MON_DATA_POKERUS, &curPokerus);
                        if (i != (PARTY_SIZE - 1) && !(GetMonData(&party[i + 1], MON_DATA_POKERUS, 0) & 0xF0))
                        {
                            SetMonData(&party[i + 1], MON_DATA_POKERUS, &curPokerus);
                            i++;
                        }
                    }
                }
            }
        }
    }
}

// https://github.com/pret/pokeemerald/blob/9a6c2c25d08ef157cc4800014651bd0c679f6fc5/src/pokemon.c#L5991
void UpdatePartyPokerusTime(u16 days)
{
    int i;
    for (i = 0; i < PARTY_SIZE; i++)
    {
        if (GetMonData(&gPlayerParty[i], MON_DATA_SPECIES, 0))
        {
            u8 pokerus = GetMonData(&gPlayerParty[i], MON_DATA_POKERUS, 0);
            if (pokerus & 0xF)
            {
                if ((pokerus & 0xF) < days || days > 4)
                    pokerus &= 0xF0;
                else
                    pokerus -= days;

                if (pokerus == 0)
                    pokerus = 0x10;

                SetMonData(&gPlayerParty[i], MON_DATA_POKERUS, &pokerus);
            }
        }
    }
}

#ifdef INSERT_POKERUS_SPECIAL

// https://github.com/pret/pokeemerald/blob/9a6c2c25d08ef157cc4800014651bd0c679f6fc5/src/field_specials.c#L1489
bool8 IsPokerusInParty(void)
{
    if (!CheckPartyPokerus(gPlayerParty, 0x3f))
    {
        return FALSE;
    }
    return TRUE;
}

#endif
