package.path = "./?.lua;./?/init.lua;" .. package.path
for _, version in ipairs({ "firered", "emerald" }) do
  dofile("tests/gen3_ai_taunt/cases.lua").run("gen1", version)
end
require("tests.modkit").finish("native GBA AI Taunt predicates")
