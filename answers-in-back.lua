-- answers-in-back.lua
-- Used by the "answers" profile (see _quarto-answers.yml). In the combined
-- single-document render (the PDF), this filter removes every "Answer" callout
-- from its place in the text and gathers all of them into an unnumbered
-- chapter, "Answers to the exercises", inserted just before the References
-- chapter. Exercise callouts stay where they are.

local answers = {}

-- A callout's .content is a Blocks list when it holds several blocks and a
-- bare Block when it holds one; normalize to a deep-copied Blocks list.
local function content_blocks(c)
  local ty = pandoc.utils.type(c)
  if ty == "Blocks" then
    return c:walk({})
  elseif ty == "Block" then
    return pandoc.Blocks({ c:walk({}) })
  else
    return pandoc.Blocks({})
  end
end

function Callout(node)
  local title = node.title and pandoc.utils.stringify(node.title) or ""
  if title:match("^Answer") then
    local num = title:match("Answer%s+(%S+)") or title
    table.insert(answers, { title   = title,
                            chapter = num:match("^(%d+)") or "?",
                            blocks  = content_blocks(node.content) })
    return {}  -- remove the callout from its place in the chapter
  end
end

function Pandoc(doc)
  if #answers == 0 then
    return doc
  end

  -- Build the appendix.
  local app = pandoc.List()
  app:insert(pandoc.Header(1, pandoc.Inlines("Answers to the exercises"),
                           pandoc.Attr("sec-answers", { "unnumbered" })))
  local current = nil
  for _, a in ipairs(answers) do
    if a.chapter ~= current then
      current = a.chapter
      app:insert(pandoc.Header(2, pandoc.Inlines("Chapter " .. current),
                               pandoc.Attr("", { "unnumbered" })))
    end
    app:insert(pandoc.Para(pandoc.Inlines{ pandoc.Strong(pandoc.Inlines(a.title .. ".")) }))
    for _, blk in ipairs(a.blocks) do
      app:insert(blk)
    end
  end

  -- Insert before the "References" chapter header if present, else append.
  local body = doc.blocks
  local ref_idx = nil
  for i, b in ipairs(body) do
    if b.t == "Header" and b.level == 1
       and pandoc.utils.stringify(b.content) == "References" then
      ref_idx = i
      break
    end
  end

  local final = pandoc.List()
  if ref_idx then
    for i = 1, ref_idx - 1 do final:insert(body[i]) end
    final:extend(app)
    for i = ref_idx, #body do final:insert(body[i]) end
  else
    final = pandoc.List(body)
    final:extend(app)
  end

  doc.blocks = final
  return doc
end
