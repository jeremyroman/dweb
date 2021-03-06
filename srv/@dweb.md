dweb - A simple website written in D
=====
dweb is a simple website framework inspired by the [werc][werc] software.

Its principles are:

- Database free, uses files and directories instead.
- Written using the D programming language.
- Minimize tedious work: eg., no need to ever write HTML, use markdown instead.
- Very minimalist yet extensible codebase. Handlers for special things should be easy to add.

It was created because werc was annoying to deploy on UW Computer Science Club's Apache setup and because [Not Invented Here](http://en.wikipedia.org/wiki/Not_Invented_Here).

[werc]:http://werc.cat-v.org/
[md]:http://daringfireball.net/projects/markdown

Install Guide
------
You will need:
- An HTTP server with CGI support.
- The D compiler.

Extract the contents into the location you want to serve webpages from. Edit the following files:

- `$DWEB_ROOT/.htaccess`: make the rewrite path work for your setup.
- `$DWEB_ROOT/src/config.d`: change these things as desired. Custom handlers are added in init_handlers. The key is the glob to activate the handler, and the value is the `bin/` relative path of the handler.
- `$DWEB_ROOT/src/web.d`: this is the core code.
- `$DWEB_ROOT/pub/`: static content goes here.
- `$DWEB_ROOT/srv/`: directories, markdown webpages etc. go in here.
- `$DWEB_ROOT/bin/`: custom handlers go here.

Run `./build` in `$DWEB_ROOT/src` to recompile the website software.

Source
--------

You can get the source code on [github](https://github.com/j3parker/dweb) or by running

     git clone git://github.com/j3parker/dweb.git

Contact
--------
For questions, suggestions, bug reports and contributing patches email [j3parker](mailto:j3parker@csclub.uwaterloo.ca)

License
-------
Public domain.

Credits
-------
The idea and css stolen from [werc][werc]. This page itself also plagarised.

Thanks to John Gruber for the [Markdown.pl][md] script.
