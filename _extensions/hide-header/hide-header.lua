-- Author: Matt Warkentin <warkentin@lunenfeld.ca>
-- Remove headers tagged with the `.hide` class
function Header(elem)
  if elem.classes[1] == 'hide' then
    return pandoc.Null()
  end
  return elem
end
