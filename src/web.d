//#!/usr/bin/rdmd
import std.stdio, std.path, std.process, std.file, std.array, std.string, std.algorithm, std.datetime, std.ascii, std.regex;
import config;

string dweb_root;
string[string] template_variables;
string[string] headers;

string write_link(string to, bool expand) {
  bool isdir = dirExists(dweb_root ~ "/srv/" ~ to[url_root.length..$]);
  string flair = nav_tree_chev? (expand? "&raquo; " : "&rsaquo; ") : "";
  string result = "";
  result ~= "<li" ~ (expand? " class=\"thisPage\" " : "") ~ ">";
  result ~= "<a href=\"" ~ to ~ (isdir ? "/" : "") ~ "\">"
        ~ flair ~ baseName(to) ~ (isdir ? "/" : "") ~ "</a>";
  result ~= "</li>";
  return result;
}

string nav_tree_r(string url, string cur_loc, string[] subdirs) {
  string result = "";
  string[] dirs = array(map!"a.name"(dirEntries(dweb_root ~ "/srv/" ~ cur_loc, SpanMode.shallow)));
  sort(dirs);
  if (dirs.length == 0) return "";
  bool inserted_ul = false;
  bool next = false;
  string next_loc;
  foreach(string s; dirs) {
    s= s[(dweb_root ~ "/srv/").length..$];
    string name = stripExtension(baseName(s));
    if (name.length == 0) continue; // e.g. ".md", should we do something else with these files?
    if (name == "index") continue; // "index" will never appear in the nav_tree.
    if (name[0] == '@') continue; // hidden file
    if (!inserted_ul) { result ~= "<ul>"; inserted_ul = true; }
    bool expand = subdirs.length > 0 && name == subdirs[0];
    result ~= write_link(url_root ~ stripExtension(s), expand);

    if (expand && isDir(dweb_root ~ "/srv/" ~ s)) {
      if (nav_tree_vert) {
      	result ~= "<li>";
        result ~= nav_tree_r(url, (cur_loc == "" ? "" : cur_loc ~ "/") ~ subdirs[0], subdirs[1..$]);
        result ~= "</li>";
      } else {
        next = true;
        next_loc = (cur_loc == "" ? "" : cur_loc ~ "/") ~ subdirs[0];
      }
    }
  }

  if (inserted_ul) result ~= "</ul>";
  if (next) result ~= nav_tree_r(url, next_loc, subdirs[1..$]);
  return result;
}

string do_nav_tree(string url) {
  return nav_tree_r(url, "", cast(string[])array(pathSplitter(url)));
}

string not_found(string path) {
  headers["Status"] = "404 Not Found";
  return "The page <code>" ~ path ~ "</code> does not exist. (404)";
}

bool dirExists(string path)  { try { if (isDir(path))  return true; else return false; } catch (Exception e) { return false; } }

string do_content(string url) {
  // first, see if we have something that wants to handle url outright
  foreach (string glob, string h; handlers) {
    if (globMatch(url, glob)) {
      return shell(dweb_root ~ "/bin/" ~ h ~ " " ~ url);
    }
  }
  // if that failed, see if we can handle the file
  if (url == "" ? true : url[$-1] == '/') url ~= "index";
  foreach (f; array(map!"a.name"(dirEntries(dirName(dweb_root ~ "/srv/" ~ url), SpanMode.shallow)))) {
    if (isDir(f)) continue;
    string name = baseName(f); name = name[0] == '@' ? name[1..$] : name;
    if (stripExtension(name) == baseName(url)) {
      foreach (string glob, string h; handlers) { 
        if (globMatch(name, glob)) {
          return shell(dweb_root ~ "/bin/" ~ h ~ " " ~ f);
        }
      }
    }
  }
  if (baseName(url) != "index") return not_found(url);
  return "";
}

bool evil(string s) {
  foreach(char c; s) if (!isAlphaNum(c) && c != '/' && c != '-' && c != '_') return true;
  return false;
}

string simple_template(string text, string[string] vars) {
  return std.regex.replace!((match) { return vars[match[1]]; })(text, regex("\\{\\{\\s*(\\w+)\\s*\\}\\}", "g"));
}

void send_headers() {
  foreach (header, header_body; headers) {
    writefln("%s: %s", header, header_body);
  }
  writeln();
}

void main(string[] args) {
  init_handlers();
  dweb_root = getcwd()[0..$-4]; // take out bin/
  headers["Content-Type"] = "text/html; charset=UTF-8";

  string url = getenv("REQUEST_URI")[url_root.length..$];
  if (evil(url)) {
    headers["Status"] = "400 Bad Request";
    send_headers();
    writeln("bad url.");
    return;
  }
  
  string pagename = baseName(url);
  if (pagename.length != 0) pagename = " - " ~ pagename;
  pagename = site_title ~ pagename;
  template_variables["url_root"] = url_root;
  template_variables["site_title"] = site_title;
  template_variables["site_subtitle"] = site_subtitle;
  template_variables["pagename"] = pagename;
  template_variables["nav_tree"] = do_nav_tree(url);
  template_variables["content"] = do_content(url);

  send_headers();
  string default_template = readText(dweb_root ~ "/templates/default.html");
  write(simple_template(default_template, template_variables));
}
