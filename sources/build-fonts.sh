#!/bin/bash

rm -rf "fonts/OTF-Mac" "fonts/TTF-Windows" "fonts/Webfonts"
mkdir -p "fonts/OTF-Mac" "fonts/TTF-Windows" "fonts/Webfonts"

for weightName in Semibold Retina Regular Medium Light Heavy Extrabold Bold
do
	for style in Roman Italic
	do

		if [ "$style" = "Roman" ]; then
			baseName="TwilioSansMono-$weightName"
		    sourcePath="$style/$weightName/$baseName.ufo"
		else
			baseName="TwilioSansMono-${weightName}Itl"
		    sourcePath="$style/$weightName/$baseName.ufo"
		fi

		ufoPath="${sourcePath/Itl/Italic}"

		echo " :::: Building OTFs :::: "
		makeotf -omitMacNames -addDSIG -f $ufoPath -r -o fonts/OTF-Mac 

		echo " :::: Building TTFs :::: "
		otf2ttf "fonts/OTF-Mac/$baseName.otf" -o "fonts/TTF-Windows/$baseName.ttf"
		cp -r $ufoPath "fonts/TTF-Windows/"
		ttfcomponentizer "fonts/TTF-Windows/$baseName.ttf"
		rm -r fonts/TTF-Windows/*.ufo

		echo " :::: Building Webfonts :::: "
		cp "fonts/TTF-Windows/$baseName.ttf" "fonts/Webfonts/"
		gftools fix-dsig -d "fonts/Webfonts/$baseName.ttf"
		gftools fix-vertical-metrics -at 950 -dt -266 -lt 0 "fonts/Webfonts/$baseName.ttf"
		sfnt2woff-zopfli "fonts/Webfonts/$baseName.ttf"
		woff2_compress "fonts/Webfonts/$baseName.ttf"
		rm fonts/Webfonts/*.ttf

	done
done