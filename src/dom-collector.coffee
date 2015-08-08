Promise = require 'bluebird'
request = require 'request'
cheerio = require 'cheerio'
_ = require 'lodash'
iconv = require('iconv').Iconv

filters = require './filter'

# promisify
Promise.promisifyAll require('request')

# export logger
module.exports.log = log = -> true

# add debug logger
if process.env.NODE_ENV is 'test'
  module.exports.log = log = console.log

filter_value = (filter, value) ->
  # multiple filter given
  if filter.indexOf(' ') isnt -1
    list = filter.split ' '
    for item in list
      if item is 'undefined'
        continue
      value = filter_value item, value
    return value

  unless filter
    return value
  if Object.keys(filters).indexOf(filter) isnt -1
    value = filters[filter] value
  else
    throw new StatusError 400, 'filter not found: ' + filter
    return value

match_value = (type, $selector, value, condition) ->
  if type is 'boolean'
    return $selector.is condition
  
  result = value.match new RegExp(condition)
  if result is null
    log 'given: ', value
    log 'RegExp: ', condition
    ''
  else
    result[1]

find_value = ($, selector, parent = '', self = false) ->
  # if _.endsWith selector.key, '[]'
  if selector.type is 'array'
    # just for internal reference
    selector.value + ' '
  else
    attribute_name = ''
    
    if _.startsWith(selector.value, '[') and _.endsWith(selector.value, ']')
      attribute_name = selector.value.slice 1, -1
    
    if self
      $selector = $ 
    else
      if attribute_name
        $selector = $(parent)
      else
        $selector = $(parent + selector.value)
    if $selector.length is 0
      return selector.default
    else if $selector.length is 1
      # single elem
      if attribute_name
        # [attr]
        value = $selector.attr(attribute_name) or $selector.data(attribute_name)
      else
        value = $selector.text() or $selector.val()

      value = match_value selector.type, $selector, value, selector.match if selector.match
      value = filter_value (selector.filter + ' ' + selector.type), value, selector.default
      value
    else 
      # elem list
      items = []
      $selector.map (i, e) -> 
        items.push find_value $(e), selector, '', true
      items

fetch_json = (rules) ->
  # replace params
  if rules.params and _.isArray(rules.params)
    for param in rules.params
      if param.value
        rules.url = rules.url.replace new RegExp("\{#{param.key}\}"), param.value

  log rules.url
  
  request.getAsync
    url: rules.url
    rejectUnauthorized: false
    timeout: rules.timeout
    headers: rules.headers
    encoding: null
  .spread (response, body) ->
    if rules.encoding is 'euc-kr'
      body = new iconv('EUC-KR', 'UTF-8').convert(body)

    $ = cheerio.load body

    result = {}

    # find values
    for selector in rules.selector
      if not _.endsWith(selector.key, '[]') and selector.key.indexOf('[]') isnt -1
        parent = result[selector.key.split('[]')[0] + '[]']
        if parent
          result[selector.key] = find_value $, selector, parent
        else
          throw new StatusError 400, 'parent not found: ' + selector.key.split('[]')[0] + '[]'
          log result
      else
        result[selector.key] = find_value $, selector

    # selector_keys = _.pluck selector, 'key'
    log result

    # group keys to array
    for key in Object.keys result
      if _.endsWith(key, '[]')
        delete result[key]
        continue

      if key.indexOf('[]') isnt -1
        # the key should be grouped
        keys = key.split('[]')
        group_key = keys[0]
        result[group_key] = [] if result[group_key] is undefined
        current_selector = _.findIndex rules.selector, 'key', key
        unless _.isArray result[key]
          # wrap 'string' to ['array']
          result[key] = [result[key]]
        for value, i in result[key]
          result[group_key][i] = {} if result[group_key][i] is undefined
          result[group_key][i][keys[1].slice(1)] = value
        delete result[key]
      else if key.indexOf('.') isnt -1
        keys = key.split '.'
        result[keys[0]] = {} if result[keys[0]] is undefined
        result[keys[0]][keys[1]] = result[key]
        delete result[key]
    return result

module.exports.fetch_json = fetch_json