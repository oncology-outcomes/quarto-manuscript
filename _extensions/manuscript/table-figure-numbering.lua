local utils = require 'pandoc.utils'
local stringify = utils.stringify
local log = quarto.log.output

fig_num = 0
tab_num = 0

return {
  {
    Image = function(fig)
      local title = fig.title
      if string.match(title, '^fig:') then
        fig_num = fig_num + 1
        if (fig.caption) ~= nil then
          cap = stringify(fig.caption)
          cap = pandoc.List:new{
            pandoc.Strong(pandoc.Str('Figure ' .. fig_num .. '. ')),
            pandoc.Str(cap)
          }
        end
        return pandoc.Image(pandoc.Span(cap), fig.src, fig.title, fig.attr)
      end
    end
  },
  {
    Table = function(tab)
      if tab.caption.long == nil then
        return tab
      end
      local cap = stringify(tab.caption.long)
      tab_num = tab_num + 1
      cap = pandoc.List:new{
        pandoc.Strong(pandoc.Str('Table ' .. tab_num .. '. ')),
        pandoc.Str(cap)
      }
      return pandoc.Table({pandoc.Span(cap)}, tab.colspecs, tab.head, tab.bodies, tab.foot, tab.attr)
    end
  }
}
