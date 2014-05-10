require './refLibs/shotenjin'
http = require 'http'
url = require 'url'
path = require 'path'
fs = require 'fs'
query = require 'querystring'
config = require './config'
route = require './route'

exports.runServer = (port) ->
	port = port or 80
	server = http.createServer (req, res) -> 
		_postData = ''
		req.on 'data', (chunk) ->
			_postData += chunk
			return
		.on 'end', ->
			req.post = query.parse _postData
			handlerRequest req, res
			console.log "Request for #{req.url} received."
			return
		return
	.listen port, '127.0.0.1'
	console.log "CoffeeMVC Server running at http://127.0.0.1:#{port}/"
	return

handlerRequest = (req, res) ->
	actionInfo = route.getActionInfo req.url, req.method
	if actionInfo.action?
		controller = require "./controllers/#{actionInfo.controller}"
		if controller[actionInfo.action]?
			ct = new ControllerContext req, res
			controller[actionInfo.action].apply ct, actionInfo.args
			return
		else
			handler500 req, res, "Error: controller: #{actionInfo.controller} without action #{actionInfo.action}"
			return
	else
		staticFileServer req, res
		return

class ControllerContext
	constructor: (@req, @res) ->
		@handler404 = handler404
		@handler500 = handler500
		return
	render: (viewName, context) ->
		viewEngine.render @req, @res, viewName, context
		return
	renderJson: (json) ->
		viewEngine.renderJson @res, json
		return


handler404 = (req, res) ->
	res.writeHead 404, {'Content-Type': 'text/plain'}
	res.end 'Page Not Found'
	return
handler500 = (req, res, err) ->
	res.writeHead 500, {'Content-Type': 'text/plain'}
	res.end err.toString()
	return
viewEngine = 
	render: (req, res, viewName, context) ->
		filename = path.join __dirname, 'views', viewName
		try
			output = Shotenjin.renderView filename, context
		catch err
			handler500 req, res, err
			return
		res.writeHead 200, {'Content-Type': 'text/html'}
		res.end output
		return
	renderJson: (res, json) ->
		res.writeHead 200, {'Content-Type': 'application/json'}
		console.log JSON.stringify json 
		res.end JSON.stringify json 
		return
staticFileServer = (req, res, filePath) ->
	filePath = path.join __dirname, config.staticFileDir, url.parse(req.url).pathname unless filePath?
	fs.exists filePath, (exists) ->
		if not exists?
			handler404 req, res
			return
		fs.readFile filePath, 'binary' , (err, file) ->
			if err?
				handler500 req, res ,err
				return
			ext = path.extname filePath
			ext = if ext? then ext.slice 1 else 'html'
			res.writeHead 200, {'Content-Type': contentTypes[ext] or 'text/html'}
			res.write file, "binary"
			res.end()
			return
		return
	return
	
