
PLUGIN_PATH=~/appsupport/sibelius/Plugins
EXAMPLE=~/Documents/Musik/Konserter/Flöjt/*.sib

test:                                          
	cp ExportJSON.plg $(PLUGIN_PATH)/JSON/ExportJSON.plg
	open -a /Applications/Sibelius\ 6.app $(EXAMPLE)


