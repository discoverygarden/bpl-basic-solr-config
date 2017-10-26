<xsl:stylesheet version="1.0"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:string="xalan://java.lang.String"
  xmlns:sparql="http://www.w3.org/2001/sw/DataAccess/rf1/result"
  xmlns:dgi-e="xalan://ca.discoverygarden.gsearch_extensions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Determines if a constituent has an OBJ attached or in S3. -->
  <xsl:template name="constituent_obj_attached_or_in_s3">
    <xsl:param name="pid"/>
    <xsl:param name="fedorauser"/>
    <xsl:param name="fedorapass"/>
    <!-- XXX: Kept separate as one supports Basic Auth where the other requires
         creds to be passed in to the datastream dissemination function. -->
    <xsl:param name="fedora_endpoint">http://localhost:8080/fedora</xsl:param>
    <xsl:param name="fedora_risearch">http://localhost:8080/fedora/risearch</xsl:param>
    <!-- Parameter-ized for potential added specificity. -->
    <xsl:param name="constituent_obj_query">
      PREFIX fm: &lt;info:fedora/fedora-system:def/model#&gt;
      PREFIX fv: &lt;info:fedora/fedora-system:def/view#&gt;
      PREFIX fre: &lt;info:fedora/fedora-system:def/relations-external#&gt;
      SELECT ?constituent
      FROM &lt;#ri&gt;
      WHERE {
        &lt;info:fedora/%PID%&gt; fm:hasModel &lt;info:fedora/islandora:compoundCModel&gt; .
        ?constituent fre:isConstituentOf &lt;info:fedora/%PID%&gt; .
        ?constituent fv:disseminates ?ds .
        ?ds fv:disseminationType &lt;info:fedora/*/S3_MANIFEST&gt;
      }
    </xsl:param>

    <!-- Query the RI for constituents. -->
    <xsl:variable name="ri_pid_graph">
      <xsl:copy-of select="document(concat($fedora_risearch, '?query=', encoder:encode(string:replaceAll($constituent_obj_query, '%PID%', $pid)), '&amp;lang=sparql'))"/>
    </xsl:variable>

    <!-- XXX: Feels pretty hack-y, but there's no satisfactory way to write a
         nodeset mapper in XSLT 1.0, so instead, map to string and ask if the
         expected value was contained therein. -->
    <xsl:variable name="pidlist">
      <xsl:for-each select="xalan:nodeset($ri_pid_graph)//*[@uri]">
          <xsl:value-of select="boolean(dgi-e:JSONToXML.convertJSONToDocument(dgi-e:FedoraUtils.getRawDatastreamDissemination(substring-after(@uri, 'info:fedora/'), 'S3_MANIFEST', $fedora_endpoint, $fedorauser, $fedorapass))//datastreams/OBJ)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="contains($pidlist, 'true')"/>

  </xsl:template>

</xsl:stylesheet>
