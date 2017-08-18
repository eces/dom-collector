# DOM Collector

[![npm version](https://badge.fury.io/js/dom-collector.svg)](http://badge.fury.io/js/dom-collector)

It simply transforms a given url into key-value organized JSON with specification.


### Install

`npm install --save dom-collector`

### Features

Under the hood, it does ...

- Validate rule specification you passed.

- Load web page with well-known library [request](https://github.com/request/request)

- Parse and fetch elements with proved dom selector [cheerio](https://github.com/cheeriojs/cheerio); it might be better than jsdom.

- Filter values and fill the default value configured.

- Replace collected values into JSON Object, also iterative elements will be into JSON Array.

- Return a thenable [Promise](https://github.com/petkaantonov/bluebird) function to be resolved asynchronously.

### Example

For this html body

```html
<ul id="content-list">
  <li data-id="1">
    <a href="#"> aaa </a>
  </li>
  <li data-id="2">
    <a href="#"> bbb </a>
  </li>
  <li data-id="3">
    <a href="#"></a>
  </li>
</ul>
```

Add a rule below

```coffee
collector = require 'dom-collector'

rule =
  url: 'https://gist.githubusercontent.com/eces/f8d377992a12f64dc353/raw/75fd1607925e12bb82fdc7890514a3899781531d/test-01.html'
  timeout: 15000
  encoding: 'utf8'
  params: []
  headers: 
    'User-Agent': 'Mozilla/5.0(iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B314 Safari/531.21.10'
  selector: [
    {
      key: 'items[]'
      value: '#content-list li'
      type: 'array'
      default: []
    }
    {
      key: 'items[].label'
      value: 'a'
      type: 'string'
      filter: 'trim'
      default: 'default'
    }
    {
      key: 'items[].src'
      value: '[data-id]'
      type: 'number'
    }
  ]

task = collector.fetch_json rule
task.then (result) ->
  console.log result
```

Then, it brings the result

```json
{
  "items": [ 
    { "label": "aaa", "src": 1 }
    { "label": "bbb", "src": 2 }
    { "label": "default", "src": 3 }
  ]
}
```

### Functions

#### `fetch_json(rule: Object)`

> ```
> require('dom-collector').fetch_json(rule);
> ```

### Rule(selector) specification

#### Value

This is DOM selector to find values for key. It supports querySelector and jQuery selector like. When you are supposed to do `$('#content')` then this value should be `#content`.

#### Key

This key will be exposed and created into result JSON. If key has `[]` array notation, it becomes a parent key and every keys ending with `parent[]` become children of the parent. If parent key has no entry, children may not resolved from empty array.

#### Type

`string`, `number`, `boolean`

Please note that the default value will be set if failed type-casting.

#### Default

This default value will be replaced into value if no element is found, and also

  - when type is `string` and string length is zero.
  - when type is `number` and falsy with `isFinite`; NaN, Infinity, undefined.

#### Match

This regular expression will be evaluated and return the first value.

`100` can be found from `<li onclick="contentView(100, 3);"></li>` with below matcher:

```coffee
match: "contentView\\(([0-9]+)\\,"
```


#### Filter

Reference: eces/dom-collector/src/filter.coffee

##### strip_filesize

`70.5M` to `70500`
 
##### strip_comma

`1,000,000` to `1000000`

##### trim

`"\r\n hello. "` to `"hello."`

##### string

`value` to `String(value)`

##### number

`value` to `Number(value)`

##### boolean

`value` to `Boolean(value)`

##### Using custom function

The value is directly transformed by given function that is capable of any value also including `null`, `undefined`.

```
filter: (v) -> '(' + String(v).trim() + ')'
```

Please be aware of unintended boolean conversion from this reading [MDN - Boolean](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Boolean).

> The value passed as the first parameter is converted to a boolean value, if necessary. If value is omitted or is 0, -0, null, false, NaN, undefined, or the empty string (""), the object has an initial value of false. All other values, including any object or the string "false", create an object with an initial value of true.

> Do not confuse the primitive Boolean values true and false with the true and false values of the Boolean object.

> Any object whose value is not undefined or null, including a Boolean object whose value is false, evaluates to true when passed to a conditional statement.

### Development

`grunt build`
`grunt test`

### Contribution

Welcome


### License

Under MIT License.