contentTypes = 
	"aiff": "audio/x-aiff"
	"arj": "application/x-arj-compressed"
	"asf": "video/x-ms-asf"
	"asx": "video/x-ms-asx"
	"au": "audio/ulaw"
	"avi": "video/x-msvideo"
	"bcpio": "application/x-bcpio"
	"ccad": "application/clariscad"
	"cod": "application/vnd.rim.cod"
	"com": "application/x-msdos-program"
	"cpio": "application/x-cpio"
	"cpt": "application/mac-compactpro"
	"csh": "application/x-csh"
	"css": "text/css"
	"deb": "application/x-debian-package"
	"dl": "video/dl"
	"doc": "application/msword"
	"drw": "application/drafting"
	"dvi": "application/x-dvi"
	"dwg": "application/acad"
	"dxf": "application/dxf"
	"dxr": "application/x-director"
	"etx": "text/x-setext"
	"ez": "application/andrew-inset"
	"fli": "video/x-fli"
	"flv": "video/x-flv"
	"gif": "image/gif"
	"gl": "video/gl"
	"gtar": "application/x-gtar"
	"gz": "application/x-gzip"
	"hdf": "application/x-hdf"
	"hqx": "application/mac-binhex40"
	"html": "text/html",
	"ice": "x-conference/x-cooltalk"
	"ief": "image/ief"
	"igs": "model/iges"
	"ips": "application/x-ipscript"
	"ipx": "application/x-ipix"
	"jad": "text/vnd.sun.j2me.app-descriptor"
	"jar": "application/java-archive"
	"jpeg": "image/jpeg"
	"jpg": "image/jpeg"
	"js": "text/javascript"
	"json": "application/json"
	"latex": "application/x-latex"
	"lsp": "application/x-lisp"
	"lzh": "application/octet-stream"
	"m": "text/plain"
	"m3u": "audio/x-mpegurl"
	"man": "application/x-troff-man"
	"me": "application/x-troff-me"
	"midi": "audio/midi"
	"mif": "application/x-mif"
	"mime": "www/mime"
	"movie": "video/x-sgi-movie"
	"mp4": "video/mp4"
	"mpg": "video/mpeg"
	"mpga": "audio/mpeg"
	"ms": "application/x-troff-ms"
	"nc": "application/x-netcdf"
	"oda": "application/oda"
	"ogm": "application/ogg"
	"pbm": "image/x-portable-bitmap"
	"pdf": "application/pdf"
	"pgm": "image/x-portable-graymap"
	"pgn": "application/x-chess-pgn"
	"pgp": "application/pgp"
	"pm": "application/x-perl"
	"png": "image/png"
	"pnm": "image/x-portable-anymap"
	"ppm": "image/x-portable-pixmap"
	"ppz": "application/vnd.ms-powerpoint"
	"pre": "application/x-freelance"
	"prt": "application/pro_eng"
	"ps": "application/postscript"
	"qt": "video/quicktime"
	"ra": "audio/x-realaudio"
	"rar": "application/x-rar-compressed"
	"ras": "image/x-cmu-raster"
	"rgb": "image/x-rgb"
	"rm": "audio/x-pn-realaudio"
	"rpm": "audio/x-pn-realaudio-plugin"
	"rtf": "text/rtf"
	"rtx": "text/richtext"
	"scm": "application/x-lotusscreencam"
	"set": "application/set"
	"sgml": "text/sgml"
	"sh": "application/x-sh"
	"shar": "application/x-shar"
	"silo": "model/mesh"
	"sit": "application/x-stuffit"
	"skt": "application/x-koan"
	"smil": "application/smil"
	"snd": "audio/basic"
	"sol": "application/solids"
	"spl": "application/x-futuresplash"
	"src": "application/x-wais-source"
	"stl": "application/SLA"
	"stp": "application/STEP"
	"sv4cpio": "application/x-sv4cpio"
	"sv4crc": "application/x-sv4crc"
	"svg": "image/svg+xml"
	"swf": "application/x-shockwave-flash"
	"tar": "application/x-tar"
	"tcl": "application/x-tcl"
	"tex": "application/x-tex"
	"texinfo": "application/x-texinfo"
	"tgz": "application/x-tar-gz"
	"tiff": "image/tiff"
	"tr": "application/x-troff"
	"tsi": "audio/TSP-audio"
	"tsp": "application/dsptype"
	"tsv": "text/tab-separated-values"
	"txt": "text/plain"
	"unv": "application/i-deas"
	"ustar": "application/x-ustar"
	"vcd": "application/x-cdlink"
	"vda": "application/vda"
	"vivo": "video/vnd.vivo"
	"vrm": "x-world/x-vrml"
	"wav": "audio/x-wav"
	"wax": "audio/x-ms-wax"
	"wma": "audio/x-ms-wma"
	"wmv": "video/x-ms-wmv"
	"wmx": "video/x-ms-wmx"
	"wrl": "model/vrml"
	"wvx": "video/x-ms-wvx"
	"xbm": "image/x-xbitmap"
	"xlw": "application/vnd.ms-excel"
	"xml": "text/xml"
	"xpm": "image/x-xpixmap"
	"xwd": "image/x-xwindowdump"
	"xyz": "chemical/x-pdb"
	"zip": "application/zip"