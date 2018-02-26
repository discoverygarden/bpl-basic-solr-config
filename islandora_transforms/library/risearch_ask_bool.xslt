<xsl:stylesheet version="1.0"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:sparql="http://www.w3.org/2001/sw/DataAccess/rf1/result"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Template to make an ASK query and return the boolean result. -->
  <xsl:template name="risearch_ask_bool">
    <xsl:param name="risearch">http://localhost:8080/fedora/risearch</xsl:param>
    <xsl:param name="query"/>

    <xsl:variable name="encoded_query" select="encoder:encode(normalize-space($query))"/>
    <xsl:variable name="result">
      <xsl:copy-of select="document(concat($risearch, '?query=', $encoded_query, '&amp;lang=sparql'))"/>
    </xsl:variable>

    <xsl:value-of select="xalan:nodeset($result)/sparql:sparql/sparql:results/sparql:result/sparql:k0"/>

  </xsl:template>

</xsl:stylesheet>
