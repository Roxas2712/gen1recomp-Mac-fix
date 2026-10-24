# Native GBA AI party status

`if_status_in_party` now implements native STATUS1 equality instead of a
best-effort subset test. It scans the six stored party slots, including
active mons, and requires nonzero HP and a species other than NONE/EGG.
Sparse records and a seventh slot do not change those boundaries.

FireRed interprets selector 1 as the enemy party and every other selector as
the player party. Emerald instead selects the current user or target's side;
non-1 selectors mean target, including in doubles and player-side AI contexts.
Queries read stored party data, without substituting active-battler status,
mutating records or consuming RNG.

The native command uses MON_DATA_SPECIES, which reads the underlying species
for an ordinary egg. It does not test the normal egg flag. Bad eggs and the
explicit EGG species are excluded. The implementation preserves that detail
rather than applying an unrelated usable-party predicate.

Raw numeric status words retain all 32 bits. Named legacy conditions map to
native values; named sleep reads its stored remaining turns (legacy records
without a counter retain the previous value of seven). Sleep infliction and
the actual attack canceller now maintain party sleep counters; clearing the
status clears those fields as well. This makes the exact reader usable with
actual owned status producers, not only manually constructed raw words.

The unused, broken `if_status_not_in_party` macro is not changed here; the
paired host keeps it unsupported. This feature does not change active-battler
bitmask predicates or establish complete battle/controller parity.

Primary references:
[FireRed AI commands](https://github.com/pret/pokefirered/blob/master/src/battle_ai_script_commands.c),
[FireRed species reader](https://github.com/pret/pokefirered/blob/master/src/pokemon.c),
[Emerald AI commands](https://github.com/pret/pokeemerald/blob/731ad5bfd6e6f265508d0efcca0ba42f9dcf5881/src/battle_ai_script_commands.c).

## Validation

```sh
luajit tests/engine/game3_ai_party_status_test.lua
```

The byte-identical shared fixture runs actual VMs on FireRed/Emerald. It
covers all 256 low-byte words, unsigned/high-bit values, exact zero, all
user/target double slots and selectors, six-slot/HP/species boundaries,
ordinary/bad eggs, active versus stored party status and no-mutation/RNG.
Actual status infliction, sleep cancellation, Early Bird waking and curing
are included; only ROM text presentation is replaced. Typed cartridge-shaped
move records provide input for the real canceller.

Focused checks pass **7,496/7,496**, and **4 workers / 2,500 paired observations**
match the paired host. Unchanged upstream dev is a negative control: **352**
failed checks and **352** differing observations per GBA profile.
Expanded focused cases pass after the source standard engine tier, with
unchanged production code. Full standard-run evidence is recorded in the PR.
No cartridge assets, generated data or graphical gameplay run are included.
