const string url_root = "/~j3parker/";

const string site_title = "This is a Title";
const string site_subtitle = "but this is a subtitle";

const bool nav_tree_vert = false;
const bool nav_tree_chev = false;
const bool page_container = true;

string[string] handlers;

void init_handlers() {
  handlers["*.md"] = "contrib/Markdown.pl";
  handlers["changelog"] = "changelog.sh";
}
