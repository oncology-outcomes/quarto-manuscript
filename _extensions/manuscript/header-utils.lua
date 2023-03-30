-- Author: Matt Warkentin <warkentin@lunenfeld.ca>
-- Add pagebreak before or after headers tagged with the `.pagebreak` class

local function pagebreak()
local raw = {
    epub = '<p style="page-break-after: always;"> </p>',
    html = '<div style="page-break-after: always;"></div>',
    latex = '\\newpage{}',
    ooxml = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>',
    odt = '<text:p text:style-name="Pagebreak"/>',
    context = '\\page'
}

if quarto.doc.isFormat('docx') then
    return pandoc.RawBlock('openxml', raw.ooxml)
elseif quarto.doc.isFormat('pdf')  then
    return pandoc.RawBlock('tex', raw.latex)
elseif quarto.doc.isFormat('odt')  then
    return pandoc.RawBlock('opendocument', raw.odt)
elseif quarto.doc.isFormat('epub') then
    return pandoc.RawBlock('html', raw.epub)
elseif quarto.doc.isFormat('html') then
    return pandoc.RawBlock('html', raw.html)
elseif quarto.doc.isFormat('context') then
    return pandoc.RawBlock('context', raw.context)
else
    -- fall back to insert a form feed character
    return pandoc.Para{pandoc.Str '\f'}
end
end

function Header(elem)
    if elem.classes then
        for _,cls in ipairs(elem.classes) do
            if cls == 'hide' then
                return pandoc.Null()
            end
        end
    end

    if elem.classes then
        local where = elem.attributes['where']
        for i,cls in ipairs(elem.classes) do
            if cls == 'pagebreak' then
                if where == 'after' then
                    return {elem, pagebreak()}
                else
                    return {pagebreak(), elem}
                end
            end
        end
    end
    return elem
end
