assert = require('chai').assert
Promise = require 'bluebird'
collector = require '../lib/dom-collector'

Fixture = {}

describe 'dom-collector', ->
  describe 'logger', ->
    it 'should be configured', (done) ->
      collector.log = console.log
      done()

  describe 'collector', ->
    it 'should be return array', (done) ->
      rule =
        url: 'https://gist.githubusercontent.com/eces/f8d377992a12f64dc353/raw/a6d40f27dcf0e78891333048f4bc87f595574f99/test-01.html'
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
        expected = [ 
          { label: 'aaa', src: 1 }
          { label: 'bbb', src: 2 }
          { label: 'default', src: 3 }
        ]

        assert.property result, 'items'
        assert.isArray result.items
        assert.deepEqual result.items, expected
        
        done()