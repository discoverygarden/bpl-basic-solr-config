<?xml version="1.0" encoding="UTF-8"?>
<!-- BPL requires some indexing of cases not handled by standard MODS slurping -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:foxml="info:fedora/fedora-system:def/foxml#"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:exslt-string="http://exslt.org/strings"
  exclude-result-prefixes="mods">

  <!-- Gather all abstracts, typed or not -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:abstract">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'abstract_all_types'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Author / Donor custom field -->
  <xsl:template mode="slurp_for_bpl_author_donor" match="mods:mods/mods:name[@type='personal' or @type='corporate' or @type='author' or @type='donor']/mods:namePart[not(@type='date')]">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'author_donor'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
  </xsl:template>

  <!--Non-date-typed regular name/namePart -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:name[@type='personal']/mods:namePart[not(@type='date') and not(@type='termsOfAddress')]">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'name_personal_namePart_not_date_or_termsOfAddress'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="slurp_for_bpl_subjects" match="mods:name">
    <!-- Non-date-typed subject name/namePart -->
    <xsl:if test="@type='personal' and mods:namePart[not(@type='date') and not(@type='termsOfAddress')]">
      <xsl:call-template name="write_bpl_field">
        <xsl:with-param name="field_name" select="'subject_name_personal_namePart_not_date_or_termsOfAddress'"/>
        <xsl:with-param name="content" select="normalize-space(mods:namePart/text())"/>
      </xsl:call-template>
    </xsl:if>
    <!-- Make sure subject/name/nameParts of all types are being indexed (no
         non-typed field is currently indexed for subject/name) -->
    <xsl:if test="mods:namePart">
      <xsl:call-template name="write_bpl_field">
        <xsl:with-param name="field_name" select="'faceted_subjects'"/>
        <xsl:with-param name="content" select="normalize-space(mods:namePart/text())"/>
      </xsl:call-template>
      <xsl:call-template name="write_bpl_field">
        <xsl:with-param name="field_name" select="'subject_name_namePart_all_types'"/>
        <xsl:with-param name="content" select="normalize-space(mods:namePart/text())"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Lump faceted subject topic fields together with non-date-typed names from
       above. -->
  <xsl:template mode="slurp_for_bpl_subjects" match="mods:topic">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'faceted_subjects'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Lump together all descendants of subject for advanced search that haven't
       yet been lumped in -->
  <xsl:template mode="slurp_for_bpl_subject_descendants" match="mods:subject//*">
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
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:identifier[@type='local-call-number']">
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'all_call_numbers'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'all_call_numbers'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
      <xsl:with-param name="suffix" select="'_est'"/>
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
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:titleInfo">
    <xsl:variable name="title" select="normalize-space(mods:title)"/>
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'titleInfo_title'"/>
      <xsl:with-param name="content" select="$title"/>
    </xsl:call-template>
    <xsl:variable name="content">
      <xsl:choose>
        <xsl:when test="$title and mods:nonSort">
          <xsl:value-of select="concat(normalize-space(mods:nonSort/text()), ' ', normalize-space($title))"/>
        </xsl:when>
        <xsl:when test="$title and not(mods:nonSort)">
          <xsl:value-of select="normalize-space($title)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'titleInfo_title_concatenated_nonSort'"/>
      <xsl:with-param name="content" select="$content"/>
    </xsl:call-template>
    <!-- Concatenate subTitle with this concatenated field with ': ' -->
    <xsl:variable name="concatenated_title_nonSort_subTitle">
      <xsl:variable name="subtitle" select="normalize-space(mods:subTitle)"/>
      <xsl:value-of select="$content"/>
      <xsl:if test="$subtitle">
        <xsl:text>: </xsl:text>
        <xsl:value-of select="$subtitle"/>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'titleInfo_title_concatenated_nonSort_concatenated_subTitle'"/>
      <xsl:with-param name="content" select="$concatenated_title_nonSort_subTitle"/>
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
    <!-- Apply templates to children of subject -->
    <xsl:apply-templates mode="slurp_for_bpl_subjects" select="."/>
    <xsl:apply-templates mode="slurp_for_bpl_subject_descendants" select="."/>
  </xsl:template>

  <!-- Concatenate filing-suffix and call-number with space. -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods">
    <xsl:variable name="content">
      <xsl:choose>
        <xsl:when test="mods:identifier[@type='non-marc-filing-suffix'] and mods:identifier[@type='non-marc-call-number']">
          <xsl:value-of select="concat(normalize-space(mods:identifier[@type='non-marc-filing-suffix']/text()), ' ', normalize-space(mods:identifier[@type='non-marc-call-number']/text()))"/>
        </xsl:when>
        <xsl:when test="not(mods:identifier[@type='non-marc-filing-suffix']) and mods:identifier[@type='non-marc-call-number']">
          <xsl:value-of select="normalize-space(mods:identifier[@type='non-marc-call-number']/text())"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'identifier_non-marc-filing-suffix_concatenated_non-marc-call-number'"/>
      <xsl:with-param name="content" select="$content"/>
    </xsl:call-template>
    <xsl:apply-templates mode="slurp_for_bpl"/>
  </xsl:template>

  <!-- Fields created from the non-marc-call-number. -->
  <xsl:template mode="slurp_for_bpl" match="mods:mods/mods:identifier[@type = 'non-marc-call-number']">
    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="content" select="translate(normalize-space(text()), $uppercase, $lowercase)"/>
    <xsl:if test="not($content = '')">
      <!-- Create the custom field for sorting on call numbers.
         XXX: This is basically sorting alphanumerically, adding padding for numbers,
         and ignoring special characters like dashes, spaces, and brackets. This may
         break in some cases, as the call number data is messy.
         XXX: In an ideal world, we'd be on Solr 6+ and able to use query slop
         to force token ordering at query time with fancy padding. Instead,
         manually tokenize, set sort padding, and re-assemble/store so we can
         use an untokenized string to sort at query time. -->
      <xsl:call-template name="write_bpl_field">
        <xsl:with-param name="field_name" select="'identifier_non_marc_call_number'"/>
        <xsl:with-param name="content">
          <xsl:for-each select="exslt-string:tokenize($content, '-_ ()#,')">
            <xsl:variable name="token" select="normalize-space(.)"/>
            <xsl:choose>
              <xsl:when test="number($token) = number($token)">
                <xsl:value-of select="format-number(number($token), '000000')"/>
              </xsl:when>
              <!-- Check if last character is a letter and first character is a number. -->
              <xsl:when test="contains($lowercase, substring($token, string-length($token), 1)) and
                              number(substring($token, 1, 1)) = number(substring($token, 1, 1))">
                <!-- Split the string into two parts (number and suffix) and zero-pad the number part.
                     XXX: This will only work for strings that are of the form ([0-9]+)([a-zA-Z]+). -->
                <xsl:variable name="num_digits">
                  <xsl:call-template name="leading_digits">
                    <xsl:with-param name="text" select="$token"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="number" select="substring($token, 1, $num_digits)"/>
                <xsl:variable name="suffix" select="substring($token, $num_digits + 1)"/>
                <xsl:value-of select="format-number(number($number), '000000')"/>
                <xsl:value-of select="$suffix"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$token"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:with-param>
        <xsl:with-param name="suffix" select="'_ss'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'all_call_numbers'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
    </xsl:call-template>
    <xsl:call-template name="write_bpl_field">
      <xsl:with-param name="field_name" select="'all_call_numbers'"/>
      <xsl:with-param name="content" select="normalize-space()"/>
      <xsl:with-param name="suffix" select="'_est'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Helper template to get number of leading digits in a string. -->
  <xsl:template name="leading_digits">
    <xsl:param name="text"/>
    <xsl:param name="count" select="0"/>
    <xsl:choose>
      <xsl:when test="number(substring($text, 1, 1)) = number(substring($text, 1, 1))">
        <xsl:call-template name="leading_digits">
          <xsl:with-param name="text" select="substring($text, 2)"/>
          <xsl:with-param name="count" select="$count + 1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$count"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Does the actual Solr field writing -->
  <xsl:template name="write_bpl_field">
    <xsl:param name="field_name"/>
    <xsl:param name="content"/>
    <xsl:param name="suffix">_ms</xsl:param>

    <xsl:if test="not(normalize-space($content) = '')">
      <field>
        <xsl:attribute name="name">
          <xsl:value-of select="concat('bpl_mods_', $field_name, $suffix)"/>
        </xsl:attribute>
        <xsl:value-of select="$content"/>
      </field>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
