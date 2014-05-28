<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output cdata-section-elements="source alt href name download href alt source" />

 <!--  <xsl:template name="string-replace-substring">
    <xsl:param name="input"/>
    <xsl:param name="search"/>
    <xsl:param name="wrapper-element" select="'span'"/>
    <xsl:param name="wrapper-style" select="'background-color: papayawhip;'"/>
    <xsl:choose>
       <xsl:when test="not(contains($input, $search))">
         <xsl:value-of select="$input"/>
       </xsl:when>
       <xsl:otherwise>
         <xsl:value-of select="substring-before($input, $search)"/>

         <xsl:element name="{$wrapper-element}">
           <xsl:if test="$wrapper-style">
             <xsl:attribute name="style">
               <xsl:value-of select="$wrapper-style"/>
             </xsl:attribute>
           </xsl:if>
           <xsl:value-of select="$search"/>
         </xsl:element>
         <xsl:call-template name="wrap">
           <xsl:with-param name="input" select="substring-after($input, $search)"/>
           <xsl:with-param name="search" select="$search"/>
           <xsl:with-param name="wrapper-element" select="$wrapper-element"/>
           <xsl:with-param name="wrapper-style" select="$wrapper-style"/>
         </xsl:call-template>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:template> -->

  <xsl:template name="string-replace-all">
    <xsl:param name="text" />
    <xsl:param name="replace" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text"
          select="substring-after($text,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <xsl:template match="created/date">
    <xsl:variable name="date">
      <xsl:value-of select="normalize-space(text())"/>
    </xsl:variable>
    <created><xsl:value-of select="substring($date, 0, string-length($date)-5)" /></created>
  </xsl:template>

  <xsl:template name="image-field-fallback">
    <xsl:variable name="image_url">
      <xsl:call-template name="string-replace-all">
        <xsl:with-param name="text" select="*[local-name() = 'img-zoom' or local-name() = 'img-content' or local-name() = 'img']"/>
        <xsl:with-param name="replace" select="'/./'" />
        <xsl:with-param name="by" select="$export_host" />
      </xsl:call-template>
    </xsl:variable>    
    
    <xsl:if test="$image_url != ''">
      <image>      
        <href>
          <xsl:value-of select="normalize-space($image_url)" />
        </href>
        <alt><xsl:value-of select="*[local-name() = 'img-content-alt' or local-name() = 'img-alt']"/></alt>
        <description><xsl:value-of select="img-description" /></description>
        <source><xsl:value-of select="img-source" /></source>
      </image>
    </xsl:if>
  </xsl:template>



  <xsl:template name="content-image-sources">
    <xsl:param name="text" />
 
    <xsl:call-template name="string-replace-all">
      <xsl:with-param name="text" select="$text"/>
      <xsl:with-param name="replace" select="'/./img/content/'" />
      <xsl:with-param name="by" select="'/sites/default/files/static-images/'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="content-reddot-internal-links">
    <xsl:param name="text"/>

    <xsl:variable name="prefixed">
      <xsl:call-template name="string-replace-all">
        <xsl:with-param name="text" select="$text" />
        <xsl:with-param name="replace" select="'/./'"/>
        <xsl:with-param name="by" select="'/cps/rde/xchg/lebensmittelklarheit/hs.xsl/'" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="string-replace-all">
      <xsl:with-param name="text" select="$prefixed" />
      <xsl:with-param name="replace" select="'.xml'"/>
      <xsl:with-param name="by" select="'.htm'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="content-replace-urls">
    <xsl:param name="text" />

    <xsl:variable name="static_images">
      <xsl:call-template name="content-image-sources">
        <xsl:with-param name="text" select="normalize-space($text)" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="content-reddot-internal-links">
      <xsl:with-param name="text" select="$static_images" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="content">
      <xsl:call-template name="image-field-fallback"/>    
      <xsl:if test="normalize-space(../img-teaser/text()) != ''">
      <teaser-image>
        <xsl:variable name="teaser_image">
          <xsl:call-template name="string-replace-all">
            <xsl:with-param name="text" select="../img-teaser/text()"/>
            <xsl:with-param name="replace" select="'/./'" />
            <xsl:with-param name="by" select="$export_host" />
          </xsl:call-template>
        </xsl:variable>
        <href><xsl:value-of select="$teaser_image"/></href>
        <name><xsl:value-of select="../img-teaser-alt"/></name>
      </teaser-image>
      </xsl:if>
      <text>
      <xsl:call-template name="content-replace-urls">
        <xsl:with-param name="text" select="./text/text()" />
      </xsl:call-template>
      </text>
    
      <xsl:if test="count(.//downloads/download/href) > 0">
      <downloads>
        <xsl:apply-templates select=".//downloads/download/href" />
      </downloads>
      </xsl:if>
      <xsl:if test="count(links/link) > 0">
      <links>
        <xsl:apply-templates select="links/link" />
      </links>
      </xsl:if>
  </xsl:template>

  <xsl:template match="//downloads/download/href">
    <xsl:variable name="download">
      <xsl:call-template name="string-replace-all">
        <xsl:with-param name="text" select="text()"/>
        <xsl:with-param name="replace" select="'/./'" />
        <xsl:with-param name="by" select="$export_host" />
      </xsl:call-template>
    </xsl:variable>

    <download>
      <href><xsl:value-of select="$download" /></href>
      <name><xsl:value-of select="ancestor::download/name" /></name>
      
      <filename><xsl:value-of select="ancestor::download/description" /></filename>
    </download>
  </xsl:template>


  <xsl:template match="links/link">
    <xsl:for-each select="href[number(text()) != text()][not(contains(text(), 'http://www.lebensmittelklarheit.de'))]">
      <link>
        <href><xsl:value-of select="normalize-space(parent::link/href)" /></href>
        <name><xsl:value-of select="normalize-space(parent::link/name)" /></name>    
      </link>
    </xsl:for-each>
    <xsl:for-each select="href[number(text()) = text()]|href[contains(text(), 'http://www.lebensmittelklarheit.de')]">
      <xsl:variable name="reference_absolute">
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text" select="normalize-space(parent::link/href)"/>
          <xsl:with-param name="replace" select="'http://www.lebensmittelklarheit.de/cps/rde/xchg/lebensmittelklarheit/hs.xsl/'" />
          <xsl:with-param name="by" select="''" />
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="reference_relative">
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text" select="$reference_absolute"/>
          <xsl:with-param name="replace" select="'/./'" />
          <xsl:with-param name="by" select="''" />
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="reference">
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text" select="$reference_relative"/>
          <xsl:with-param name="replace" select="'.htm'" />
          <xsl:with-param name="by" select="''" />
        </xsl:call-template>
      </xsl:variable>
      <reference>
        <reddot-id><xsl:value-of select="$reference" /></reddot-id>
        <name><xsl:value-of select="normalize-space(parent::link/name)" /></name>    
      </reference>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>