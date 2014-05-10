parseURL = require('url').parse
routes = 
	get: []
	post: []
	head: []
	put: []
	delete: []
exports.map = (dict) ->
	if dict? and dict.url? and dict.controller?
		method = if dict.method? then dict.method.toLowerCase() else 'get'
		routes[method].push {
			u: dict.url
			c: dict.controller
			a: dict.action or 'index'		
		}
	return
exports.getActionInfo = (url, method) ->
	r = 
		controller: null
		action: null
		args: null
	method = if method? then method.toLowerCase() else 'get'
	pathname = parseURL(url).pathname
	m_routes = routes[method]
	for m_route in m_routes
		r.args = m_route.u.exec pathname
		if r.args?
			r.controller = m_route.c
			r.action = m_route.a
			r.args.shift()
			break
	return r

	
