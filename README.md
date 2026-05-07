# XML Transformation

## Background

This project began as a small XML/XSLT demonstration intended to explore structured XML data transformation into styled HTML presentation. The sample dataset models a film collection containing titles, personnel, awards, locations, languages, and related metadata. The primary purpose of the project was to experiment with XSLT templating, XPath navigation, and the separation between structured source data and rendered presentation output.

The original implementation relied on browser-native XML processing instructions and DTD-based document structure definitions. Within the XML source file (`src/films.xml`) the processing instruction:

```xml
<?xml-stylesheet type="text/xsl" href="films.xsl"?>
```

directed the browser to dynamically apply the XSLT transformation (`src/films.xsl`) at render time, while the document type declaration:

```xml
<!DOCTYPE film_collection SYSTEM "films.dtd">
```

associated the XML document with an external DTD (`src/films.dtd`) defining the permitted document structure and attribute constraints. The XSLT transformation generated HTML structure and hyperlinks dynamically, while CSS styling was applied separately through standard stylesheet references embedded in the transformed HTML output.

Modern browser support for native XSLT processing has gradually been deprecated, making the original browser-based transformation workflow unreliable as a long-term demonstration method. In the original design, the HTML output existed only as a dynamically generated browser DOM structure rather than as a persistent HTML artifact stored on disk. To preserve the transformation workflow while producing reproducible static output, the project was revised to use Saxon HE as an explicit XSLT transformation engine executed within a Docker container. The revised pipeline generates a persistent HTML file suitable for static hosting through GitHub Pages.

---

## Replacing browser-based XML transformation with Saxon

