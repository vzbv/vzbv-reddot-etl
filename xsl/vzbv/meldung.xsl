<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output cdata-section-elements="source alt href title subheadline text teaser href source description" />
<xsl:param name="export_host"/>
<xsl:template match="/">
  <article-pages>
    <xsl:for-each select="/pages/page">
      <article-page>
        <reddot-id><xsl:value-of select="normalize-space(id)"/></reddot-id>
        <guid><xsl:value-of select="normalize-space(guid)"/></guid>
        <title><xsl:value-of select="normalize-space(title)"/></title>
        <xsl:apply-templates select="created/date" />
        <subheadline><xsl:value-of select="normalize-space(content/headline)" /></subheadline>
        <teaser><xsl:value-of select="normalize-space(teaser)" /></teaser>
        

        
      </article-page>
    </xsl:for-each>
  </article-pages>
</xsl:template>
</xsl:stylesheet>