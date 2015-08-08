module.exports.strip_filesize = (value) ->
    if value?.trim().length is 0
      value = 0
    else if value?.indexOf('M') isnt -1
      value = value.replace('M', '') * 1000
    else if not isFinite(+value)
      value = 0
    value

module.exports.strip_comma = (value) ->
  value = value.replace /,/g, ''

module.exports.string = (value, def = '') -> String(value) or def

module.exports.number = (value, def = 0) -> Number(value) or def

module.exports.boolean = (value, def = false) -> Boolean(value) or def

module.exports.trim = (value) -> value?.trim() or ''