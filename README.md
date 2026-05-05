=======

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY saxon-he-12.9.jar /app/
COPY lib /app/lib
COPY src /app/src  

=======

docker build -t saxon-toolbox .

docker run -it --rm -v "$(pwd)/output:/app/output" saxon-toolbox bash

java -jar Saxon-HE-12.9.jar -s:src/films.xml -xsl:src/films.xsl -o:output/films.html

root@9aa7fe00df40:/app# ls -lah output
total 24K
drwxr-xr-x 2 ubuntu ubuntu 4.0K May  5 21:47 .
drwxr-xr-x 1 root   root   4.0K May  5 21:47 ..
-rw-r--r-- 1 ubuntu ubuntu 1.4K May  5 17:26 films.css
-rw-r--r-- 1 root   root   8.6K May  5 21:47 films.html

=======

docker build -t saxon-toolbox .

docker run -d --name saxon-dev -v "$(pwd)/output:/app/output" saxon-toolbox tail -f /dev/null

docker exec -it saxon-dev bash

java -jar Saxon-HE-12.9.jar -s:src/films.xml -xsl:src/films.xsl -o:output/films.html
 or
java -cp "Saxon-HE-12.9.jar:lib/*" net.sf.saxon.Transform -s:src/films.xml -xsl:src/films.xsl -o:output/films.html

========

<https://mikecurtis1.github.io/xml-films/output/films.html>
