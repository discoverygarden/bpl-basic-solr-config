<?xml version="1.0" encoding="UTF-8"?>
<!-- BPL requires some indexing of cases not handled by standard MODS slurping -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:foxml="info:fedora/fedora-system:def/foxml#"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="mods">

  <!--Non-date-typed regular name/namePart -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:name[@type='personal']/mods:namePart[not(@type='date')]">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'name_personal_namePart_not_date'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Non-date-typed subject name/namePart -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:subject/mods:name[@type='personal']/mods:namePart[not(@type='date')]">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'subject_name_personal_namePart_not_date'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'faceted_subjects'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'all_subject_descendants'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Make sure subject/name/nameParts of all types are being indexed (no
       non-typed field is currently indexed for subject/name) -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:subject/mods:name/mods:namePart">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'subject_name_namePart_not_typed'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'all_subject_descendants'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Lump faceted subject topic fields together with non-date-typed names from
       above. -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:subject/mods:topic">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'faceted_subjects'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'all_subject_descendants'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Lump together all descendants of subject for advanced search -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:subject//*">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'all_subject_descendants'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Non-otherTyped relatedItem/titleInfo/title -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:relatedItem[not(@otherType)]/mods:titleInfo/mods:title">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'relatedItem_not_otherType_titleInfo_title'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Non-typed note -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:note[not(@type)]">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'note_no_type'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Both types of call numbers, for advanced search -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:identifier[@type='local-call-number'] | mods:identifier[@type='non-marc-call-number']">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'all_call_numbers'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Both types of filing suffixes, for advanced search -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:identifier[@type='local-filing-suffix'] | mods:identifier[@type='non-marc-filing-suffix']">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'all_filing_suffixes'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Concatenate title/nonSort with title -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:titleInfo[mods:nonSort and mods:title]">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'titleInfo_title_concatenated_nonSort'"/>
      <xsl:with-param name="content" select="concat(normalize-space(mods:nonSort/text()), ' ', normalize-space(mods:title/text()))"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Concatenate physicalDescription/extent with the extent's @unit -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:physicalDescription/mods:extent[@unit]">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'physicalDescription_extent_concatenated_unit'"/>
      <xsl:with-param name="content" select="concat(normalize-space(text()), ' ', normalize-space(@unit))"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Concatenate geographic elements together using double-dashes -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:subject">
    <!-- Concatenate geographic elements -->
    <xsl:variable name="concatenated_geographic">
      <xsl:for-each select="mods:geographic">
        <xsl:variable name="node_text" select="normalize-space(text())"/>
        <xsl:value-of select="$node_text"/>
        <xsl:if test="$node_text and position()!=last()">--</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'subject_geographic_concatenated'"/>
      <xsl:with-param name="content" select="$concatenated_geographic"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Does the actual Solr field writing -->
  <xsl:template name="write_bpl_field">
    <xsl:param name="field_name"/>
    <xsl:param name="content"/>

    <xsl:if test="not(normalize-space($content) = '')">
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="concat('bpl_mods_', $field_name, '_ms')"/>
        </xsl:attribute>
        <xsl:value-of select="$content"/>
      </field>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
