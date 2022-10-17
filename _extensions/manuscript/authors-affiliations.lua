local List = require 'pandoc.List'
local utils = require 'pandoc.utils'
local stringify = utils.stringify
local byAuthor
local byAffiliation
local Authors = {}
local Affiliations = {}

local authorHoriz

local Corresponding = nil
local function make_correspondance(name, email)
  correspondance = List:new({
    pandoc.Str('* Corresponding Author: '),
    pandoc.Str(name),
    pandoc.Str(' ('),
    pandoc.Link(email, 'mailto:' .. email),
    pandoc.Str(')')
  })
  Corresponding = List:new({ pandoc.Span(correspondance) })
end

local equalCont = nil
local function make_equal_contributor()
  eq_statement = pandoc.Str('† These authors contributed equally to this work.')
  equalCont = List:new({ pandoc.Span(eq_statement) })
end

local function create_author_list(byAuthor)
  local authors = {}
  for i, author in ipairs(byAuthor) do
    local sups = {}

    for j, aff in ipairs(author.affiliations) do
      table.insert(sups, aff.number)
    end
    sups_str = table.concat(sups, ',')

    local name = stringify(author.name.literal)

    if author.attributes ~= nil then
      if author.attributes.equal ~= nil and author.attributes.equal then
        sups_str = sups_str .. ',†'
        make_equal_contributor()
      end
      if author.attributes.corresponding ~= nil and author.attributes.corresponding then
        local email = stringify(author.email)
        sups_str = sups_str .. ',*'
        make_correspondance(name, email)
      end
    end

    local authorEntry = List:new({
      pandoc.Str(name),
      pandoc.Superscript(pandoc.Str(sups_str))
    })

    if authorHoriz and i < #byAuthor then
      authorEntry:extend({ pandoc.Str(', ') })
    end

    table.insert(authors, pandoc.Span(authorEntry))
  end

  if authorHoriz then
    Authors = { pandoc.Para(authors) }
  else
    Authors = authors
  end
end

local function create_affiliation_list(byAffiliation)
  for i, aff in ipairs(byAffiliation) do
    local full_aff = pandoc.List({})

    if aff.name then
      full_aff:insert(stringify(aff.name))
    end

    if aff.address then
      full_aff:insert(stringify(aff.address))
    end

    if aff.city then
      full_aff:insert(stringify(aff.city))
    end

    if aff.region then
      full_aff:insert(stringify(aff.region))
    end

    if aff.postal then
      full_aff:insert(stringify(aff.postal))
    end

    if aff.country then
      full_aff:insert(stringify(aff.country))
    end    
    
    local entry = table.concat(full_aff, ', ')
    
    entry = aff.number .. '. ' .. entry
    table.insert(Affiliations, pandoc.Span(pandoc.Str(entry)))
  end
end

local function remove_author_meta(meta)
  meta.author = nil
  meta.authors = nil
  meta.affiliations = nil
  meta['by-author'] = nil
  meta['by-affiliation'] = nil
  return meta
end

return {
  {
    Meta = function(meta)
      byAuthor = meta['by-author']
      byAffiliation = meta['by-affiliation']
      if meta['author-horizontal'] ~= nil then
        authorHoriz = meta['author-horizontal']
      else
        authorHoriz = false
      end
      create_author_list(byAuthor)
      create_affiliation_list(byAffiliation)
      return meta
    end,
    Pandoc = function(doc)
      local meta = doc.meta
      local body = List:new({})
      body:extend(Authors)
      body:extend(Affiliations)
      if equalCont ~= nil then
        body:extend(equalCont)
      end
      if Corresponding ~= nil then
        body:extend(Corresponding)
      end
      body:extend(doc.blocks)
      meta = remove_author_meta(meta)
      return pandoc.Pandoc(body, meta)
    end
  }
}
