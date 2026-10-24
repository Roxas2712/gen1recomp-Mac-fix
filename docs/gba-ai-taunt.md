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
