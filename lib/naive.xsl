<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ens="http://www.le-tex.de/namespace/emphasis-normalize-space"
  exclude-result-prefixes="ens xs" version="2.0"> 

  <xsl:template match="*[local-name() = ('emphasis', 'link', 'phrase')]
                        [matches(., '\s$')]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="replace(., '\s+$', '')"/>
    </xsl:copy>
    <xsl:value-of select="replace(., '.+?(\s+)$', '$1')"/>
  </xsl:template>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>