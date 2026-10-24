package.path = "./?.lua;./?/init.lua;" .. package.path
for _, version in ipairs({ "firered", "emerald" }) do
  dofile("tests/gen3_ai_item_knowledge/cases.lua").run("gen1", version)
end
require("tests.modkit").finish("native GBA AI item knowledge")
