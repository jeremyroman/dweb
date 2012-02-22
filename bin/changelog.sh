echo "<ul>"
git log --pretty=format:'<li>%s - %aN (%ae) <b>(%cr)</b></li>' --abbrev-commit --date=relative
echo "</ul>"
