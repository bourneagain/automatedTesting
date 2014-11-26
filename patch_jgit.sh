find ./ -iname "*pom.xml*" -exec sed -i 's/^\s*<argLine/<\!-- <argLine/g' {} \;
find ./ -iname "*pom.xml*" -exec sed -i 's/<\/argLine>\s*$/<\/argLine> -->/g' {} \;
