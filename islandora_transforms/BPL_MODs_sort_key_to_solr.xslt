<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:foxml="info:fedora/fedora-system:def/foxml#"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:cdm="http://www.oclc.org/contentdm"
  exclude-result-prefixes="mods cdm xalan">

  <xsl:template name="bpl-sort-key-string-replace">
    <xsl:param name="string" />
    <xsl:param name="replace" />
    <xsl:param name="with" />
    <xsl:choose>
      <xsl:when test="contains($string, $replace)">
        <xsl:value-of select="substring-before($string, $replace)" />
        <xsl:value-of select="$with" />
        <xsl:call-template name="bpl-sort-key-string-replace">
          <xsl:with-param name="string" select="substring-after($string,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="with" select="$with" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string" />
      </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="bpl-sort-key-lower-case">
  <xsl:param name="string"/>
  <xsl:value-of select="translate($string,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
</xsl:template>

<!-- punctuation list not comprehensive, just covers what appears in call numbers -->
<xsl:template name="bpl-sort-key-no-punct">
  <xsl:param name="string"/>
  <xsl:value-of select="translate($string,',./#-()','')"/>
</xsl:template>

<xsl:template name="bpl-sort-key-no-punct-space">
  <xsl:param name="string"/>
  <xsl:value-of select="translate($string,',./#-() ','')"/>
</xsl:template>

<xsl:template name="bpl-sort-key-tokenizeString">
  <xsl:param name="list"/>
  <xsl:param name="delimiter"/>
    <xsl:choose>
      <xsl:when test="contains($list, $delimiter)">
        <token>
          <!-- get everything in front of the first delimiter -->
          <xsl:value-of select="substring-before($list,$delimiter)"/>
        </token>
        <xsl:call-template name="bpl-sort-key-tokenizeString">
          <!-- store anything left in another variable -->
          <xsl:with-param name="list" select="substring-after($list,$delimiter)"/>
          <xsl:with-param name="delimiter" select="$delimiter"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$list = ''">
            <xsl:text/>
          </xsl:when>
          <xsl:otherwise>
            <token>
              <xsl:value-of select="$list"/>
            </token>
          </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- prototype to build sort string from call number permutations -->
