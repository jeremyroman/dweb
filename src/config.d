const string url_root = "/~j3parker/";

const string site_title = "This is a Title";
const string site_subtitle = "but this is a subtitle";

const bool nav_tree_vert = true;
const bool nav_tree_chev = true;
const bool page_container = false;

string[string] handlers;

void init_handlers() {
  handlers["*.md"] = "contrib/Markdown.pl";
  handlers["changelog"] = "changelog.sh";
}
