<xsl:stylesheet version="1.0"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:string="http://www.w3.org/2001/sw/DataAccess/rf1/result"
  xmlns:sparql="http://www.w3.org/2001/sw/DataAccess/rf1/result"
  xmlns:dgi-e="xalan://ca.discoverygarden.gsearch_extensions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Determines if this object, or a constituent's, has an OBJ. -->
  <xsl:template name="constituent_obj_attached_or_in_s3">
    <xsl:param name="pid"/>
    <xsl:param name="drupal_endpoint">http://localhost</xsl:param>

    <!-- Do the query. -->
    <xsl:variable name="query_result">
      <xsl:copy-of select="document(concat($drupal_endpoint, '/islandora_s3_backup/constituent_manifest_query/', $pid, '/OBJ'))"/>
    </xsl:variable>

    <xsl:value-of select="boolean($query_result/constituent_info/dsid_entry)"/>

  </xsl:template>

</xsl:stylesheet>
