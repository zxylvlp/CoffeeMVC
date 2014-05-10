route = require './route'
route.map {
	method: 'get'
	url: /^\/hello\/$/i
	controller: 'Index'
	action: 'index'
}
exports.staticFileDir = 'static'
