# emphasis-normalize-space
Pull leading or trailing whitespace out of phrasing elements.

Usage scenario: Text that has been converted from word processors or DTP apps. Character styles are often used in these apps to mark up keywords and other phrases of semantic relevance. Mostly for typographic reasons, these apps often include the space character that follows the keyword in the styled content. Example: `<para>A <phrase role="kwd">keyword </phrase>in a paragraph.</para>`. In the resulting XML, these keywords should not contain the trailing whitespace; it needs to be pulled out of the styled content and inserted again after it.

## Invocation:

### DocBook

To convert the sample file, you can call

```
saxon -xsl:test/test.xsl -s:test/test.xml -o:out.xml
```

where `saxon` is your front-end script for Saxon. 

### Parameters

If you want to retain the pulled-out spaces as styleable elements:

```
saxon -xsl:test/test.xsl -s:test/test.xml -o:out.xml {http://www.le-tex.de/namespace/emphasis-normalize-space}typographical-wrap=true
```

The default values for the parameters `ens:left-space-regex` and `ens:right-space-regex` include non-breaking, em, en, and other spaces, opening or closing brackets/quotes, and other punctuation. You can either redeclare them or, if you just want plain `\s+`-based normalization, set the parameter `ens:ws-only` to `true`.

```
saxon -xsl:test/test.xsl -s:test/test.xml -o:out.xml {http://www.le-tex.de/namespace/emphasis-normalize-space}ws-only=true
```

Instead of calling [test/test.xsl](test/test.xsl), you can also call [lib/emphasis-normalize-space.xsl](lib/emphasis-normalize-space.xsl) directly. But then you have to specify the initial mode, `ens:default`, using the curly-brace namespace URI notation. See below for examples.

### Customization

There are currently front ends for TEI and JATS/BITS/STS.

```
saxon -xsl:lib/front-end-for-jats.xsl -s:test/test_jats.xml -im:{http://www.le-tex.de/namespace/emphasis-normalize-space}default
```

```
saxon -xsl:lib/front-end-for-tei.xsl -s:test/test_tei.xml -im:{http://www.le-tex.de/namespace/emphasis-normalize-space}default
```

The front ends contain more or less arbitrary assumptions for `$ens:inline-element-names` and `$ens:scope-establishing-elements`.

## Compatibility

It has been tested with Saxon HE 9.5.1.2, PE 9.6.0.7, and HE 9.7.0.8.

## Effect

When converting the DocBook example with the rich regexes (that contain punctuation and other space characters) and without typographic wrapper generation, the diff between [original](test/test.xml) and [result](test/out/test.xml) looks like this:

![diff](img/diff_dbk_punctuation_nophrase.png)

