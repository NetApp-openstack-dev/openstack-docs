<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:d="http://docbook.org/ns/docbook" xmlns:date="http://exslt.org/dates-and-times">

    <xsl:import href="urn:docbkx:stylesheet"/>

    <!-- Abstract title should be NetApp blue -->
    <xsl:attribute-set name="abstract.title.properties">
        <xsl:attribute name="font-family">Gotham SSm</xsl:attribute>
        <xsl:attribute name="text-align">left</xsl:attribute>
        <xsl:attribute name="color">#0067c5</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="book.titlepage.recto.style">
        <xsl:attribute name="text-align">left</xsl:attribute>
        <xsl:attribute name="color">#454545</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="root.properties">
        <xsl:attribute name="font-family">Gotham SSm</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="table.table.properties">
        <xsl:attribute name="table-layout">fixed</xsl:attribute>
        <xsl:attribute name="width">100%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="monospace.verbatim.properties">
        <xsl:attribute name="wrap-option">wrap</xsl:attribute>
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="processing-instruction('db-font-size')">
                    <xsl:value-of select="processing-instruction('db-font-size')"/>
                </xsl:when>
                <xsl:otherwise>inherit</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:template name="book.titlepage.verso"/>
    <xsl:template name="book.titlepage.before.verso"/>
    <xsl:template name="book.titlepage.recto">
        <fo:block>
            <fo:table inline-progression-dimension="100%" table-layout="fixed">
                <fo:table-column column-width="1in"/>
                <fo:table-column column-width="4in"/>
                <fo:table-column column-width="1.5in"/>

                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block>
                                <fo:external-graphic width="100%" content-width="scale-to-fit">
                                    <xsl:attribute name="src">images/na_logo_vrt_2c_rgb.png</xsl:attribute>
                                </fo:external-graphic>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block>
                                <fo:external-graphic width="100%" content-width="scale-to-fit">
                                    <xsl:attribute name="src">images/built_for_openstack.png</xsl:attribute>
                                </fo:external-graphic>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row>
                        <fo:table-cell number-columns-spanned="3">
                            <fo:block text-align="center" padding-top="36pt" font-family="Gotham SSm Bold">
                                <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:title"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell number-columns-spanned="2">
                            <fo:block text-align="left" color="#454545" padding-top="12pt">
                                <xsl:apply-templates mode="titlepage.mode" select="d:info/d:authorgroup/d:author"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell number-columns-spanned="2">
                            <fo:block text-align="left" padding-top="8pt">
                                <xsl:apply-templates select="d:info/d:pubdate/processing-instruction()"/>
                                <xsl:text> | </xsl:text>
                                <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:releaseinfo"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell number-columns-spanned="2">
                            <fo:block text-align="left" padding-top="320pt">
                                <xsl:apply-templates select="d:info/d:abstract"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>

    <xsl:template match="d:title" mode="book.titlepage.recto.auto.mode">
        <fo:inline color="#0067c5" font-size="18">
            <xsl:apply-templates mode="titlepage.mode"/>
        </fo:inline>
    </xsl:template>

    <!-- ToC -->
    <xsl:template name="table.of.contents.titlepage" priority="1">
        <fo:block xsl:use-attribute-sets="section.title.level1.properties"
            space-after="12pt"
            font-weight="bold">
            <xsl:call-template name="gentext">
                <xsl:with-param name="key" select="'TableofContents'"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>

    <xsl:attribute-set name="toc.line.properties">
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="self::d:chapter or self::d:appendix">bold</xsl:when>
                <xsl:otherwise>normal</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="self::d:chapter or self::d:appendix">#0067c5</xsl:when>
                <xsl:otherwise>#454545</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:template name="list.of.tables.titlepage" priority="1">
        <fo:block xsl:use-attribute-sets="section.title.level1.properties"
            space-after="12pt"
            font-weight="bold">
            <xsl:call-template name="gentext">
                <xsl:with-param name="key" select="'ListofTables'"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>

    <xsl:template name="list.of.figures.titlepage" priority="1">
        <fo:block xsl:use-attribute-sets="section.title.level1.properties"
            space-after="12pt"
            font-weight="bold">
            <xsl:call-template name="gentext">
                <xsl:with-param name="key" select="'ListofFigures'"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>

    <!-- no headers -->
    <xsl:template name="header.content">
        <xsl:param name="pageclass" select="''"/>
        <xsl:param name="sequence" select="''"/>
        <xsl:param name="position" select="''"/>
        <xsl:param name="gentext-key" select="''"/>

        <fo:block>
            <xsl:choose>
                <xsl:when test="$sequence != 'blank' and $gentext-key != 'colophon' and $position = 'right' and $draft.mode='yes'">
                    <fo:inline color="#C8102E" font-size="18">
                        DRAFT
                    </fo:inline>
                </xsl:when>
            </xsl:choose>
        </fo:block>
    </xsl:template>

    <!-- footers -->
    <xsl:param name="symbol.font.family">Gotham SSm</xsl:param>
    <xsl:param name="dingbat.font.family">Gotham SSm</xsl:param>
    <xsl:param name="footer.column.widths">1 1 1</xsl:param>
    <xsl:attribute-set name="footer.content.properties">
        <xsl:attribute name="font-family">Gotham SSm</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="font-size">8pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:template name="footer.content">
        <xsl:param name="pageclass" select="''"/>
        <xsl:param name="sequence" select="''"/>
        <xsl:param name="position" select="''"/>
        <xsl:param name="gentext-key" select="''"/>

        <fo:block font-size="6.5">
            <xsl:choose>
                <xsl:when test="$sequence != 'blank' and $gentext-key != 'colophon' and $position = 'left'">
                    <fo:page-number/>
                </xsl:when>
                <xsl:when test="$sequence != 'blank' and $gentext-key != 'colophon' and $position = 'center'">
                    <xsl:value-of select="/d:book/d:titleabbrev/text()"/>
                </xsl:when>
                <xsl:when test="$sequence != 'blank' and $gentext-key != 'colophon' and $position = 'right'">
                    &#xA9; <xsl:value-of select="concat(date:year(), ' ')"/>NetApp, Inc. All rights reserved.
                </xsl:when>
            </xsl:choose>
        </fo:block>
    </xsl:template>

    <!-- Table header should have blue background, white font -->
    <xsl:template name="table.row.properties">
        <xsl:variable name="rownum">
            <xsl:number from="d:tbody" count="d:tr"/>
        </xsl:variable>
        <xsl:attribute name="font-size">8</xsl:attribute>
        <xsl:choose>
            <xsl:when test="ancestor::d:thead">
                <xsl:attribute name="font-weight">bold</xsl:attribute>
                <xsl:attribute name="color">#FFFFFF</xsl:attribute>
                <xsl:attribute name="background-color">#0067c5</xsl:attribute>
            </xsl:when>
            <xsl:when test="$rownum mod 2 = 0">
                <xsl:attribute name="background-color">#C8C9C7</xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Center captions above figures, tables, etc. -->
    <xsl:template name="formal.title.properties">
        <xsl:if test="not(self::d:table)">
            <xsl:attribute name="text-align">center</xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- Text should be NetApp deep gray -->
    <xsl:attribute-set name="root.properties">
        <xsl:attribute name="color">#454545</xsl:attribute>
    </xsl:attribute-set>

    <!-- Chapter titles should be NetApp blue -->
    <xsl:attribute-set name="component.title.properties">
        <xsl:attribute name="font-family">Gotham SSm Bold</xsl:attribute>
        <xsl:attribute name="color">#0067c5</xsl:attribute>
    </xsl:attribute-set>

    <!-- Section titles should use correct font -->
    <xsl:attribute-set name="section.title.properties">
        <xsl:attribute name="font-family">Gotham SSm Bold</xsl:attribute>
    </xsl:attribute-set>

    <!-- Colophon titles should use correct font -->
    <xsl:attribute-set name="component.title.properties">
        <xsl:attribute name="font-family">Gotham SSm Bold</xsl:attribute>
        <xsl:attribute name="color">#0067c5</xsl:attribute>
    </xsl:attribute-set>

    <!-- Hyperlinks should be NetApp blue -->
    <xsl:attribute-set name="xref.properties">
        <xsl:attribute name="color">#0067c5</xsl:attribute>
        <xsl:attribute name="text-decoration">underline</xsl:attribute>
    </xsl:attribute-set>

    <!-- Customize admonitions -->
    <xsl:attribute-set name="admonition.title.properties">
        <xsl:attribute name="font-style">italic</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="graphical.admonition.properties">
        <xsl:attribute name="border-top">0.5pt solid black</xsl:attribute>
        <xsl:attribute name="border-bottom">0.5pt solid black</xsl:attribute>
        <xsl:attribute name="padding-top">4pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">4pt</xsl:attribute>
    </xsl:attribute-set>

    <!-- Format Version History Table -->
    <xsl:attribute-set name="revhistory.title.properties">
        <xsl:attribute name="font-family">Gotham SSm Bold</xsl:attribute>
        <xsl:attribute name="font-size">18pt</xsl:attribute>
        <xsl:attribute name="text-align">left</xsl:attribute>
        <xsl:attribute name="color">#0067c5</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="revhistory.table.header.properties">
        <xsl:attribute name="text-align">center</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="color">#FFFFFF</xsl:attribute>
        <xsl:attribute name="background-color">#0067c5</xsl:attribute>
        <xsl:attribute name="border-start-style">solid</xsl:attribute>
        <xsl:attribute name="border-start-width">0.5pt</xsl:attribute>
        <xsl:attribute name="border-start-color">black</xsl:attribute>
        <xsl:attribute name="border-top-style">solid</xsl:attribute>
        <xsl:attribute name="border-top-width">0.5pt</xsl:attribute>
        <xsl:attribute name="border-top-color">black</xsl:attribute>
        <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
        <xsl:attribute name="border-bottom-width">0.5pt</xsl:attribute>
        <xsl:attribute name="border-bottom-color">black</xsl:attribute>
        <xsl:attribute name="border-end-style">solid</xsl:attribute>
        <xsl:attribute name="border-end-width">0.5pt</xsl:attribute>
        <xsl:attribute name="border-end-color">black</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="revhistory.table.cell.properties">
        <xsl:attribute name="padding-start">2pt</xsl:attribute>
        <xsl:attribute name="padding-end">2pt</xsl:attribute>
        <xsl:attribute name="padding-top">2pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">2pt</xsl:attribute>
        <xsl:attribute name="border-start-style">solid</xsl:attribute>
        <xsl:attribute name="border-start-width">0.5pt</xsl:attribute>
        <xsl:attribute name="border-start-color">black</xsl:attribute>
        <xsl:attribute name="border-top-style">solid</xsl:attribute>
        <xsl:attribute name="border-top-width">0.5pt</xsl:attribute>
        <xsl:attribute name="border-top-color">black</xsl:attribute>
        <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
        <xsl:attribute name="border-bottom-width">0.5pt</xsl:attribute>
        <xsl:attribute name="border-bottom-color">black</xsl:attribute>
        <xsl:attribute name="border-end-style">solid</xsl:attribute>
        <xsl:attribute name="border-end-width">0.5pt</xsl:attribute>
        <xsl:attribute name="border-end-color">black</xsl:attribute>
    </xsl:attribute-set>

    <xsl:template match="d:revhistory">
        <fo:block xsl:use-attribute-sets="revhistory.title.properties">
            <xsl:apply-templates select="d:title|d:info/d:title" mode="titlepage.mode"/>
        </fo:block>
        <fo:table table-layout="fixed" width="100%" xsl:use-attribute-sets="revhistory.table.properties">
            <fo:table-column column-number="1" column-width="1in"/>
            <fo:table-column column-number="2" column-width="1.25in"/>
            <fo:table-column column-number="3" column-width="4.25in"/>
            <fo:table-body start-indent="0pt" end-indent="0pt">
                <fo:table-row>
                    <fo:table-cell>
                        <fo:block xsl:use-attribute-sets="revhistory.table.header.properties">Version</fo:block>
                    </fo:table-cell>
                    <fo:table-cell>
                        <fo:block xsl:use-attribute-sets="revhistory.table.header.properties">Date</fo:block>
                    </fo:table-cell>
                    <fo:table-cell>
                        <fo:block xsl:use-attribute-sets="revhistory.table.header.properties">Document Version History</fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <xsl:apply-templates select="*[not(self::d:title)]"/>
            </fo:table-body>
        </fo:table>
    </xsl:template>

    <xsl:template match="d:revhistory/d:revision">
        <xsl:variable name="revnumber" select="d:revnumber"/>
        <xsl:variable name="revdate"   select="d:date"/>
        <xsl:variable name="revremark" select="d:revremark|d:revdescription"/>
        <fo:table-row>
            <fo:table-cell xsl:use-attribute-sets="revhistory.table.cell.properties">
                <fo:block>
                    <xsl:if test="$revnumber">
                        <xsl:text>Version</xsl:text>
                        <xsl:call-template name="gentext.space"/>
                        <xsl:apply-templates select="$revnumber[1]" mode="titlepage.mode"/>
                    </xsl:if>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell xsl:use-attribute-sets="revhistory.table.cell.properties">
                <fo:block>
                    <xsl:apply-templates select="$revdate[1]" mode="titlepage.mode"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell xsl:use-attribute-sets="revhistory.table.cell.properties">
                <fo:block>
                    <xsl:apply-templates select="$revremark[1]" mode="titlepage.mode"/>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>

    <!-- Format Back Page -->
    <xsl:template name="colophon.titlepage.recto">
        <fo:block>
            <fo:table inline-progression-dimension="100%" table-layout="fixed">
                <fo:table-column column-width="1in"/>
                <fo:table-column column-width="4in"/>
                <fo:table-column column-width="1.5in"/>

                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell number-columns-spanned="3">
                            <fo:block text-align="left" padding-top="36pt">
                                <fo:inline color="#0067c5" font-size="14" font-family="Gotham SSm Bold">
                                    <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:title"/>
                                </fo:inline>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row>
                        <fo:table-cell number-columns-spanned="3">
                            <fo:block>
                                <xsl:apply-templates mode="titlepage.mode" select="d:subtitle"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row>
                        <fo:table-cell number-columns-spanned="3">
                            <fo:block padding-top="24pt">
                                <xsl:apply-templates select="/d:book/d:info/d:revhistory"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <!-- note: some of the padding-top size may have to be shrunk in the future as the version history table grows in order to fit all content on a single page -->
                    <fo:table-row>
                        <fo:table-cell number-columns-spanned="3">
                            <fo:block padding-top="24pt" font-size="8pt">
                                Some content enclosed in this document was derived from the <fo:basic-link external-destination="url(http://docs.openstack.org/icehouse/config-reference/)"><fo:inline color="#0067c5" text-decoration="underline">OpenStack Configuration Reference</fo:inline></fo:basic-link>, available under the Apache License, Version 2.0. You may obtain a copy of the License at <fo:basic-link external-destination="url(http://www.apache.org/licenses/LICENSE-2.0)"><fo:inline color="#0067c5" text-decoration="underline">http://www.apache.org/licenses/LICENSE-2.0</fo:inline></fo:basic-link>.
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <!-- note: some of the padding-top size may have to be shrunk in the future as the version history table grows in order to fit all content on a single page -->
                    <fo:table-row>
                        <fo:table-cell number-columns-spanned="3">
                            <fo:block padding-top="24pt" font-size="9pt">
                                NetApp provides no representations or warranties regarding the accuracy, reliability, or serviceability of any information or recommendations provided in this publication, or with respect to any results that may be obtained by the use of the information or observance of any recommendations provided herein. The information in this document is distributed AS IS, and the use of this information or the implementation of any recommendations or techniques herein is a customer’s responsibility and depends on the customer’s ability to evaluate and integrate them into the customer’s operational environment. This document and the information contained herein may be used solely in connection with the NetApp products discussed in this document.
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <!-- note: some of the padding-top size may have to be shrunk in the future as the version history table grows in order to fit all content on a single page -->
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block padding-top="24pt">
                                <!-- this should be shifted into left margin rather than overlap to right -->
                                <fo:external-graphic width="100%" content-width="scale-to-fit">
                                    <xsl:attribute name="src">images/logo_url.png</xsl:attribute>
                                </fo:external-graphic>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell number-columns-spanned="2">
                            <fo:block padding-top="24pt" font-size="6pt">
                                &#xA9; <xsl:value-of select="concat(date:year(), ' ')"/> <xsl:value-of select="/d:book/d:info/d:copyright/d:holder"/> All rights reserved. No portions of this document may be reproduced without prior written consent of NetApp, Inc. Specifications are subject to change without notice. NetApp, the NetApp logo, Go further, faster, DataFabric, Data ONTAP, FlexClone, MultiStore, OnCommand, ONTAPI, and vFiler are trademarks or registered trademarks of NetApp, Inc. in the United States and/or other countries. Windows is a registered trademark of Microsoft Corporation. Linux is a registered trademark of Linus Torvalds. Java is a registered trademark of Oracle Corporation. All other brands or products are trademarks or registered trademarks of their respective holders and should be treated as such.
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>
</xsl:stylesheet>
