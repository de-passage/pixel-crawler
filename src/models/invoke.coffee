invoke = (f, args...) ->
  if typeof t is "function"
    f.apply(this, args)
  #else if typeof t is "undefined"
  else
    f
