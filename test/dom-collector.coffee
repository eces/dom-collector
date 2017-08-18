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
    it 'should return array', (done) ->
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
    it 'should return next element', (done) ->
      rule =
        url: 'https://gist.githubusercontent.com/eces/f8d377992a12f64dc353/raw/a6ec9951dc78ae9921d86acb87820433e83d8afe/test-02.html'
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
            _value: (e) -> e.next()
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
          { label: '1', src: 1 }
          { label: '2', src: 2 }
          { label: '3', src: 3 }
        ]

        assert.property result, 'items'
        assert.isArray result.items
        assert.deepEqual result.items, expected
        
        done()

    it 'should accept function filter', (done) ->
      rule =
        url: 'https://gist.githubusercontent.com/eces/f8d377992a12f64dc353/raw/a6ec9951dc78ae9921d86acb87820433e83d8afe/test-02.html'
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
            # filter: (v) -> v.trim().replace 'a', 'b'
            filter: (v) -> '(' + String(v).trim() + ')'
            default: 'default'
          }
        ]
      
      task = collector.fetch_json rule
      task.then (result) ->
        expected = [ 
          { label: '(aaa)' }
          { label: '(bbb)' }
          { label: '(default)' }
        ]

        assert.property result, 'items'
        assert.isArray result.items
        assert.deepEqual result.items, expected
        
        done()