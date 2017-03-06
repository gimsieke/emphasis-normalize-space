<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ens="http://www.le-tex.de/namespace/emphasis-normalize-space"
  exclude-result-prefixes="ens xs" version="2.0"> 

  <xsl:import href="emphasis-normalize-space.xsl"/>

  <xsl:variable name="ens:inline-element-names" as="xs:string*"
    select="('hi', 
             'link', 
             'distinct',
             'emph',
             'foreign',
             'gloss',
             'name')"/>
  
  <xsl:variable name="ens:output-phrase-element-name" as="xs:string" 
    select="'hi'"/>
  <xsl:variable name="ens:output-phrase-element-namespace" as="xs:string"
    select="'http://www.tei-c.org/ns/1.0'"/>
  <xsl:variable name="ens:output-role-attribute-name" as="xs:string" 
    select="'rend'"/>
  <xsl:variable name="ens:input-role-attribute-names" as="xs:string*" 
    select="('type', 'rend')"/>
  
  <xsl:variable name="ens:scope-establishing-elements" as="xs:string*"
    select="('cell', 
             'figure', 
             'note', 
             'index',
             'item', 
             'table')"/>
    
</xsl:stylesheet>