<xsl:template mode="slurp_for_bpl_sort_key" match="mods:mods/mods:identifier[@type = 'non-marc-call-number']">

    <xsl:for-each select=".">
      <xsl:variable name="value-repl-slash">
        <xsl:call-template name="bpl-sort-key-string-replace">
          <xsl:with-param name="string" select="normalize-space(.)"/>
          <xsl:with-param name="replace" select="'/'"/>
          <xsl:with-param name="with" select="'-'"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="value-repl-space">
        <xsl:call-template name="bpl-sort-key-string-replace">
          <xsl:with-param name="string" select="$value-repl-slash"/>
          <xsl:with-param name="replace" select="' '"/>
          <xsl:with-param name="with" select="'-'"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="value">
        <xsl:call-template name="bpl-sort-key-lower-case">
          <xsl:with-param name="string" select="$value-repl-space"/>
        </xsl:call-template>
      </xsl:variable>
      <!-- the value, represented as digits and non digits -->
      <xsl:variable name="value-d-D">
        <xsl:value-of select="translate($value,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz','ddddddddddDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD')"/>
      </xsl:variable>
      <xsl:variable name="sort-key">
        <xsl:choose>
          <!-- first and most common permutation: {Collection #}-{Box #}-{Envelope or Folder #} -->
          <!-- this test does work with addition level (fourth '-#') though -->
          <!-- equivalent of matches($value,'^\d{3}-') -->
          <xsl:when test="starts-with($value-d-D,'ddd')">
            <xsl:variable name="value-tokens">
              <xsl:call-template name="bpl-sort-key-tokenizeString">
                <xsl:with-param name="list" select="$value"/>
                <xsl:with-param name="delimiter" select="'-'"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="value-tokens-ln">
                <xsl:call-template name="bpl-sort-key-tokenizeString">
                  <xsl:with-param name="list" select="$value-d-D"/>
                  <xsl:with-param name="delimiter" select="'-'"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:for-each select="xalan:nodeset($value-tokens)/token">
                <!-- record position so we can reference letters and numbers version of token -->
                <xsl:variable name="position" select="position()"/>
                <!-- now get reference token -->
                <xsl:variable name="token-ln" select="xalan:nodeset($value-tokens-ln)/token[position() = $position]"/>
                <!-- get last two characters in reference token for test -->
                <xsl:variable name="token-ln-last2" select="substring($token-ln,string-length(.) - 1)"/>
                <!-- NOTE: order of these important. DO NOT alter. -->
                <xsl:choose>
                  <!-- when parens with box/envelope ranges shows up, e.g. 328-1-(256-259) use floor of range -->
                  <!-- equivalent of matches(.,'^\(\d+') -->
                  <xsl:when test="starts-with($token-ln,'(d')">
                    <!-- equivalent, but not as good as replace(.,'^\((\d+)','$1')-->
                    <xsl:variable name="floor" select="translate(.,'(','')"/>
                    <xsl:value-of select="format-number(number($floor),'0000')"/>
                  </xsl:when>
                  <!-- when contains parens but does not start with a number, just make an alphanumeric key -->
                  <!-- equivalent of matches(.,'^\(\D') -->
                  <xsl:when test="starts-with($token-ln,'(D')">
                    <xsl:call-template name="bpl-sort-key-no-punct">
                      <xsl:with-param name="string" select="."/>
                    </xsl:call-template>
                  </xsl:when>
                  <!-- the ceiling goes away for ranges -->
                  <!-- equivalent of matches(.,'\d+\)$'), adjustment made for tokenizing on space
                       since fouls up call numbers with 'vol.' -->
                  <xsl:when test="$token-ln-last2 = 'd)'">
                    <xsl:choose>
                      <xsl:when test="not(contains($value,'vol'))"/>
                      <xsl:otherwise>
                        <xsl:call-template name="bpl-sort-key-no-punct-space">
                          <xsl:with-param name="string" select="."/>
                        </xsl:call-template>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <!-- no letters, format number -->
                  <!-- equivalent of not(matches(.,'\D')) -->
                  <xsl:when test="not(contains($token-ln,'D'))">
                    <xsl:value-of select="format-number(number(.),'0000')"/>
                  </xsl:when>
                  <!-- single letter, use -->
                  <!-- equivalent of matches(.,'^\D$') -->
                  <xsl:when test="$token-ln = 'D'">
                    <xsl:value-of select="concat(.,'000')"/>
                  </xsl:when>
                  <!-- when has number(s), letter(s), e.g. 207-1000-1a -->
                  <!-- equivalent of matches(.,'\d+\D+'). Dodgy? -->
                  <xsl:when test="contains($token-ln,'dD')">
                    <!--<xsl:variable name="numbers" select="replace(.,'(\d+)(\D+)','$1')"/>
                    <xsl:variable name="letters" select="replace(.,'(\d+)(\D+)','$2')"/>-->
                    <xsl:variable name="numbers" select="translate(.,'abcdefghijklmnopqrstuvwxyz','')"/>
                    <xsl:variable name="letters" select="translate(.,'0123456789','')"/>
                    <xsl:value-of select="concat(format-number(number($numbers),'0000'),$letters)"/>
                  </xsl:when>
                  <!-- when has letters, numbers, e.g. 208-sc7-9-1 -->
                  <!-- equivalent of matches(.,'\D+\d+') -->
                  <xsl:when test="contains($token-ln,'Dd')">
  <!--                                        <xsl:variable name="letters" select="replace(.,'(\D+)(\d+)','$1')"/>
                    <xsl:variable name="numbers" select="replace(.,'(\D+)(\d+)','$2')"/>
                    -->
                    <xsl:variable name="numbers" select="translate(.,'abcdefghijklmnopqrstuvwxyz','')"/>
                    <xsl:variable name="letters" select="translate(.,'0123456789','')"/>
                    <xsl:value-of select="concat($letters, format-number(number($numbers),'0000'))"/>
                  </xsl:when>
                  <!-- may be all letters, as for substitutions of names or addresses for box and envelope -->
                  <!-- equivalent of not(matches(.,'\d')) -->
                  <xsl:when test="not(contains($token-ln,'d'))">
                    <!--<xsl:value-of select="lower-case(replace(.,'\W',''))"/>-->
                    <xsl:call-template name="bpl-sort-key-no-punct">
                      <xsl:with-param name="string" select="."/>
                    </xsl:call-template>
                  </xsl:when>
                </xsl:choose>
              </xsl:for-each>
            </xsl:when>
            <!-- maps -->
            <!-- equivalent of matches(lower-case($value),'^map') -->
            <xsl:when test="starts-with($value,'map')">
              <!--<xsl:value-of select="lower-case(replace(.,'\W',''))"/>-->
              <xsl:call-template name="bpl-sort-key-no-punct-space">
                <xsl:with-param name="string" select="$value"/>
              </xsl:call-template>
            </xsl:when>
         <!-- where space is used and names/addresses sub'd for box and envelope -->
         <!-- equivalent of matches($value,'\d+\s+\D') -->
         <xsl:when test="contains($value-d-D,'d D')">
           <!-- xslt2: tokenize(.,'[\s-]')
                Performing tokenization on just space here as including '-' was a CYA,
                we'll see how it works....
           -->
           <xsl:variable name="value-tokens">
             <xsl:call-template name="bpl-sort-key-tokenizeString">
               <xsl:with-param name="list" select="$value"/>
               <xsl:with-param name="delimiter" select="' '"/>
             </xsl:call-template>
           </xsl:variable>
           <xsl:variable name="value-tokens-ln">
             <xsl:call-template name="bpl-sort-key-tokenizeString">
               <xsl:with-param name="list" select="$value-d-D"/>
               <xsl:with-param name="delimiter" select="' '"/>
             </xsl:call-template>
           </xsl:variable>
           <xsl:for-each select="xalan:nodeset($value-tokens)/token">
             <!-- record position so we can reference letters and numbers version of token -->
             <xsl:variable name="position" select="position()"/>
             <!-- now get reference token -->
             <xsl:variable name="token-ln" select="xalan:nodeset($value-tokens-ln)/token[position() = $position]"/>
             <xsl:choose>
               <!-- when is number -->
               <!-- equivlent of not(matches(.,'\D')) -->
               <xsl:when test="not(contains($token-ln,'D'))">
                 <xsl:value-of select="format-number(number(.),'0000')"/>
               </xsl:when>
               <xsl:otherwise>
                 <xsl:value-of select="."/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:when>
            <!-- if all else fails and does not match given formats....-->
            <xsl:otherwise>
              <!--<xsl:value-of select="lower-case(replace(.,'\W',''))"/>-->
              <xsl:call-template name="bpl-sort-key-no-punct">
                <xsl:with-param name="string" select="."/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="write_sort_key_field">
          <xsl:with-param name="field_name" select="'call_number_sort_key'"/>
          <xsl:with-param name="content" select="$sort-key"/>
        </xsl:call-template>
      </xsl:for-each>
  </xsl:template>

  <!-- Does the actual Solr field writing -->
  <xsl:template name="write_sort_key_field">
  <xsl:param name="field_name"/>
  <xsl:param name="content"/>

  <xsl:if test="not(normalize-space($content) = '')">
    <field>
      <xsl:attribute name="name">
        <xsl:value-of select="concat('bpl_mods_', $field_name, '_ss')"/>
      </xsl:attribute>
      <xsl:value-of select="$content"/>
    </field>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
