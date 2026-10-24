package.path = "./?.lua;./?/init.lua;" .. package.path
for _, version in ipairs({ "firered", "emerald" }) do
  dofile("tests/gen3_ai_party_status/cases.lua").run("gen1", version)
end
require("tests.modkit").finish("native GBA AI party status")
