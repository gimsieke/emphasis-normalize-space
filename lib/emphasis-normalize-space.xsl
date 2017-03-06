<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ens="http://www.le-tex.de/namespace/emphasis-normalize-space"
  exclude-result-prefixes="ens xs" version="2.0"> 

  <!-- The following params are meant as invocation options for end users,
    the variables are meant as vocabulary customization hooks for XSLT
    developers. -->

  <xsl:param name="ens:left-space-regex" as="xs:string"
    select="'\s\p{Po}\p{Ps}\p{Pi}\p{Zs}'"/>
  <xsl:param name="ens:right-space-regex" as="xs:string"
    select="'\s\p{Po}\p{Pe}\p{Pf}\p{Zs}'"/>

  <!-- In order to activate this option with Saxon on the command line,
    supply the following parameter: 
'?{http://www.le-tex.de/namespace/emphasis-normalize-space}typographical-wrap=true()'
or (thanks to standard typecasting rules):
{http://www.le-tex.de/namespace/emphasis-normalize-space}typographical-wrap=true
  See the section “Command line parameters” at 
  http://www.saxonica.com/html/documentation/using-xsl/commandline/ -->
  <xsl:param name="ens:typographical-wrap" as="xs:boolean" select="false()"/>

  <!-- If you only want to normalize real whitespace (no punctuation etc.):
{http://www.le-tex.de/namespace/emphasis-normalize-space}ws-only=true -->
  <xsl:param name="ens:ws-only" as="xs:boolean" select="false()"/>

  <xsl:variable name="ens:inline-element-names" as="xs:string*"
    select="(: serving suggestion for DocBook :)
            ('phrase', 
             'link', 
             'glossterm', 
             'emphasis')"/>

  <!-- This is also for DocBook: -->
  <xsl:variable name="ens:scope-establishing-elements" as="xs:string*"
    select="('annotation', 
             'entry', 
             'blockquote', 
             'figure', 
             'footnote', 
             'indexterm',
             'listitem', 
             'table')"/>

  <xsl:variable name="ens:output-phrase-element-name" as="xs:string" 
    select="'phrase'"/>
  <xsl:variable name="ens:output-phrase-element-namespace" as="xs:string"
    select="'http://docbook.org/ns/docbook'"/>
  <xsl:variable name="ens:output-role-attribute-name" as="xs:string" 
    select="'role'"/>
  <xsl:variable name="ens:output-role-prefix" as="xs:string"
    select="'ens_'"/>
  <xsl:variable name="ens:input-role-attribute-names" as="xs:string*" 
    select="$ens:output-role-attribute-name"/>

  <!-- end of invocation params / customization variables -->


  <xsl:template mode="ens:default"
    match="*[local-name() = $ens:inline-element-names]
            [matches(., $ens:left-regex, 's') 
             or 
             matches(., $ens:right-regex, 's')]">
    <!-- Pattern matching requires us to provide the regexes in 
      global variables. However, in order to facilitate customizing
      (by providing individual regexes for individual matching 
      contexts), we outsource the processing to a named template
      that accepts the regexes as tunneled parameters. --> 
    <xsl:call-template name="ens:pull-out-space">
      <xsl:with-param name="left-regex" select="$ens:left-regex" tunnel="yes"/>
      <xsl:with-param name="right-regex" select="$ens:right-regex" tunnel="yes"/>
      <xsl:with-param name="both-regex" select="$ens:both-regex" tunnel="yes"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="ens:pull-out-space">
    <!-- shave-left-text-nodes and shave-right-text-nodes may be non-empty
      if we process nested inline markup. -->
    <xsl:param name="shave-left-text-nodes" as="text()*" tunnel="yes"/>
    <xsl:param name="shave-right-text-nodes" as="text()*" tunnel="yes"/>
    <xsl:param name="left-regex" as="xs:string" tunnel="yes"/>
    <xsl:param name="right-regex" as="xs:string" tunnel="yes"/>
    <xsl:variable name="same-scope-text" as="text()*" 
      select="descendant::text()[ens:same-scope(., current())]"/>
    <!-- We need the 's' option in case if some of the whitespace/punctuation
      that matches the regex is a newline character: -->
    <xsl:variable name="shave-left-text-node" as="text()?"
      select="($same-scope-text)[1][matches(., 
                                    $left-regex, 's')]"/>
    <xsl:variable name="shave-right-text-node" as="text()?"
      select="($same-scope-text)[last()][matches(., 
                                         $right-regex, 's')]"/>
    <!-- Render the whitespace/punctuation part of the leftmost text node
      within the current context (if it starts with whitespace/punctuation): -->
    <xsl:call-template name="ens:pulled-out-space">
      <xsl:with-param name="string" 
        select="replace(
                  $shave-left-text-node[not(
  (: suppress WS that will already :)     some $a in $shave-left-text-nodes
  (: be rendered by an ancestor :)        satisfies ($a is .)
                                       )],
                  $left-regex, 
                  '$1', 
                  's'
                )"/>
    </xsl:call-template>
    <!-- next-match might invoke the identity template but maybe also some
      other template in the current mode (ens:default). Noteworthy observations:
      a) The text nodes that should be stripped of their whitespace/punctuation
         are passed as tunneled parameters. These will be caught when
         processing text nodes. Node-identity comparison will tell 
         text node matching templates whether the node at hand is one
         that needs to be left-trimmed, right-trimmed, or both. 
      b) Both the to-be-stripped text nodes of the current context
         and of the surrounding context(s) will be passed in parameters
         that hold sequences of text nodes; one parameter for left and
         one for right. -->
    <xsl:next-match>
      <xsl:with-param name="shave-left-text-nodes" tunnel="yes"
        select="($shave-left-text-node, $shave-left-text-nodes)"/>
      <xsl:with-param name="shave-right-text-nodes" tunnel="yes"
        select="($shave-right-text-node, $shave-right-text-nodes)"/>
    </xsl:next-match>
    <!-- Render the whitespace/punctuation part of the rightmost text node
      within the current context (if it ends with whitespace/punctuation): -->
    <xsl:call-template name="ens:pulled-out-space">
      <xsl:with-param name="string" 
        select="replace(
                  $shave-right-text-node[not(
  (: suppress WS that will already :)     some $a in $shave-right-text-nodes
  (: be rendered by an ancestor :)        satisfies ($a is .)
                                       )], 
                  $right-regex, 
                  '$2', 
                  's'
                )"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template mode="ens:default"
    match="*[local-name() = $ens:inline-element-names]//text()">
    <xsl:param name="shave-left-text-nodes" as="text()*" tunnel="yes"/>
    <xsl:param name="shave-right-text-nodes" as="text()*" tunnel="yes"/>
    <xsl:param name="left-regex" as="xs:string?" tunnel="yes"/>
    <xsl:param name="right-regex" as="xs:string?" tunnel="yes"/>
    <xsl:param name="both-regex" as="xs:string?" tunnel="yes"/>
    <xsl:variable name="current-in-left" as="text()?" 
      select="$shave-left-text-nodes intersect ."/>
    <xsl:variable name="current-in-right" as="text()?" 
      select="$shave-right-text-nodes intersect ."/>
    <xsl:variable name="current-in-both" as="text()?" 
      select="$current-in-left intersect $current-in-right"/>
    <xsl:choose>
      <xsl:when test="exists($current-in-both)">
        <xsl:value-of select="replace(., $ens:both-regex, '$2', 's')"/>
      </xsl:when>
      <xsl:when test="exists($current-in-left)">
        <xsl:value-of select="replace(., $ens:left-regex, '$2', 's')"/>
      </xsl:when>
      <xsl:when test="exists($current-in-right)">
        <xsl:value-of select="replace(., $ens:right-regex, '$1', 's')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <xsl:template name="ens:pulled-out-space">
    <xsl:param name="string" as="xs:string"/>
    <xsl:choose>
      <!-- Suppressing empty strings is necessary when using the wrapper
        option. -->
      <xsl:when test="$string eq ''"/>
      <!-- Optionally wrap the shaved-off whitespace/punctuation in an 
        element that may be styled appropriately. This may be customized
      for each XML vocabulary. -->
      <xsl:when test="$ens:typographical-wrap">
        <xsl:element name="{$ens:output-phrase-element-name}"
          namespace="{$ens:output-phrase-element-namespace}">
          <xsl:attribute name="{$ens:output-role-attribute-name}"
            select="ens:wrapper-role(.)"/>
          <xsl:if test="matches($string, '^\s')
                        or matches($string, '\s$')">
            <xsl:attribute name="xml:space" select="'preserve'"/>
          </xsl:if>
          <xsl:value-of select="$string"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Attach a class value to the generated whitespace/punctuation 
    wrapper markup that conveys information about the context that
    it stems from. Then the input typography can be restored while
    still being able to extract the meaningful phrases from the input -->
  <xsl:function name="ens:wrapper-role" as="xs:string">
    <xsl:param name="orig-element" as="element(*)"/>
    <xsl:variable name="role-val" as="xs:string?"
      select="(for $n in $ens:input-role-attribute-names 
               return $orig-element/@*[name() = $n])[1]"/>
    <xsl:sequence 
      select="if (normalize-space($role-val))
              then
                for $r in tokenize($role-val, '\s+')
                return concat($ens:output-role-prefix, local-name($orig-element), '.', $r)
              else
                concat($ens:output-role-prefix, local-name($orig-element))"/>
  </xsl:function>
  
  <xsl:function name="ens:same-scope" as="xs:boolean">
    <!-- 
      There are situations when you don’t want to select the
      text nodes of an embedded footnote when selecting the text
      nodes of a paragraph.
      A footnote, for example, constitutes a so called “scope.”
      Other scope-establishing elements are table cells that
      may contain paragraphs, or figures/tables whose captions 
      may contain paragraphs. But also indexterms, elements that 
      do not contain paragraphs, may establish a new scope. 
      This concept allows you to select only the main narrative 
      text of a given paragraph (or phrase, …), excluding any 
      content of embedded notes, figures, list items, or index 
      terms.
      Example:
