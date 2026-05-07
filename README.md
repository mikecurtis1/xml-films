# XML Transformation

## XSLT with Saxon

Dockerfile

```text
FROM eclipse-temurin:17-jre

WORKDIR /app

COPY saxon-he-12.9.jar /app/
COPY lib /app/lib
COPY src /app/src  
```

Create Docker image

```bash
docker build -t saxon-toolbox .
```

Create container and open bash shell in one action.

```bash
docker run -it --rm -v "$(pwd)/output:/app/output" saxon-toolbox bash
```

> Or
> 
> Create container then open bash shell in separate actions.
> 
> ```bash
> docker run -d --name saxon-dev -v "$(pwd)/output:/app/output" saxon-toolbox tail -f /dev/null
> ```
> ```bash
> docker exec -it saxon-dev bash
> ```

---

Examine the XML source code and the output folder prior to running the Saxon transformation.

```bash
pwd
```
```bash
ls -lah
```
```bash
ls -lah src 
```
```bash
head src/films.xml
```
```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="films.xsl"?>
<!DOCTYPE film_collection SYSTEM "films.dtd">
<film_collection amgbase="http://www.allmovie.com/">
  <film date_entered="5/20/2004" amg="v45555">
	<title>
		<original_title language="English">Some Like It Hot</original_title>
		<other_title language="Japanese">O Atsui no ga O Suki</other_title>
	</title>
	<awards>
```
```bash
head -21 src/films.xsl
```
```xsl
<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:variable name="amgbase" select="/film_collection/@amgbase"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="stylesheet" type="text/css" href="films.css" media="screen" />
        <link 
          rel="stylesheet" 
          type="text/css" 
          href="https://fonts.googleapis.com/css?family=Lato" />
      <title>Film Collection :: XML</title>
      </head>
      <body>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>
```
```bash
ls -lah output
```
```bash
head -28 output/films.css
```
```css
body {
    font-family:"Lato", Helvetica,sans-serif;
    background-color:#493C35;
    max-width:34em;
    margin-left:auto;
    margin-right:auto;
    padding:0 1em 0 1em;
}

hr {
    /*color:#B7C68B;
    background-color:#B7C68B;
    border:0;
    height:0.25em;*/
    background-color:#493C35;
    border-top:0.25em dotted #eaeaca;
    border-bottom:0;
    
}

div.film {
    border-radius: 1em 1em 0 0;
    border-bottom: 0.5em dotted #eaeaca;
    background-color:#C7B493;
    color:#524032;
    padding:1.25em 2em 1em 2em;
    margin: 0 0 1em 0;
}
```

---

Run Saxon tranformation of XML to HTML utilizing the XSLT file.

```bash
java -jar Saxon-HE-12.9.jar -s:src/films.xml -xsl:src/films.xsl -o:output/films.html
```

> Or run Saxon with options to explicitly indicate library dependencies
>
> ```bash
> java -cp "Saxon-HE-12.9.jar:lib/*" net.sf.saxon.Transform -s:src/films.xml -xsl:src/films.xsl -o:output/films.html
> ```

```bash
ls -lah output
```
```text
total 24K
drwxr-xr-x 2 ubuntu ubuntu 4.0K May  5 21:47 .
drwxr-xr-x 1 root   root   4.0K May  5 21:47 ..
-rw-r--r-- 1 ubuntu ubuntu 1.4K May  5 17:26 films.css
-rw-r--r-- 1 root   root   8.6K May  5 21:47 films.html
```
```bash
head -18 output/films.html
```
```html
<!DOCTYPE HTML>
<html>
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <link rel="stylesheet" type="text/css" href="films.css" media="screen">
      <link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Lato">
      <title>Film Collection :: XML</title>
   </head>
   <body>
      <div class="film">
         <div class="title">
            <div class="original_title"><a href="http://www.allmovie.com/movie/v45555">Some Like It Hot</a> (English)
               </div>
            <div class="other_title">O Atsui no ga O Suki (Japanese)
               </div>
            <div class="date_entered">Date entered : 5/20/2004</div>
         </div>
```

> <https://mikecurtis1.github.io/xml-films/output/films.html>
