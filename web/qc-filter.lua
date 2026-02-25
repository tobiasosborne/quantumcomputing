-- qc-filter.lua — Pandoc Lua filter for QC lecture notes
-- Converts custom LaTeX environments to styled HTML with
-- foldable details/summary elements.

local envs = {
  intuition    = { default_title = "Physical intuition",  foldable = true,  open = true,
                   cls = "box-intuition" },
  historical   = { default_title = "Historical note",     foldable = true,  open = true,
                   cls = "box-historical" },
  keyresult    = { default_title = "Key result",          foldable = true,  open = true,
                   cls = "box-keyresult" },
  algorithmbox = { default_title = "Algorithm",           foldable = true,  open = true,
                   cls = "box-algorithm" },
  solution     = { default_title = "Solution",            foldable = true,  open = false,
                   cls = "box-solution" },
  definition   = { default_title = "Definition",          foldable = false, open = false,
                   cls = "box-definition" },
  exercise     = { default_title = "Exercise",            foldable = false, open = false,
                   cls = "box-exercise" },
  example      = { default_title = "Example",             foldable = false, open = false,
                   cls = "box-example" },
  remark       = { default_title = "Remark",              foldable = false, open = false,
                   cls = "box-remark" },
  note         = { default_title = "Note",                foldable = false, open = false,
                   cls = "box-remark" },
  notation     = { default_title = "Notation",            foldable = false, open = false,
                   cls = "box-notation" },
  theorem      = { default_title = "Theorem",             foldable = false, open = false,
                   cls = "box-theorem" },
  lemma        = { default_title = "Lemma",               foldable = false, open = false,
                   cls = "box-theorem" },
  proposition  = { default_title = "Proposition",         foldable = false, open = false,
                   cls = "box-theorem" },
  corollary    = { default_title = "Corollary",           foldable = false, open = false,
                   cls = "box-theorem" },
}

function Div(el)
  for env_name, cfg in pairs(envs) do
    if el.classes:includes(env_name) then
      local title = cfg.default_title
      local data = el.attributes["data-latex"]
      if data then
        local t = data:match("%[(.-)%]")
        if t and t ~= "" then
          title = t
        end
      end

      local content = pandoc.write(pandoc.Pandoc(el.content), "html")

      if cfg.foldable then
        local open_attr = cfg.open and " open" or ""
        local html = string.format(
          '<details class="%s"%s>\n<summary>%s</summary>\n<div class="box-body">\n%s\n</div>\n</details>',
          cfg.cls, open_attr, title, content
        )
        return pandoc.RawBlock("html", html)
      else
        local html = string.format(
          '<div class="%s">\n<strong>%s.</strong>\n%s\n</div>',
          cfg.cls, title, content
        )
        return pandoc.RawBlock("html", html)
      end
    end
  end
end

function RawBlock(el)
  if el.format == "latex" then
    if el.text:match("\\begin{tikzpicture}") or el.text:match("TikZ diagram") then
      return pandoc.RawBlock("html",
        '<div class="tikz-placeholder">[TikZ diagram — see PDF]</div>')
    end
    local center_content = el.text:match("\\begin{center}%s*(.-)%s*\\end{center}")
    if center_content then
      local inner = center_content:match("\\textit{(.-)}")
      if inner then
        return pandoc.RawBlock("html",
          '<div class="tikz-placeholder">' .. inner .. '</div>')
      end
    end
  end
end
