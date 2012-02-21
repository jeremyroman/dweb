//#!/usr/bin/rdmd
import std.stdio;
import std.process;
import std.file;
import std.array;
import std.string;
import std.algorithm;
import config;

string indent = "";
void html(string s) { writeln(indent ~ s); }
void html_pop(string s) { indent = indent[0..max(0, $-4)]; html(s); }
void html_push(string s) { html(s); indent ~= "    "; }

void write_link(string root, string file, bool expand) {
  bool isdir = dirExists(file);
  string flair = nav_tree_chev? (expand? "&raquo; " : "&rsaquo; ") : "";
  html_push("<li" ~ (expand? " class=\"thisPage\" " : "") ~ ">");
  html("<a href=\"" ~ construct_rel_link(root, file) ~ "\">"
        ~ flair ~last_in_path(file) ~ (isdir ? "/" : "")
        ~ "</a>");
  html_pop("</li>");
}

void nav_tree_r(string root, string cur_loc, string[] subdirs) {
  string[] dirs = dir(cur_loc);
  if (dirs.length == 0) return;
  html_push("<ul>");
  bool next = false;
  string next_loc;
  foreach(string s; dirs) {
    bool hidden = last_in_path(s).length > 0 && last_in_path(s)[0] == '.';
    bool expand = s[cur_loc.length..$] == (subdirs.length == 0 ? "" : subdirs[0]);
    if (hidden && !expand) continue;
    write_link(root, s, expand);
    if (expand && isDir(cur_loc ~ subdirs[0])) {
      if (nav_tree_vert) {
        html_push("<li>");
        nav_tree_r(root, cur_loc ~ subdirs[0] ~ "/", subdirs[1..$]);
        html_pop("</li>");
      } else {
        next = true;
        next_loc = cur_loc ~ subdirs[0] ~ "/";
      }
    }
  }
  html_pop("</ul>");
  if (next) nav_tree_r(root, next_loc, subdirs[1..$]);
}

// this could be better
string[] dir(string path) {
  string[] files;
  foreach(string s; dirEntries(path, SpanMode.shallow)) {
    if (s[max(0,$-8)..$] != "index.md") files ~= s;
  }
  sort(files);
  return files;
}

void do_nav_tree(string path) {
  try { if (isDir(path) && path[path.length - 1] != '/') { path = site_root; } }
  catch (Exception e) { path = site_root; }

  html_push("<div id=\"" ~ (nav_tree_vert ? "" : "horiz-") ~ "side-bar\">");

  string root = get_root_dir(path);
  string[] subdirs = explode_slashes(path[site_root.length..$]);
  nav_tree_r(root, site_root, subdirs);

  html_pop("</div>\n");
}

string last_in_path(string path) {
  auto i = max(path.length,1) - 1;
  while (i-- > 0) if (path[i] == '/') return path[min(i+1,$)..$];
  return path;
}

string chomp_slashes(string path) { return chompPrefix(chomp(path, "/"), "/"); }
string[] explode_slashes(string path) { return split(chomp_slashes(path), "/"); }

string get_root_dir(string path) {
  if (path == "") return "";
  if (isDir(path)) return path[path.length - 1] == '/' ? path : path ~ "/";
  auto i = path.length - 1;
  while (--i > 0) if (path[i] == '/') return path[0..i];
  return "/";
}

string construct_rel_link(string src, string dst) {
  string rel = "";
  string[] srcs = explode_slashes(src);
  string[] dsts = explode_slashes(dst);
  ulong i = 0;
  while(i < srcs.length && i < dsts.length && srcs[i] == dsts[i]) i++;
  if (i == srcs.length && i == dsts.length) return ".";
  foreach (ulong j; 0..(srcs.length - i)) rel ~= "../";
  foreach (string s; dsts[i..$]) rel ~= s ~ "/"; 
  return isDir(dst) ? rel : rel[0..$-1];
}

void not_found(string path) {
  html("The page <code>" ~ path ~ "</code> does not exist. (404)");
}

void do_header() {
  html_push("<div id=\"header\">");
  
  html_push("<div class=\"superHeader\">");
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

void do_markdown(string file) {
  // sanity check file first?!?!?
  html(shell("cat " ~ file ~ "|" ~ dweb_root ~ "bin/contrib/Markdown.pl"));
}

bool fileExists(string path) { try { if (isFile(path)) return true; else return false; } catch (Exception e) { return false; } }
bool dirExists(string path)  { try { if (isDir(path))  return true; else return false; } catch (Exception e) { return false; } }

void do_content(string path) {
  html_push("<div id=\"main-copy\"" ~ (nav_tree_vert? " class=\"main-copy-side-bar\"" : "")  ~ ">");
  string url = path[site_root.length..$];
  switch (url) {
    case "changelog":
      html(shell(dweb_root ~ "bin/changelog"));
      break;
    default:
      try {
        if (isDir(path) && fileExists(path ~ "index.md")) path ~= "index.md";
        if (fileExists(path)) do_markdown(path);
      } catch (Exception e) {
        not_found(path);
      }
  }
  html_pop("</div>\n");
}

void do_footer() {
  html_push("<div id=\"footer\">");

  html_push("<div class=\"left\">");
  html("<a href=\"" ~ url_root ~ ".dweb\">Powered by dweb</a>");
  html_pop("</div>");

  html_push("<div class=\"right\">");
  html("&nbsp;");
  html_pop("</div>");

  html_pop("</div>\n");
}

void main(string[] args) {
  html("Content-type: text/html\n");
  html("<!DOCTYPE html>");
  html_push("<html>\n");

  string url = getenv("SCRIPT_URL")[url_root.length..$];
  string path = site_root ~ url;
  
  string pagename = last_in_path(url);
  if (pagename.length != 0) pagename = " - " ~ pagename;
  pagename = site_title ~ pagename;
  
  html_push("<head>");
  html("<title>" ~ pagename ~ "</title>");
  html("<link rel=\"stylesheet\" href=\"" ~ url_root ~ "pub/style/style.css\" type=\"text/css\" media=\"screen, handheld\" title=\"default\">");
  html("<link rel=\"shortcut\" href=\"" ~ url_root ~ "pub/favicon.ico\" type=\"image/vnd.microsoft.icon\">");
  html("<meta charset=\"UTF-8\">");
  html("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">");
  html_pop("</head>\n");
  
  html_push("<body" ~ (page_container? " style=\"text-align: center\"" : "")~ ">");
  if (page_container) html_push("<div id=\"container\">");
  do_header();
  do_nav_tree(path);
  do_content(path);
  do_footer();
  if (page_container) html_push("</div>");
  html_pop("</body>\n");

  html_pop("</html>");
}
