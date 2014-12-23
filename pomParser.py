from lxml import etree as ET
tree=ET.parse('/Users/sam/cs527/cs527Project/guava-libraries/guava-tests/pom_bk.xml');
root=tree.getroot()
namespaces = {"pns" : "http://maven.apache.org/POM/4.0.0"}
#root.findall('pns:parent',namespaces=namespaces)

# only able to traverse the tags
for i in root:
	print i.tag


# able to iter through all available tags 
for i in root.iter():
	print i

"""
Ekstazi plugin content  to be added under  build/plugins

<plugin>
<dependencies>
<dependency>
<groupId>org.ekstazi</groupId>
<artifactId>org.ekstazi.core</artifactId>
<version>3.4.2</version>
</dependency>
</dependencies>
<groupId>org.ekstazi</groupId>
<artifactId>ekstazi-maven-plugin</artifactId>
<version>3.4.2</version>
<executions>
<execution>
<id>selection</id>
<goals>
<goal>selection</goal>
<goal>restore</goal>
</goals>
</execution>
</executions>
</plugin>
"""
