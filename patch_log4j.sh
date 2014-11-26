find ./ -iname "*pom.xml*" -exec sed -i '/maven-antrun-plugin/,/<plugin>/d' {} \;