<para><emphasis>Outer</emphasis> para text<footnote><para>Footnote text</para></footnote>.</para>
      Typical invocation (context: outer para):
      .//text()[ens:same-scope(., current())]
      Result: The three text nodes with string content
      'Outer', ' para text', and '.'
      -->
    <xsl:param name="node" as="node()" />
    <xsl:param name="ancestor-elt" as="element(*)*" />
    <xsl:sequence 
      select="not(
                $node/ancestor::*[
                  local-name() = $ens:scope-establishing-elements]
                  [
                    some $a in ancestor::* 
                    satisfies (
                      some $b in $ancestor-elt 
                      satisfies ($a is $b))
                  ]
                )" />
  </xsl:function>
  
  <xsl:variable name="ens:left-positive-regex-group" as="xs:string"
    select="(
              '(\s+)'[$ens:ws-only], 
              concat('([', $ens:left-space-regex, ']+)')
            )[1]"/>
  
  <xsl:variable name="ens:negative-regex-group-after-left" as="xs:string"
    select="(
              '(\S.*)'[$ens:ws-only], 
              concat('([^', $ens:left-space-regex, $ens:right-space-regex, '].*)')
            )[1]"/>

  <xsl:variable name="ens:right-positive-regex-group" as="xs:string"
    select="(
              '(\s+)'[$ens:ws-only], 
              concat('([', $ens:right-space-regex, ']+)')
            )[1]"/>
  
  <xsl:variable name="ens:negative-regex-group-before-right" as="xs:string"
    select="(
              '(.*\S)'[$ens:ws-only], 
              concat('(.*[^', $ens:left-space-regex, $ens:right-space-regex, '])')
            )[1]"/>

  <xsl:variable name="ens:left-regex" as="xs:string"
    select="concat(
              '^', 
              $ens:left-positive-regex-group,
              $ens:negative-regex-group-after-left,
              '$'
            )"/>
  <xsl:variable name="ens:right-regex" as="xs:string"
    select="concat(
              '^',
              $ens:negative-regex-group-before-right,
              $ens:right-positive-regex-group,
              '$'
            )"/>
  <xsl:variable name="ens:both-regex" as="xs:string"
    select="concat(
              '^', 
              $ens:left-positive-regex-group,
              $ens:negative-regex-group-before-right,
              $ens:right-positive-regex-group,
              '$'
            )"/>

  <xsl:template match="@* | node()" mode="ens:default">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>