<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:ens="http://www.le-tex.de/namespace/emphasis-normalize-space"
  exclude-result-prefixes="xs ens" version="2.0"> 

  <xsl:import href="../lib/docbook-same-scope.xsl"/>
  <xsl:import href="../lib/emphasis-normalize-space.xsl"/>

  <xsl:template match="/" mode="#default">
    <xsl:apply-templates mode="ens:default"/>
  </xsl:template>
  
  <xsl:template match="/processing-instruction()" mode="ens:default">
    <xsl:next-match/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

</xsl:stylesheet>