To replace the deprecated browser-native XSLT workflow, the project now uses [Saxon HE](https://www.saxonica.com/download/java.xml) as an explicit XSLT transformation engine. Saxon is a Java-based XSLT and XPath processor capable of transforming XML documents into HTML, XML, text, and other output formats. In this project, Saxon processes `src/films.xml` together with `src/films.xsl` and generates a persistent HTML artifact in `output/films.html`.

The Saxon integration was intentionally kept lightweight and local to the project rather than installed globally into the development environment. After downloading the Saxon HE distribution archive, the primary `saxon-he-12.9.jar` file together with the supporting `lib/` dependency directory were copied into the local project directory structure. These runtime dependencies are required for the Java execution environment but are not considered part of the project source itself, so both the Saxon JAR file and the accompanying `lib/` directory were excluded from version control using `.gitignore`.

Although experienced Java developers may already be familiar with external JAR dependency management and classpath configuration, the setup process is documented here because XML/XSLT transformation workflows have become relatively uncommon in contemporary front-end development. The intent of this repository is therefore not only to preserve the transformation pipeline itself, but also to document the surrounding tooling and execution model required to reproduce the transformation process using current software environments.

---

## Docker setup

The transformation workflow is executed within a lightweight Docker container using the Eclipse Temurin Java runtime image. Containerization was chosen primarily to avoid introducing Java and Saxon dependencies directly into the host WSL development environment while still preserving a reproducible execution context for the transformation pipeline.

The container mounts the local `output/` directory from the host filesystem so that generated HTML artifacts persist outside the container lifecycle and remain available for static publishing through GitHub Pages.

### Dockerfile content

```text
FROM eclipse-temurin:17-jre

WORKDIR /app

COPY saxon-he-12.9.jar /app/
COPY lib /app/lib
COPY src /app/src  
```

### Create Docker image

```bash
docker build -t saxon-toolbox .
```

### Create container and open bash shell in one action.

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

## Examine the XML source code and the output folder prior to running the Saxon transformation.

Once the container is running, the XML source files, XSLT transformation logic, and output directories can be inspected directly within the isolated runtime environment. The following commands demonstrate the project structure prior to executing the Saxon transformation process.

```bash
hostname
```
```text
LAPTOP
```
```bash
ls -lah
```
```text
total 5.6M
drwxr-xr-x  6 mikecurtis1 mikecurtis1 4.0K May  7 12:21 .
drwxr-x--- 17 mikecurtis1 mikecurtis1 4.0K May  7 12:24 ..
drwxr-xr-x  8 mikecurtis1 mikecurtis1 4.0K May  7 12:24 .git
-rw-r--r--  1 mikecurtis1 mikecurtis1   40 May  7 12:20 .gitignore
-rw-r--r--  1 mikecurtis1 mikecurtis1  111 May  7 12:20 Dockerfile
-rw-r--r--  1 mikecurtis1 mikecurtis1 8.6K May  7 12:23 README.md
drwxr-xr-x  2 mikecurtis1 mikecurtis1 4.0K May  7 12:21 lib
drwxr-xr-x  2 mikecurtis1 mikecurtis1 4.0K May  7 11:53 output
-rw-r--r--  1 mikecurtis1 mikecurtis1 5.6M Sep 12  2025 saxon-he-12.9.jar
drwxr-xr-x  2 mikecurtis1 mikecurtis1 4.0K May  5 19:42 src
```
```bash
cat .gitignore
```
```text
Saxon-HE-12.9.jar
saxon-he-12.9.jar
lib/
```
```bash
ls -lah output
```
```text
total 12K
drwxr-xr-x 2 mikecurtis1 mikecurtis1 4.0K May  7 11:53 .
drwxr-xr-x 6 mikecurtis1 mikecurtis1 4.0K May  7 12:21 ..
-rw-r--r-- 1 mikecurtis1 mikecurtis1 1.4K May  5 19:29 films.css
```
```bash
ls -lah src 
```
```text
total 28K
drwxr-xr-x 2 mikecurtis1 mikecurtis1 4.0K May  5 19:42 .
drwxr-xr-x 6 mikecurtis1 mikecurtis1 4.0K May  7 12:21 ..
-rw-r--r-- 1 mikecurtis1 mikecurtis1 1.7K May  5 19:42 films.dtd
-rw-r--r-- 1 mikecurtis1 mikecurtis1 4.3K May  5 19:42 films.xml
-rw-r--r-- 1 mikecurtis1 mikecurtis1 4.5K May  5 19:42 films.xsl
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

## Run Saxon tranformation of XML to HTML utilizing the XSLT file.

The transformation itself is performed by invoking the Saxon processor through the Java runtime. The `-s` parameter identifies the XML source document, `-xsl` specifies the XSLT stylesheet, and `-o` defines the generated HTML output artifact.

```bash
java -jar saxon-he-12.9.jar -s:src/films.xml -xsl:src/films.xsl -o:output/films.html
```

> Or run Saxon with options to explicitly indicate library dependencies
>
> ```bash
> java -cp "saxon-he-12.9.jar:lib/*" net.sf.saxon.Transform -s:src/films.xml -xsl:src/films.xsl -o:output/films.html
> ```

### Examine output

Notice that within the container environment (hostname `daf877f94c93`) the `output/` directory reflects host filesystem ownership (`ubuntu`) due to the Docker bind mount (`"$(pwd)/output:/app/output"`), which shares the directory between host and container.

```bash
hostname
```
```text
daf877f94c93
```

```bash
ls -lah
```

```text
total 5.6M
drwxr-xr-x 1 root   root   4.0K May  7 16:25 .
drwxr-xr-x 1 root   root   4.0K May  7 16:25 ..
drwxr-xr-x 2 root   root   4.0K May  7 16:14 lib
drwxr-xr-x 2 ubuntu ubuntu 4.0K May  7 16:26 output
-rw-r--r-- 1 root   root   5.6M Sep 12  2025 saxon-he-12.9.jar
drwxr-xr-x 2 root   root   4.0K May  7 15:54 src
```

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

After shutting down the container we can confirm our output file persists in the host environement. (Note ownership by `root` which came from the container environment.)

```bash
hostname
```
```text
LAPTOP
```
```bash
ls -lah output
```
```text
total 24K
drwxr-xr-x 2 mikecurtis1 mikecurtis1 4.0K May  7 12:26 .
drwxr-xr-x 6 mikecurtis1 mikecurtis1 4.0K May  7 12:21 ..
-rw-r--r-- 1 mikecurtis1 mikecurtis1 1.4K May  5 19:29 films.css
-rw-r--r-- 1 root        root        8.6K May  7 12:26 films.html
```

#### View HTML transformation in browser.

> <https://mikecurtis1.github.io/xml-films/output/films.html>
