# GBA AI Taunt predicates

`if_target_taunted` and `if_target_not_taunted` now read the live target's
`expTauntedTurns`, the same timer already used by move limitations and the
owned Taunt effect/residual handlers. Previously, these commands always
answered false/true even while Taunt was active.

The predicates read only TARGET, leave its timer untouched and consume no
RNG. The regression cases run the actual GBA AI VM for FireRed/Emerald in
single/double configurations. They additionally invoke the owned Taunt
effect and the real residual scheduler to verify application, the two-tick
lifetime, no refresh on repeat, expiration and reapplication. A presentation
text seam avoids requiring cartridge text; no query or timer implementation
is replaced.

```sh
luajit tests/engine/game3_ai_taunt_test.lua
```

The shared case file also runs in Gen2Recomped for the counterpart contract.
This is bounded AI/effect/residual validation, not a complete ordinary move,
accuracy, animation or gameplay test. It does not change Taunt duration here.

## Validation record

At source runtime `cdd4ad167373e2b5f08c96f95ee87041f59e0e17`:

- **372/372** focused checks pass on FireRed/Emerald.
- The shared Gen2Recomped counterpart matches in **4 workers / 96 paired
  observations**, including both predicate directions and real effect/residual
  lifetime. Upstream dev `535a5ec` fails 56 assertions and differs in 28
  observations per GBA profile, detecting the old placeholders.
- Standard tiers pass **1,116/1,116** engine suites (upstream: 1,115/1,115),
  **161/161** Gen-2, **59/59** save-codec, **2/2** save-record,
  **2/2** save-world, **11/11** Gen-5 and **79/79** SDK suites.
- The top-level game3 tier reports **425 run / 425 passed**, including **261
  self-skips** where cartridge caches are unavailable. Other selected standard
  tiers pass as well. These skips are not native gameplay evidence.

The initial standard run lacked a subprocess LuaJIT path and Java, reproducing
exactly on upstream. With LuaJIT configured, only the Java-dependent Android
importer tier remained unavailable. That tier passes separately with a
checksum-verified temporary Temurin 21.0.13+9 JDK; upstream passes it too.
The original standard-run exit status remains recorded rather than relabeled.
Logs are outside the checkout in local `tmp/ai-taunt-paired-qa/`.
