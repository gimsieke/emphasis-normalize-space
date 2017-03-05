# emphasis-normalize-space
Pull leading or trailing whitespace out of DocBook phrasing elements

Invocation example:

```
saxon -xsl:test/test.xsl -s:test/test.xml -o:out.xml
```

If you want to retain the pulled-out spaces as styleable elements:

```
saxon -xsl:test/test.xsl -s:test/test.xml -o:out.xml '?{http://www.le-tex.de/namespace/emphasis-normalize-space}typographical-wrap=true()'
```

(The syntax for passing XPath expressions and namespaces for parameters on the [command line](http://www.saxonica.com/html/documentation/using-xsl/commandline/) might have been added to Saxon only in recent years, so make sure you are using at least Saxon 9.6.0.7 for which it has been tested.)

The default values for the parameters `ens:left-space-regex` and `ens:right-space-regex` include non-breaking, em, en, and other spaces, opening or closing brackets/quotes, and other punctuation. You can either redeclare them or, if you just want plain `\s+`-based normalization, set the parameter `ens:ws-only` to `true()`.

```
saxon -xsl:test/test.xsl -s:test/test.xml -o:out.xml '?{http://www.le-tex.de/namespace/emphasis-normalize-space}ws-only=true()'
```

Currently the library only supports DocBook, but I will extend it to JATS, TEI and probably HTML soon.
