dweb - A simple website written in D
=====
dweb is a simple website framework based off the [werc][werc] software.

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

Extract the contents into the location you want to serve webpages from. Create <code>$DWEB\_ROOT/.htaccess</code> and <code>$DWEB\_ROOT/src/config.d</code> by copying the provided sample files. Then edit the following files:

- <code>$DWEB_ROOT/.htaccess</code>: make the paths work for your setup.
- <code>$DWEB_ROOT/src/config.d</code>: change these strings as necessary.
- <code>$DWEB_ROOT/src/web.d</code>: this is the main web code.
- <code>$DWEB_ROOT/pub/</code>: static content goes here.
- <code>$DWEB_ROOT/srv/</code>: directories, markdown webpages etc. go in here.
- <code>$DWEB_ROOT/bin/</code>: custom handlers go here.

Run <code>build</code> in <code>$DWEB_ROOT/src</code> to recompile the website software.

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
