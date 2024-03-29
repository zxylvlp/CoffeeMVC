// Generated by CoffeeScript 1.7.1
(function() {
  var ControllerContext, config, contentTypes, fs, handler404, handler500, handlerRequest, http, path, query, route, staticFileServer, url, viewEngine;

  require('./refLibs/shotenjin');

  http = require('http');

  url = require('url');

  path = require('path');

  fs = require('fs');

  query = require('querystring');

  config = require('./config');

  route = require('./route');

  exports.runServer = function(port) {
    var server;
    port = port || 80;
    server = http.createServer(function(req, res) {
      var _postData;
      _postData = '';
      req.on('data', function(chunk) {
        _postData += chunk;
      }).on('end', function() {
        req.post = query.parse(_postData);
        handlerRequest(req, res);
        console.log("Request for " + req.url + " received.");
      });
    }).listen(port, '127.0.0.1');
    console.log("CoffeeMVC Server running at http://127.0.0.1:" + port + "/");
  };

  handlerRequest = function(req, res) {
    var actionInfo, controller, ct;
    actionInfo = route.getActionInfo(req.url, req.method);
    if (actionInfo.action != null) {
      controller = require("./controllers/" + actionInfo.controller);
      if (controller[actionInfo.action] != null) {
        ct = new ControllerContext(req, res);
        controller[actionInfo.action].apply(ct, actionInfo.args);
      } else {
        handler500(req, res, "Error: controller: " + actionInfo.controller + " without action " + actionInfo.action);
      }
    } else {
      staticFileServer(req, res);
    }
  };

  ControllerContext = (function() {
    function ControllerContext(req, res) {
      this.req = req;
      this.res = res;
      this.handler404 = handler404;
      this.handler500 = handler500;
      return;
    }

    ControllerContext.prototype.render = function(viewName, context) {
      viewEngine.render(this.req, this.res, viewName, context);
    };

    ControllerContext.prototype.renderJson = function(json) {
      viewEngine.renderJson(this.res, json);
    };

    return ControllerContext;

  })();

  handler404 = function(req, res) {
    res.writeHead(404, {
      'Content-Type': 'text/plain'
    });
    res.end('Page Not Found');
  };

  handler500 = function(req, res, err) {
    res.writeHead(500, {
      'Content-Type': 'text/plain'
    });
    res.end(err.toString());
  };

  viewEngine = {
    render: function(req, res, viewName, context) {
      var err, filename, output;
      filename = path.join(__dirname, 'views', viewName);
      try {
        output = Shotenjin.renderView(filename, context);
      } catch (_error) {
        err = _error;
        handler500(req, res, err);
        return;
      }
      res.writeHead(200, {
        'Content-Type': 'text/html'
      });
      res.end(output);
    },
    renderJson: function(res, json) {
      res.writeHead(200, {
        'Content-Type': 'application/json'
      });
      console.log(JSON.stringify(json));
      res.end(JSON.stringify(json));
    }
  };

  staticFileServer = function(req, res, filePath) {
    if (filePath == null) {
      filePath = path.join(__dirname, config.staticFileDir, url.parse(req.url).pathname);
    }
    fs.exists(filePath, function(exists) {
      if (exists == null) {
        handler404(req, res);
        return;
      }
      fs.readFile(filePath, 'binary', function(err, file) {
        var ext;
        if (err != null) {
          handler500(req, res, err);
          return;
        }
        ext = path.extname(filePath);
        ext = ext != null ? ext.slice(1) : 'html';
        res.writeHead(200, {
          'Content-Type': contentTypes[ext] || 'text/html'
        });
        res.write(file, "binary");
        res.end();
      });
    });
  };

  contentTypes = {
    "aiff": "audio/x-aiff",
    "arj": "application/x-arj-compressed",
    "asf": "video/x-ms-asf",
    "asx": "video/x-ms-asx",
    "au": "audio/ulaw",
    "avi": "video/x-msvideo",
    "bcpio": "application/x-bcpio",
    "ccad": "application/clariscad",
    "cod": "application/vnd.rim.cod",
    "com": "application/x-msdos-program",
    "cpio": "application/x-cpio",
    "cpt": "application/mac-compactpro",
    "csh": "application/x-csh",
    "css": "text/css",
    "deb": "application/x-debian-package",
    "dl": "video/dl",
    "doc": "application/msword",
    "drw": "application/drafting",
    "dvi": "application/x-dvi",
    "dwg": "application/acad",
    "dxf": "application/dxf",
    "dxr": "application/x-director",
    "etx": "text/x-setext",
    "ez": "application/andrew-inset",
    "fli": "video/x-fli",
    "flv": "video/x-flv",
    "gif": "image/gif",
    "gl": "video/gl",
    "gtar": "application/x-gtar",
    "gz": "application/x-gzip",
    "hdf": "application/x-hdf",
    "hqx": "application/mac-binhex40",
    "html": "text/html",
    "ice": "x-conference/x-cooltalk",
    "ief": "image/ief",
    "igs": "model/iges",
    "ips": "application/x-ipscript",
    "ipx": "application/x-ipix",
    "jad": "text/vnd.sun.j2me.app-descriptor",
    "jar": "application/java-archive",
    "jpeg": "image/jpeg",
    "jpg": "image/jpeg",
    "js": "text/javascript",
    "json": "application/json",
    "latex": "application/x-latex",
    "lsp": "application/x-lisp",
    "lzh": "application/octet-stream",
    "m": "text/plain",
    "m3u": "audio/x-mpegurl",
    "man": "application/x-troff-man",
    "me": "application/x-troff-me",
    "midi": "audio/midi",
    "mif": "application/x-mif",
    "mime": "www/mime",
    "movie": "video/x-sgi-movie",
    "mp4": "video/mp4",
    "mpg": "video/mpeg",
    "mpga": "audio/mpeg",
    "ms": "application/x-troff-ms",
    "nc": "application/x-netcdf",
    "oda": "application/oda",
    "ogm": "application/ogg",
    "pbm": "image/x-portable-bitmap",
    "pdf": "application/pdf",
    "pgm": "image/x-portable-graymap",
    "pgn": "application/x-chess-pgn",
    "pgp": "application/pgp",
    "pm": "application/x-perl",
    "png": "image/png",
    "pnm": "image/x-portable-anymap",
    "ppm": "image/x-portable-pixmap",
    "ppz": "application/vnd.ms-powerpoint",
    "pre": "application/x-freelance",
    "prt": "application/pro_eng",
    "ps": "application/postscript",
    "qt": "video/quicktime",
    "ra": "audio/x-realaudio",
    "rar": "application/x-rar-compressed",
    "ras": "image/x-cmu-raster",
    "rgb": "image/x-rgb",
    "rm": "audio/x-pn-realaudio",
    "rpm": "audio/x-pn-realaudio-plugin",
    "rtf": "text/rtf",
    "rtx": "text/richtext",
    "scm": "application/x-lotusscreencam",
    "set": "application/set",
    "sgml": "text/sgml",
    "sh": "application/x-sh",
    "shar": "application/x-shar",
    "silo": "model/mesh",
    "sit": "application/x-stuffit",
    "skt": "application/x-koan",
    "smil": "application/smil",
    "snd": "audio/basic",
    "sol": "application/solids",
    "spl": "application/x-futuresplash",
    "src": "application/x-wais-source",
    "stl": "application/SLA",
    "stp": "application/STEP",
    "sv4cpio": "application/x-sv4cpio",
    "sv4crc": "application/x-sv4crc",
    "svg": "image/svg+xml",
    "swf": "application/x-shockwave-flash",
    "tar": "application/x-tar",
    "tcl": "application/x-tcl",
    "tex": "application/x-tex",
    "texinfo": "application/x-texinfo",
    "tgz": "application/x-tar-gz",
    "tiff": "image/tiff",
    "tr": "application/x-troff",
    "tsi": "audio/TSP-audio",
    "tsp": "application/dsptype",
    "tsv": "text/tab-separated-values",
    "txt": "text/plain",
    "unv": "application/i-deas",
    "ustar": "application/x-ustar",
    "vcd": "application/x-cdlink",
    "vda": "application/vda",
    "vivo": "video/vnd.vivo",
    "vrm": "x-world/x-vrml",
    "wav": "audio/x-wav",
    "wax": "audio/x-ms-wax",
    "wma": "audio/x-ms-wma",
    "wmv": "video/x-ms-wmv",
    "wmx": "video/x-ms-wmx",
    "wrl": "model/vrml",
    "wvx": "video/x-ms-wvx",
    "xbm": "image/x-xbitmap",
    "xlw": "application/vnd.ms-excel",
    "xml": "text/xml",
    "xpm": "image/x-xpixmap",
    "xwd": "image/x-xwindowdump",
    "xyz": "chemical/x-pdb",
    "zip": "application/zip"
  };

}).call(this);
