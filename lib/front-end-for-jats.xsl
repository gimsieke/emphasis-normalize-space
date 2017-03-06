<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ens="http://www.le-tex.de/namespace/emphasis-normalize-space"
  exclude-result-prefixes="ens xs" version="2.0"> 

  <xsl:import href="emphasis-normalize-space.xsl"/>

  <xsl:variable name="ens:inline-element-names" as="xs:string*"
    select="('styled-content', 
             'named-content', 
             'ext-link')"/>
  
  <xsl:variable name="ens:output-phrase-element-name" as="xs:string" 
    select="'styled-content'"/>
  <xsl:variable name="ens:output-phrase-element-namespace" as="xs:string"
    select="''"/>
  <xsl:variable name="ens:output-role-attribute-name" as="xs:string" 
    select="'style-type'"/>
  <xsl:variable name="ens:input-role-attribute-names" as="xs:string*" 
    select="('content-type', 'style-type')"/>
  
  <xsl:variable name="ens:scope-establishing-elements" as="xs:string*"
    select="('boxed-tex',
             'td',
             'th',
             'fig', 
             'fn', 
             'index-term',
             'list-item', 
             'table')"/>
    
</xsl:stylesheet>