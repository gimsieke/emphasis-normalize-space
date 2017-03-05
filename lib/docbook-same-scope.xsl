<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs dbk" version="2.0"> 

  <xsl:function name="dbk:same-scope" as="xs:boolean">
    <xsl:param name="node" as="node()" />
    <xsl:param name="ancestor-elt" as="element(*)*" />
    <xsl:sequence 
      select="not(
                $node/ancestor::*[
                  local-name() = $dbk:same-scope-element-names]
                  [
                    some $a in ancestor::* 
                    satisfies (
                      some $b in $ancestor-elt 
                      satisfies ($a is $b))
                  ]
                )" />
  </xsl:function>
  
  <xsl:variable name="dbk:same-scope-element-names" as="xs:string*"
    select="('annotation', 
             'entry', 
             'blockquote', 
             'figure', 
             'footnote', 
             'listitem', 
             'table')"/>

</xsl:stylesheet>