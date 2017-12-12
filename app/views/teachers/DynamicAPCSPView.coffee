require('app/styles/teachers/markdown-resource-view.sass')
RootView = require 'views/core/RootView'
api = require 'core/api'
ace = require('lib/aceContainer')
aceUtils = require 'core/aceUtils'

module.exports = class DynamicAPCSPView extends RootView
  id: 'dynamic-apcsp-view'
  template: require 'templates/teachers/dynamic-apcsp-view'

  getTitle: -> 'AP CS Principles'

  initialize: (options, @name) ->
    super(options)
    @name ?= 'index'
    @content = ''
    @loadingData = true
    
    if _.string.startsWith(@name, 'markdown/')
      promise = api.markdown.getMarkdownFile(@name.replace('markdown/', ''))
    else
      promise = api.apcsp.getAPCSPFile(@name)
    
    promise.then((data) =>
      @content = marked(data, sanitize: false)
      @loadingData = false
      @render()
    ).catch((error) =>
      @loadingData = false
      if error.code is 404
        @notFound = true
        @render()
      else
        console.error(error)
        @error = error.message
        @render()
      
    )


  afterRender: ->
    super()
    @$el.find('pre>code').each ->
      els = $(@)
      c = els.parent()
      lang = els.attr('class')
      if lang
        lang = lang.replace(/^lang-/,'')
      else
        lang = 'python'

      aceEditor = aceUtils.initializeACE c[0], lang
      aceEditor.setShowInvisibles false
      aceEditor.setBehavioursEnabled false
      aceEditor.setAnimatedScroll false
      aceEditor.$blockScrolling = Infinity
    if _.contains(location.href, '#')
      _.defer =>
        # Remind the browser of the fragment in the URL, so it jumps to the right section.
        location.href = location.href