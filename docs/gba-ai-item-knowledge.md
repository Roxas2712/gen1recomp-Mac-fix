# Native GBA AI item knowledge

`get_hold_effect` now reads native held-effect metadata instead of always
returning zero. `if_holds_item` uses the same battle-local observation cache.
Reads do not reveal a current opponent item, invoke the public held-item
substitution callback, mutate history or consume RNG.

Two actual native producers record the selected effect byte: a successful
Focus Band adjustment roll and an activated Leftovers heal. Failed rolls,
full-HP Leftovers, ordinary data reads, unrelated HP loss and berry consumption
do not invent observations. Other history families remain intact.

The profile behavior follows the cartridge commands, including their quirks:

- FireRed records player-side observations in one shared side byte; enemy
  observations do not populate it. Its hold-effect getter reads this byte for
  player battlers and actual item metadata for enemy battlers.
- Emerald records separate slot bytes. The hold-effect getter reads the
  current AI battler directly; for another battler it passes the observed
  EFFECT byte through the ITEM metadata reader. It is deliberately not
  replaced by either an inventory peek or an unconditional zero.
- Membership compares own-side physical item IDs with an operand formed by
  OR-ing its two bytes; opposing queries compare the observed byte. The
  retail byte-OR behavior is retained, including for declared custom IDs.

These are native VM semantics, not a new public inventory/snapshot contract.
The cache is scoped to a battle and preserves the native slot/side lifetime.

The ordinary held-item reader now prefers loaded metadata over the legacy
fallback table. In particular an explicit NONE effect or zero-percent Focus
Band is authoritative. This keeps activation and AI metadata reads consistent
and allows live definitions to work. The fallback remains for missing records.

Primary references:
[FireRed AI commands](https://github.com/pret/pokefirered/blob/master/src/battle_ai_script_commands.c),
[Emerald AI commands](https://github.com/pret/pokeemerald/blob/731ad5bfd6e6f265508d0efcca0ba42f9dcf5881/src/battle_ai_script_commands.c),
[Emerald item reader](https://github.com/pret/pokeemerald/blob/731ad5bfd6e6f265508d0efcca0ba42f9dcf5881/src/item.c).

## Validation

The same case file runs through Gen1Recomp's actual GBA VM and the paired
Gen2Recomped VM. It exercises all 67 declared effect numbers, own/opposing
selectors and double slots, byte folding, live metadata, history ownership,
read-only/RNG behavior and real effect/damage producers. Actual direct-hit,
attack-canceller and OHKO paths cover Focus Band success/failure, nonlethal
hits, Substitute, Endure, Sturdy, level/chance failure and zero-percent rolls.

```sh
luajit tests/engine/game3_ai_item_knowledge_test.lua
```

Focused checks pass **1,240/1,240**. The expanded cross-engine matrix contains
**4 workers / 364 paired observations** with zero differences.
The source standard run passes **1,116/1,116** engine suites, Gen-2 **161/161**,
save codecs **59/59**, save records **2/2**, save world **2/2**, Gen-5 **11/11**,
SDK **79/79** and all other selected tiers. The game3 top-level tier reports
**425/425**, including **261 self-skips** without cartridge caches.
The final expanded focused cases also pass after that standard run; source
production code is unchanged. LuaJIT and a temporary checksum-verified JDK
are explicitly configured; no global runtime install is required.

These are bounded CPU VM/effect/damage checks. They do not establish all
native AI opcodes, complete ordinary controller or graphical gameplay parity.
No cartridge data or generated assets are committed. Local logs are retained
outside the checkout under `tmp/ai-item-knowledge-qa/`.
