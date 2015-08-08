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
        url: 'http://embed.plnkr.co/dYaZqlxLtD5DrQX01zZB/preview'
        timeout: 15000
        encoding: 'euc-kr'
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
          # {
          #   key: 'items[].src'
          #   value: 'a[href]'
          #   type: 'string'
          # }
        ]
      
      task = collector.fetch_json rule
      task.then (result) ->
        console.log '>>', result
        done()
      # .then (result) ->

      # assert.isArray result
      # assert.equals
      # collector.log = console.log