var Promise, _, cheerio, fetch_json, filter_value, filters, find_value, iconv, log, match_value, request;

Promise = require('bluebird');

request = require('request');

cheerio = require('cheerio');

_ = require('lodash');

iconv = require('iconv').Iconv;

filters = require('./filter');

Promise.promisifyAll(require('request'));

module.exports.log = log = function() {
  return true;
};

if (process.env.NODE_ENV === 'test-verbose') {
  module.exports.log = log = console.log;
}

filter_value = function(filter, value) {
  var item, j, len, list;
  if (filter.indexOf(' ') !== -1) {
    list = filter.split(' ');
    for (j = 0, len = list.length; j < len; j++) {
      item = list[j];
      if (item === 'undefined') {
        continue;
      }
      value = filter_value(item, value);
    }
    return value;
  }
  if (!filter) {
    return value;
  }
  if (Object.keys(filters).indexOf(filter) !== -1) {
    return value = filters[filter](value);
  } else {
    throw new Error('filter not found: ' + filter);
    return value;
  }
};

match_value = function(type, $selector, value, condition) {
  var result;
  if (type === 'boolean') {
    return $selector.is(condition);
  }
  result = value.match(new RegExp(condition));
  if (result === null) {
    log('given: ', value);
    log('RegExp: ', condition);
    return '';
  } else {
    return result[1];
  }
};

find_value = function($, selector, parent, self) {
  var $selector, attribute_name, items, value;
  if (parent == null) {
    parent = '';
  }
  if (self == null) {
    self = false;
  }
  if (selector.type === 'array') {
    return selector.value + ' ';
  } else {
    attribute_name = '';
    if (_.startsWith(selector.value, '[') && _.endsWith(selector.value, ']')) {
      attribute_name = selector.value.slice(1, -1);
    }
    if (self) {
      $selector = $;
    } else {
      if (attribute_name) {
        $selector = $(parent);
      } else {
        $selector = $(parent + selector.value);
      }
    }
    if ($selector.length === 0) {
      return selector["default"];
    } else if ($selector.length === 1) {
      if (_.isFunction(selector._value)) {
        $selector = selector._value($selector);
      }
      if (attribute_name) {
        value = $selector.attr(attribute_name) || $selector.data(attribute_name);
      } else {
        value = $selector.text() || $selector.val();
      }
      if (selector.match) {
        value = match_value(selector.type, $selector, value, selector.match);
      }
      value = filter_value(selector.filter + ' ' + selector.type, value, selector["default"]);
      if ((!value) || value.length === 0) {
        value = selector["default"];
      }
      return value;
    } else {
      items = [];
      $selector.map(function(i, e) {
        return items.push(find_value($(e), selector, '', true));
      });
      return items;
    }
  }
};

fetch_json = function(rules) {
  var j, len, param, ref;
  if (rules.params && _.isArray(rules.params)) {
    ref = rules.params;
    for (j = 0, len = ref.length; j < len; j++) {
      param = ref[j];
      if (param.value) {
        rules.url = rules.url.replace(new RegExp("\{" + param.key + "\}"), param.value);
      }
    }
  }
  log(rules.url);
  if (rules.encoding == null) {
    rules.encoding = 'utf-8';
  }
  return request.getAsync({
    url: rules.url,
    rejectUnauthorized: false,
    timeout: rules.timeout,
    headers: rules.headers,
    encoding: null
  }).spread(function(response, body) {
    var $, current_selector, group_key, i, k, key, keys, l, len1, len2, len3, m, parent, ref1, ref2, ref3, result, selector, value;
    if (rules.encoding === 'euc-kr') {
      body = new iconv('EUC-KR', 'UTF-8').convert(body);
    }
    log(body.toString());
    $ = cheerio.load(body);
    result = {};
    ref1 = rules.selector;
    for (k = 0, len1 = ref1.length; k < len1; k++) {
      selector = ref1[k];
      if (!_.endsWith(selector.key, '[]') && selector.key.indexOf('[]') !== -1) {
        parent = result[selector.key.split('[]')[0] + '[]'];
        if (parent) {
          result[selector.key] = find_value($, selector, parent);
        } else {
          throw new Error('parent not found: ' + selector.key.split('[]')[0] + '[]');
          log(result);
        }
      } else {
        result[selector.key] = find_value($, selector);
      }
    }
    log(result);
    ref2 = Object.keys(result);
    for (l = 0, len2 = ref2.length; l < len2; l++) {
      key = ref2[l];
      if (_.endsWith(key, '[]')) {
        delete result[key];
        continue;
      }
      if (key.indexOf('[]') !== -1) {
        keys = key.split('[]');
        group_key = keys[0];
        if (result[group_key] === void 0) {
          result[group_key] = [];
        }
        current_selector = _.findIndex(rules.selector, 'key', key);
        if (!_.isArray(result[key])) {
          result[key] = [result[key]];
        }
        ref3 = result[key];
        for (i = m = 0, len3 = ref3.length; m < len3; i = ++m) {
          value = ref3[i];
          if (result[group_key][i] === void 0) {
            result[group_key][i] = {};
          }
          result[group_key][i][keys[1].slice(1)] = value;
        }
        delete result[key];
      } else if (key.indexOf('.') !== -1) {
        keys = key.split('.');
        if (result[keys[0]] === void 0) {
          result[keys[0]] = {};
        }
        result[keys[0]][keys[1]] = result[key];
        delete result[key];
      }
    }
    return result;
  });
};

module.exports.fetch_json = fetch_json;
