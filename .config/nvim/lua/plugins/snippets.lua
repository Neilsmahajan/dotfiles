-- ~/.config/nvim/lua/plugins/snippets.lua

return {
  "L3MON4D3/LuaSnip",
  config = function()
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node

    -- Arduino snippets
    ls.add_snippets("arduino", {
      s("setup", {
        t("void setup() {"), t({ "", "    Serial.begin(9600);" }),
        t({ "", "    " }), i(1, "// Setup code"), t({ "", "}" }),
        t({ "", "" }), t({ "", "void loop() {" }),
        t({ "", "    " }), i(2, "// Main code"), t({ "", "}" }),
      }),

      s("pinMode", {
        t("pinMode("), i(1, "pin"), t(", "), i(2, "INPUT"), t(");"),
      }),

      s("digitalRead", {
        t("digitalRead("), i(1, "pin"), t(")"),
      }),

      s("digitalWrite", {
        t("digitalWrite("), i(1, "pin"), t(", "), i(2, "HIGH"), t(");"),
      }),

      s("print", {
        t("Serial.print("), i(1, "value"), t(");"),
      }),

      s("println", {
        t("Serial.println("), i(1, "value"), t(");"),
      }),
    })
  end,
}
