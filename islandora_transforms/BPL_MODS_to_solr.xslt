<?xml version="1.0" encoding="UTF-8"?>
<!-- BPL requires some indexing of cases not handled by standard MODS slurping -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:foxml="info:fedora/fedora-system:def/foxml#"
  xmlns:mods="http://www.loc.gov/mods/v3"
     exclude-result-prefixes="mods">

  <xsl:template match="mods:mods[1]" mode="slurp_for_bpl">
    <xsl:param name="prefix">bpl_mods_</xsl:param>
    <xsl:param name="suffix">_ms</xsl:param>


    <!--Non-date-typed regular name/namePart -->
    <xsl:for-each select="mods:name[@type='personal']/mods:namePart[not(@type='date')]">
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="concat($prefix, 'name_personal_namePart_not_date', $suffix)"/>
        </xsl:attribute>
        <xsl:value-of select="normalize-space(text())"/>
      </field>
    </xsl:for-each>

    <!-- Non-date-typed subject name/namePart -->
    <xsl:for-each select="mods:subject/mods:name[@type='personal']/mods:namePart[not(@type='date')]">
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="concat($prefix, 'subject_name_personal_namePart_not_date', $suffix)"/>
        </xsl:attribute>
        <xsl:value-of select="normalize-space(text())"/>
      </field>
    </xsl:for-each>

    <!-- Make sure subject/name/nameParts of all types are being indexed (no
         non-typed field is currently indexed for subject/name) -->
    <xsl:for-each select="mods:subject/mods:name/mods:namePart">
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="concat($prefix, 'subject_name_namePart', $suffix)"/>
        </xsl:attribute>
        <xsl:value-of select="normalize-space(text())"/>
      </field>
    </xsl:for-each>

    <!-- Lump faceted subject fields together -->
    <xsl:for-each select="mods:subject/mods:topic | mods:subject/mods:name[@type='personal']/mods:namePart[not(@type='date')]">
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="concat($prefix, 'faceted_subjects', $suffix)"/>
        </xsl:attribute>
        <xsl:value-of select="normalize-space(text())"/>
      </field>
    </xsl:for-each>

    <!-- Lump together all descendants of subject for advanced search -->
    <xsl:for-each select="mods:subject//*">
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="concat($prefix, 'all_subject_descendants', $suffix)"/>
        </xsl:attribute>
        <xsl:value-of select="normalize-space(text())"/>
      </field>
    </xsl:for-each>

    <!-- Concatenate geographic elements together using double-dashes -->
    <xsl:if test="mods:subject/mods:geographic">
      <!-- Get the value first so we can see if it's going to be an empty string -->
      <xsl:variable name="concatenated_geographic">
        <xsl:for-each select="mods:subject/mods:geographic">
          <xsl:value-of select="normalize-space(text())"/>
          <xsl:if test="position()!=last()">--</xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="$concatenated_geographic != ''">
        <field>
          <xsl:attribute name="name">
            <xsl:value-of select="concat($prefix, 'subject_geographic_concatenated', $suffix)"/>
          </xsl:attribute>
          <xsl:value-of select="$concatenated_geographic"/>
        </field>
      </xsl:if>
    </xsl:if>

    <!-- Concatenate title/nonSort with title -->
    <xsl:for-each select="mods:titleInfo[mods:nonSort and mods:title]">
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="concat($prefix, 'titleInfo_title_concatenated_nonSort', $suffix)"/>
        </xsl:attribute>
        <xsl:value-of select="concat(normalize-space(mods:nonSort/text()), ' ', normalize-space(mods:title/text()))"/>
      </field>
    </xsl:for-each>

    <!-- Concatenate physicalDescription/extent with the extent's @unit -->
    <xsl:for-each select="mods:physicalDescription/mods:extent[@unit]">
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="concat($prefix, 'physicalDescription_extent_concatenated_unit', $suffix)"/>
        </xsl:attribute>
        <xsl:value-of select="concat(normalize-space(text()), ' ', normalize-space(@unit))"/>
      </field>
    </xsl:for-each>

    <!-- Non-otherTyped relatedItem/titleInfo/title -->
    <xsl:for-each select="mods:relatedItem[not(@otherType)]/mods:titleInfo/mods:title">
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="concat($prefix, 'relatedItem_not_otherType_titleInfo_title', $suffix)"/>
        </xsl:attribute>
        <xsl:value-of select="normalize-space(text())"/>
      </field>
    </xsl:for-each>

    <!-- Non-typed note -->
    <xsl:for-each select="mods:note[not(@type)]">
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="concat($prefix, 'note_no_type', $suffix)"/>
        </xsl:attribute>
        <xsl:value-of select="normalize-space(text())"/>
      </field>
    </xsl:for-each>

    <!-- Both types of call numbers, for advanced search -->
    <xsl:for-each select="mods:identifier[@type='local-call-number'] | mods:identifier[@type='non-marc-call-number']">
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="concat($prefix, 'all_call_numbers', $suffix)"/>
        </xsl:attribute>
        <xsl:value-of select="normalize-space(text())"/>
      </field>
    </xsl:for-each>

    <!-- Both types of filing suffixes, for advanced search -->
    <xsl:for-each select="mods:identifier[@type='local-filing-suffix'] | mods:identifier[@type='non-marc-filing-suffix']">
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="concat($prefix, 'all_filing_suffixes', $suffix)"/>
        </xsl:attribute>
        <xsl:value-of select="normalize-space(text())"/>
      </field>
    </xsl:for-each>

  </xsl:template>
</xsl:stylesheet>
