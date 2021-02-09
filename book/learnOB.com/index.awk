/^# /{
	title = substr($0, match($0, "[A-Z]"))
	getline timestamp
	split(timestamp, a)
	articleyear = a[3]
	if (!year) {
		year = articleyear
		printf "<h1>%d</h1>\n", year
	} else if (articleyear < year) {
		year = articleyear
		printf "<h1>%d</h1>\n", year
	}
	sub("md$", "html", FILENAME)
	printf "<a href=\"%s\">%s</a> %s\n", FILENAME, title, timestamp
	print "<br>"
	nextfile
}
