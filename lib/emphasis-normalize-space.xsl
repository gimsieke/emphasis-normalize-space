<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ens="http://www.le-tex.de/namespace/emphasis-normalize-space"
  xmlns:docbook="http://docbook.org/ns/docbook"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="docbook ens xs" version="2.0"> 

  <xsl:param name="ens:left-space-regex" as="xs:string"
    select="'([\s\p{Po}\p{Ps}\p{Pi}\p{Zs}]+)'"/>
  <xsl:param name="ens:right-space-regex" as="xs:string"
    select="'([\s\p{Po}\p{Pe}\p{Pf}\p{Zs}]+)'"/>

  <!-- In order to activate this option with Saxon on the command line: 
'?{http://www.le-tex.de/namespace/emphasis-normalize-space}typographical-wrap=true()' 
  See the section “Command line parameters” at 
  http://www.saxonica.com/html/documentation/using-xsl/commandline/ -->
  <xsl:param name="ens:typographical-wrap" as="xs:boolean" select="false()"/>

  <!-- If you only want to normalize real whitespace (no punctuation etc.):
'?{http://www.le-tex.de/namespace/emphasis-normalize-space}ws-only=true()' -->
  <xsl:param name="ens:ws-only" select="false()"/>

  <xsl:variable name="ens:left-regex" as="xs:string"
    select="concat(
              '^', 
              (
                '(\s+)'[$ens:ws-only], 
                $ens:left-space-regex
              )[1],
              '(.+)$'
            )"/>
  <xsl:variable name="ens:right-regex" as="xs:string"
    select="concat(
              '^(.+?)', 
              (
                '(\s+)'[$ens:ws-only],
                $ens:right-space-regex
              )[1],
              '$'
            )"/>
  <xsl:variable name="ens:both-regex" as="xs:string"
    select="concat('^', $ens:left-space-regex, '(.+?)', 
                        $ens:right-space-regex, '$')"/>

  <xsl:variable name="ens:inline-element-names" as="xs:string*"
    select="(: serving suggestion for DocBook :)
            ('phrase', 
             'link', 
             'glossterm', 
             'emphasis')"/>

  <xsl:template mode="ens:default"
    match="*[local-name() = $ens:inline-element-names]
            [matches(., $ens:left-regex, 's') 
             or matches(., $ens:right-regex, 's')]">
    <xsl:param name="shave-left-text-nodes" as="text()*" tunnel="yes"/>
    <xsl:param name="shave-right-text-nodes" as="text()*" tunnel="yes"/>

    <xsl:variable name="same-scope-text" as="text()+" 
      select="descendant::text()[docbook:same-scope(., current())]"/>
    <xsl:variable name="shave-left-text-node" as="text()?"
      select="($same-scope-text)[1][matches(., 
                                    $ens:left-regex, 's')]"/>
    <xsl:variable name="shave-right-text-node" as="text()?"
      select="($same-scope-text)[last()][matches(., 
                                         $ens:right-regex, 's')]"/>
    <xsl:call-template name="ens:pulled-out-space">
      <xsl:with-param name="string" 
        select="replace($shave-left-text-node, $ens:left-regex, '$1', 's')"/>
    </xsl:call-template>
    <xsl:next-match>
      <xsl:with-param name="shave-left-text-nodes" tunnel="yes"
        select="($shave-left-text-node, $shave-left-text-nodes)"/>
      <xsl:with-param name="shave-right-text-nodes" tunnel="yes"
        select="($shave-right-text-node, $shave-right-text-nodes)"/>
    </xsl:next-match>
    <xsl:call-template name="ens:pulled-out-space">
      <xsl:with-param name="string" 
        select="replace($shave-right-text-node, $ens:right-regex, '$2', 's')"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template 
    match="*[local-name() = $ens:inline-element-names]//text()" 
    mode="ens:default">
    <xsl:param name="shave-left-text-nodes" as="text()*" tunnel="yes"/>
    <xsl:param name="shave-right-text-nodes" as="text()*" tunnel="yes"/>
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
      <xsl:when test="$string eq ''"/>
      <xsl:when test="$ens:typographical-wrap">
        <phrase role="{ens:wrapper-role(.)}">
          <!--<xsl:if test="matches($string, '^\s')
                        or matches($string, '\s$')">
            <xsl:attribute name="xml:space" select="'preserve'"/>
          </xsl:if>-->
          <xsl:value-of select="$string"/>
        </phrase>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="ens:wrapper-role" as="xs:string">
    <xsl:param name="orig-element" as="element(*)"/>
    <xsl:sequence 
      select="if (normalize-space($orig-element/@role))
              then
                for $r in tokenize($orig-element/@role, '\s+')
                return concat('ens_', local-name($orig-element), '.', $r)
              else
                concat('ens_', local-name($orig-element))"/>
  </xsl:function>
  
  <xsl:template match="@* | node()" mode="ens:default">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>