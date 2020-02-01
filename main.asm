.gba
.thumb

.open "rom.gba", "test.gba", 0x08000000

.org allocation
.area allocation_size
    .importobj "build/linked.o"
.endarea

.org 0x08043A68
.area 8, 0xFE
    ldr r3, =RandomlyGivePartyPokerus |1
    bx r3
    .pool
.endarea

.org 0x08043B38
.area 8, 0xFE
    ldr r3, =UpdatePartyPokerusTime |1
    bx r3
    .pool
.endarea

.org 0x08043B40
.area 8, 0xFE
    ldr r3, =PartySpreadPokerus |1
    bx r3
    .pool
.endarea

.if 0 <= Special_IsPokerusInParty
    .org gSpecials + Special_IsPokerusInParty * 4
    .word IsPokerusInParty |1
.endif

.if 0 <= CHANCE_REDUCE_POKERUS_128_STEPS
    .org 0x0806D74C
    .area 0x34, 0xFE
        ldr r3, =UpdateHappinessStepCounter |1
        bx r3
        .pool
    .endarea
.endif

.close

.definelabel gSpecials, readu32("rom.gba", 0x08069F18 & 0x1FFFFFF)
