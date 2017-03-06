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

## Design considerations

### Naïve approach

The result of applying [lib/naive.xsl](lib/naive.xsl) to the input is shown here:

![naive](img/naive.png)

## Issues and solutions

Please note that this solution does not aim at extracting other that whitespace characters.

There are still several issues with it:

* Only right-side space normalization is performed. When you also consider left-side normalization, you either need two XSLT passes or you have to test for the case where a text node needs to be processed on [both ends](https://github.com/gimsieke/emphasis-normalize-space/blob/f0c0d6071dd157fb2fbe96e432daa758e546f45f/lib/emphasis-normalize-space.xsl#L154).
* Instead of trailing whitespace only, some of the non-whitespace element content is repeated outside of the element (example: `Nested phrases with  in it.`. This can be fixed by adding the `'s'` flag to `replace()` so that line breaks count as regular white space.
* Only the outermost elements are preserved. Nested elements will be replaced with their text content. This can be fixed by ordinary (yet recursive!) [matching template](https://github.com/gimsieke/emphasis-normalize-space/blob/f0c0d6071dd157fb2fbe96e432daa758e546f45f/lib/emphasis-normalize-space.xsl#L63) processing in which the left/right text nodes that need to be processed are passed as [tunneled parameters](https://github.com/gimsieke/emphasis-normalize-space/blob/f0c0d6071dd157fb2fbe96e432daa758e546f45f/lib/emphasis-normalize-space.xsl#L80) until we finally reach the [text nodes](https://github.com/gimsieke/emphasis-normalize-space/blob/f0c0d6071dd157fb2fbe96e432daa758e546f45f/lib/emphasis-normalize-space.xsl#L144) and check which ones need processing.
* If you want to extend the mechanism to punctuation, you need to use different regexes for left-hand and right-hand characters. (Although I didn’t test yet how well it deals with ambiguous characters such as [U+201C](http://www.fileformat.info/info/unicode/char/201c/index.htm). Maybe we need to assemble the character classes after reading the document language.
* A very subtle one: Footnotes that end in whitespace, or worse, in punctuation. If these footnotes are wrapped in a phrase (this may occur when the footnote marker has a character style in InDesign), it might happen that the footnote punctuation will be pulled out of the footnote. We use the [same-scope()](https://github.com/gimsieke/emphasis-normalize-space/blob/f0c0d6071dd157fb2fbe96e432daa758e546f45f/lib/emphasis-normalize-space.xsl#L217) (that deserves to be discussed in its own article) to only process text nodes within the current paragraph, not within paragraphs that are embedded because of a list item, a table cell, a figure caption, or a footnote are included in the current paragraph.


