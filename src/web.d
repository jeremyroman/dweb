//#!/usr/bin/rdmd
import std.stdio, std.path, std.process, std.file, std.array, std.string, std.algorithm, std.datetime, std.ascii;
import config;

string dweb_root;

string indent = "";
void html(string s) { writeln(indent ~ s); }
void html_pop(string s) { indent = indent[0..max(0, $-4)]; html(s); }
void html_push(string s) { html(s); indent ~= "    "; }

void write_link(string to, bool expand) {
  bool isdir = dirExists(dweb_root ~ "/srv/" ~ to[url_root.length..$]);
  string flair = nav_tree_chev? (expand? "&raquo; " : "&rsaquo; ") : "";
  html_push("<li" ~ (expand? " class=\"thisPage\" " : "") ~ ">");
  html("<a href=\"" ~ to ~ (isdir ? "/" : "") ~ "\">"
        ~ flair ~ baseName(to) ~ (isdir ? "/" : "") ~ "</a>");
  html_pop("</li>");
}

void nav_tree_r(string url, string cur_loc, string[] subdirs) {
  string[] dirs = array(map!"a.name"(dirEntries(dweb_root ~ "/srv/" ~ cur_loc, SpanMode.shallow)));
  sort(dirs);
  if (dirs.length == 0) return;
  bool inserted_ul = false;
  bool next = false;
  string next_loc;
  foreach(string s; dirs) {
    s= s[(dweb_root ~ "/srv/").length..$];
    string name = stripExtension(baseName(s));
    if (name.length == 0) continue; // e.g. ".md", should we do something else with these files?
    if (name == "index") continue; // "index" will never appear in the nav_tree.
    if (name[0] == '@') continue; // hidden file
    if (!inserted_ul) { html_push("<ul>"); inserted_ul = true; }
    bool expand = subdirs.length > 0 && name == subdirs[0];
    write_link(url_root ~ stripExtension(s), expand);

    if (expand && isDir(dweb_root ~ "/srv/" ~ s)) {
      if (nav_tree_vert) {
        html_push("<li>");
        nav_tree_r(url, (cur_loc == "" ? "" : cur_loc ~ "/") ~ subdirs[0], subdirs[1..$]);
        html_pop("</li>");
      } else {
        next = true;
        next_loc = (cur_loc == "" ? "" : cur_loc ~ "/") ~ subdirs[0];
      }
    }
  }

  if (inserted_ul) html_pop("</ul>");
  if (next) nav_tree_r(url, next_loc, subdirs[1..$]);
}

void do_nav_tree(string url) {
  html_push("<div id=\"" ~ (nav_tree_vert ? "" : "horiz-") ~ "side-bar\">");
  nav_tree_r(url, "", cast(string[])array(pathSplitter(url)));
  html_pop("</div>\n");
}

void not_found(string path) {
  html("The page <code>" ~ path ~ "</code> does not exist. (404)");
}

void do_header() {
  html_push("<div id=\"header\">");
  
  html_push("<div class=\"superHeader\">");
  
  html_push("<div class=\"left\">");
  html_pop("</div>"); 
  
  html_push("<div class=\"right\">");
  html("<a href=\"" ~ url_root ~ "changelog\">changelog</a>");
  html_pop("</div>");
  
  html_pop("</div>");

  html_push("<div class=\"midHeader\">");
  html_push("<h1 class=\"headerTitle\">");
  html("<a href=\"" ~ url_root ~ "\">" ~ site_title ~ " <span id=\"headerSubTitle\">" ~ site_subtitle ~ "</span></a>");
  html_pop("</h1>");
  html_pop("</div>");
  
  html_push("<div class=\"subHeader\">");
  html("<br>");
  html_pop("</div>");
  
  html_pop("</div>\n");
}

bool dirExists(string path)  { try { if (isDir(path))  return true; else return false; } catch (Exception e) { return false; } }

void do_content(string url) {
  html_push("<div id=\"main-copy\"" ~ (nav_tree_vert? " class=\"main-copy-side-bar\"" : "")  ~ ">");
  // first, see if we have something that wants to handle url outright
  foreach (string glob, string h; handlers) {
    if (globMatch(url, glob)) {
      html(shell(dweb_root ~ "/bin/" ~ h ~ " " ~ url));
      html_pop("</div>");
      return;
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
          html(shell(dweb_root ~ "/bin/" ~ h ~ " " ~ f));
          html_pop("</div>");
          return;
        }
      }
    }
  }
  if (baseName(url) != "index") not_found(url);
  html_pop("</div>");
}

void do_footer() {
  html_push("<div id=\"footer\">");

  html_push("<div class=\"left\">");
  html("<a href=\"" ~ url_root ~ "dweb\">Powered by dweb</a>");
  html_pop("</div>");

  html_push("<div class=\"right\">");
  html("&nbsp;");
  html_pop("</div>");

  html_pop("</div>\n");
}

bool evil(string s) {
  foreach(char c; s) if (!isAlphaNum(c) && c != '/' && c != '-' && c != '_') return true;
  return false;
}

void main(string[] args) {
  init_handlers();
  dweb_root = getcwd()[0..$-4]; // take out bin/
 
  html("Content-type: text/html\n");
  html("<!DOCTYPE html>");
  html_push("<html>\n");

  string url = getenv("REQUEST_URI")[url_root.length..$];
  if (evil(url)) { html ("bad url."); return; }
  
  string pagename = baseName(url);
  if (pagename.length != 0) pagename = " - " ~ pagename;
  pagename = site_title ~ pagename;
  
  html_push("<head>");
  html("<title>" ~ pagename ~ "</title>");
  html("<link rel=\"stylesheet\" href=\"" ~ url_root ~ "pub/style/style.css\" type=\"text/css\" media=\"screen, handheld\" title=\"default\">");
  html("<meta charset=\"UTF-8\">");
  html("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">");
  html_pop("</head>\n");
  
  html_push("<body" ~ (page_container? " style=\"text-align: center\"" : "")~ ">");
  if (page_container) html_push("<div id=\"container\">");
  do_header();
  do_nav_tree(url);
  do_content(url);
  do_footer();
  if (page_container) html_pop("</div>");
  html_pop("</body>\n");

  html_pop("</html>");
}
