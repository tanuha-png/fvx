<!--
    FOAF.Vix fvx-html.xsl (2010-03-18)
    Copyright (C) 2006, 2008, 2009, 2010 Wojciech Polak

    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the
    Free Software Foundation; either version 3 of the License, or (at your
    option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program.  If not, see <http://www.gnu.org/licenses/>.
  -->

<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:owl="http://www.w3.org/2002/07/owl#"
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  xmlns:bio="http://purl.org/vocab/bio/0.1/"
  xmlns:rel="http://purl.org/vocab/relationship"
  xmlns:rss="http://purl.org/rss/1.0/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dct="http://purl.org/dc/terms/"
  xmlns:contact="http://www.w3.org/2000/10/swap/pim/contact#"
  xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#"
  xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
  xmlns:ical="http://www.w3.org/2002/12/cal/icaltzd#"
  xmlns:doap="http://usefulinc.com/ns/doap#"
  xmlns:sioc="http://rdfs.org/sioc/ns#"
  xmlns:rsa="http://www.w3.org/ns/auth/rsa#"
  xmlns:cert="http://www.w3.org/ns/auth/cert#"
  xmlns:fvx="http://foaf-visualizer.org/"
  exclude-result-prefixes="xsl rdf rdfs owl foaf bio rel rss dc dct contact vcard geo ical doap sioc rsa cert fvx">

<xsl:output method="html"/>

<xsl:param name="VERSION">1.0</xsl:param>
<xsl:param name="HOST">http://foaf-visualizer.org/</xsl:param>
<xsl:param name="EMBED">0</xsl:param>
<xsl:param name="google_analytics"></xsl:param>

<xsl:variable name="URI" select="/rdf:RDF/fvx:fvx/fvx:uri"/>
<xsl:variable name="HASH" select="/rdf:RDF/fvx:fvx/fvx:hash"/>
<xsl:variable name="HL" select="/rdf:RDF/fvx:fvx/fvx:hl"/>

<xsl:key name="fvx:MSG"
	 match="/rdf:RDF/fvx:fvx/fvx:messagebundle/fvx:msg"
	 use="@id"/>

<xsl:key name="foaf:persons"
	 match="/rdf:RDF/foaf:Person |
		/rdf:RDF/contact:Male |
		/rdf:RDF/contact:Female |
		/rdf:RDF/sioc:User |
		/rdf:RDF/rdf:Description |
		/rdf:RDF/rsa:RSAPublicKey/cert:identity/rdf:Description"
	 use="@rdf:ID |
	      @rdf:nodeID |
	      @rdf:about"/>

<xsl:key name="doap:projects"
	 match="/rdf:RDF/doap:Project"
	 use="@rdf:ID |
	      @rdf:nodeID |
	      @rdf:about"/>

<xsl:template match="/">
  <xsl:choose>
    <xsl:when test="$EMBED = '1'">
      <div class="foafvix">
	<xsl:apply-templates select="rdf:RDF"/>
	<div class="poweredby">
	  <a href="{$HOST}" class="fvxlink small">
	    <xsl:value-of select="key('fvx:MSG', 'poweredBy')"/>
	    <xsl:text> </xsl:text>
	    <xsl:value-of select="$VERSION"/>
	  </a>
	</div>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <html>
	<head profile="http://www.w3.org/2006/03/hcard">
	  <title>FOAF</title>
	  <link rel="meta" type="application/rdf+xml" title="FOAF" href="{$URI}"/>
	  <link rel="shortcut icon" href="favicon.ico" type="image/x-icon"/>
	  <link rel="stylesheet" type="text/css" href="foaf-vix.css?v={$VERSION}"/>
	  <script type="text/javascript" src="foaf-vix.js?v={$VERSION}"></script>
	  <xsl:if test="$google_analytics != ''">
	    <script type="text/javascript" src="http://www.google-analytics.com/ga.js"></script>
	    <script type="text/javascript">if (typeof _gat != 'undefined') {
	      var tracker = _gat._getTracker ('<xsl:value-of select="$google_analytics"/>');
	      tracker._initData (); tracker._trackPageview (); }
	    </script>
	  </xsl:if>
	</head>
	<body>
	  <div class="foafvix">
	    <h1>
	      <img src="images/foaf.jpg" alt="[FOAF Logo]" />
	      <xsl:text> </xsl:text>
	      <xsl:value-of select="key('fvx:MSG', 'theFoafEntry')"/>
	      <xsl:text> </xsl:text>
	      <a class="fvxlink help" href="http://www.wikipedia.org/wiki/FOAF_(software)">
		<xsl:attribute name="title">
		  <xsl:value-of select="key('fvx:MSG', 'whatsThisTitle')"/>
		</xsl:attribute>
		<xsl:value-of select="key('fvx:MSG', 'whatsThis?')"/>
	      </a>
	    </h1>
	    <div id="swidth">
	      <xsl:apply-templates select="rdf:RDF"/>
	    </div>
	    <p id="footer">
	      <a class="fvxlink" href="./">FOAF.Vix <xsl:value-of select="$VERSION"/></a>
	      <xsl:text> Copyright (C) 2006-2010 </xsl:text>
	      <a class="fvxlink"
		 href="{$HOST}?uri=http://wojciechpolak.org/foaf.rdf">Wojciech Polak</a>
	    </p>
	  </div>
	</body>
      </html>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="/rdf:RDF">
  <xsl:variable
      name="DEFAULT"
      select="foaf:PersonalProfileDocument[1]/foaf:primaryTopic/@rdf:nodeID |
	      foaf:PersonalProfileDocument[1]/foaf:primaryTopic/@rdf:resource |
	      rsa:RSAPublicKey/cert:identity/rdf:Description/foaf:openid/foaf:PersonalProfileDocument/foaf:primaryTopic/@rdf:resource |
	      rdf:Description/foaf:primaryTopic/@rdf:resource |
	      rdf:Description[rdf:type/@rdf:resource = 'http://xmlns.com/foaf/0.1/PersonalProfileDocument']/foaf:primaryTopic/@rdf:nodeID"/>

  <xsl:choose>
    <xsl:when test="$HASH != '' and key('foaf:persons', $URI)">
      <xsl:apply-templates select="key('foaf:persons', $URI)"/>
    </xsl:when>

    <xsl:when test="$HASH != '' and key('doap:projects', $URI)">
      <xsl:apply-templates select="key('doap:projects', $URI)"/>
    </xsl:when>

    <xsl:otherwise>
      <xsl:choose>
	<xsl:when test="$DEFAULT != '' and key('foaf:persons', $DEFAULT)">
	  <xsl:apply-templates select="key('foaf:persons', $DEFAULT)"/>
	</xsl:when>

	<xsl:when test="foaf:Group/foaf:member">
	  <xsl:apply-templates select="foaf:Group"/>
	  <xsl:if test="foaf:Group/foaf:member/foaf:Person or
			foaf:Group/foaf:member/foaf:Agent">
	    <h2><xsl:value-of select="key('fvx:MSG', 'members')"/></h2>
	    <xsl:apply-templates select="foaf:Group/foaf:member/foaf:Person |
					 foaf:Group/foaf:member/foaf:Agent"/>
	  </xsl:if>
	</xsl:when>

	<xsl:when test="foaf:Organization/foaf:name">
	  <xsl:apply-templates select="foaf:Organization"/>
	  <xsl:if test="foaf:Organization/foaf:member/foaf:Person or
			foaf:Organization/foaf:member/foaf:Agent">
	    <h2><xsl:value-of select="key('fvx:MSG', 'members')"/></h2>
	    <xsl:apply-templates select="foaf:Organization/foaf:member/foaf:Person |
					 foaf:Organization/foaf:member/foaf:Agent"/>
	  </xsl:if>
	</xsl:when>

	<xsl:when test="foaf:Person[1] or
			foaf:PersonalProfileDocument/foaf:primaryTopic/foaf:Person[1] or
			foaf:PersonalProfileDocument//foaf:Person[not(parent::foaf:knows)] or
			foaf:PersonalProfileDocument//dct:Agent or
			rdf:Description//foaf:Person[not(parent::foaf:knows)] or
			rdf:Description//foaf:Agent[1] or
			dct:Agent[1]">
	  <xsl:apply-templates select="foaf:Person[1] |
				       foaf:PersonalProfileDocument/foaf:primaryTopic/foaf:Person[1] |
				       foaf:PersonalProfileDocument//foaf:Person[not(parent::foaf:knows)] |
				       foaf:PersonalProfileDocument//dct:Agent |
				       rdf:Description//foaf:Person[not(parent::foaf:knows)] |
				       rdf:Description//foaf:Agent[1] |
				       dct:Agent[1]"/>
	</xsl:when>

	<xsl:when test="doap:Project[1]">
	  <xsl:apply-templates select="doap:Project[1]"/>
	</xsl:when>

	<xsl:when test="rdf:Description[@rdf:about = $URI]/foaf:*">
	  <div class="person">
	    <xsl:apply-templates select="rdf:Description[@rdf:about = $URI]/foaf:*"/>
	  </div>
	</xsl:when>

	<xsl:when test="rdf:Description/foaf:*">
	  <xsl:apply-templates select="rdf:Description/foaf:*"/>
	</xsl:when>

	<xsl:otherwise>
	  <xsl:value-of select="key('fvx:MSG', 'unknownFormat')"/>
	  <p class="source">
	    <a href="{$URI}"><xsl:value-of select="$URI"/></a>
	  </p>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="foaf:Group |
		     foaf:Organization |
		     foaf:Person |
		     foaf:Agent |
		     contact:Male |
		     contact:Female |
		     dct:Agent |
		     rdf:Description[parent::cert:identity] |
		     rdf:Description[rdf:type/@rdf:resource = 'http://xmlns.com/foaf/0.1/Person']">
  <div class="vcard person">
    <xsl:choose>
      <xsl:when test="name() = 'foaf:Group' or
		      name() = 'foaf:Organization'">
	<xsl:attribute name="class">vcard group</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
	<xsl:attribute name="class">vcard person</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="$EMBED != '1'">
      <xsl:choose>
	<xsl:when test="foaf:img/@rdf:resource or
			foaf:img/foaf:Image/@rdf:about">
	  <img class="photo ownerImage"
	       src="{foaf:img/@rdf:resource |
		    foaf:img/foaf:Image/@rdf:about}"
	       alt="[image]"/>
	</xsl:when>
	<xsl:when test="foaf:depiction[1]/@rdf:resource">
	  <img class="photo ownerImage"
	       src="{foaf:depiction[1]/@rdf:resource}"
	       alt="[image]"/>
	</xsl:when>
	<xsl:when test="foaf:depiction[1]/foaf:Image/@rdf:about">
	  <img class="photo ownerImage"
	       src="{foaf:depiction[1]/foaf:Image/@rdf:about}"
	       alt="[image]"/>
	</xsl:when>
      </xsl:choose>
    </xsl:if>

    <xsl:if test="$EMBED = '1'">
      <xsl:choose>
	<xsl:when test="foaf:img/foaf:Image/foaf:thumbnail/@rdf:resource">
	  <img class="photo ownerImageSmall"
	       src="{foaf:img/foaf:Image/foaf:thumbnail/@rdf:resource}"
	       alt="[image]"/>
	</xsl:when>
	<xsl:when test="foaf:img/foaf:Image/@rdf:about or
			foaf:img/@rdf:resource">
	  <img class="photo ownerImageSmall"
	       src="{foaf:img/foaf:Image/@rdf:about |
		    foaf:img/@rdf:resource}"
	       alt="[image]"/>
	</xsl:when>
	<xsl:when test="foaf:depiction[1]/@rdf:resource">
	  <img class="photo ownerImageSmall"
	       src="{foaf:depiction[1]/@rdf:resource}"
	       alt="[image]"/>
	</xsl:when>
	<xsl:when test="foaf:depiction[1]/foaf:Image/@rdf:about">
	  <img class="photo ownerImageSmall"
	       src="{foaf:depiction[1]/foaf:Image/@rdf:about}"
	       alt="[image]"/>
	</xsl:when>
      </xsl:choose>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="foaf:firstName and foaf:surname">
	<div class="personName">
	  <span class="fn n person-name">
	    <span class="given-name">
	      <xsl:value-of select="foaf:firstName"/>
	    </span>
	    <xsl:text> </xsl:text>
	    <span class="family-name">
	      <xsl:value-of select="foaf:surname"/>
	    </span>
	  </span>
	</div>
      </xsl:when>
      <xsl:when test="foaf:givenName and foaf:familyName">
	<div class="personName">
	  <span class="fn n person-name">
	    <span class="given-name">
	      <xsl:value-of select="foaf:givenName"/>
	    </span>
	    <xsl:text> </xsl:text>
	    <span class="family-name">
	      <xsl:value-of select="foaf:familyName"/>
	    </span>
	  </span>
	</div>
      </xsl:when>
      <xsl:when test="foaf:givenname and foaf:family_name">
	<div class="personName">
	  <span class="fn n person-name">
	    <span class="given-name">
	      <xsl:value-of select="foaf:givenname"/>
	    </span>
	    <xsl:text> </xsl:text>
	    <span class="family-name">
	      <xsl:value-of select="foaf:family_name"/>
	    </span>
	  </span>
	</div>
      </xsl:when>
      <xsl:when test="foaf:name">
	<div class="personName">
	  <span class="fn person-name">
	    <xsl:value-of select="foaf:name"/>
	  </span>
	</div>
      </xsl:when>
    </xsl:choose>

    <table class="personalData" cellspacing="0">
      <xsl:if test="$EMBED = '1'">
	<xsl:attribute name="style">
	  <xsl:text>clear:both;</xsl:text>
	</xsl:attribute>
      </xsl:if>

      <xsl:if test="foaf:nick">
	<tr class="nick">
	  <td class="fieldName td1">
	    <xsl:choose>
	      <xsl:when test="name(..) = 'foaf:Group'">
		<xsl:value-of select="key('fvx:MSG', 'group:')"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="key('fvx:MSG', 'nick:')"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </td>
	  <td>
	    <xsl:apply-templates select="foaf:nick"/>
	  </td>
	</tr>
      </xsl:if>

      <xsl:choose>
	<xsl:when test="foaf:birthday">
	  <tr class="birthday">
	    <td class="fieldName td1">
	      <xsl:value-of select="key('fvx:MSG', 'birthday:')"/>
	    </td>
	    <td><xsl:value-of select="foaf:birthday"/></td>
	  </tr>
	</xsl:when>
	<xsl:when test="foaf:dateOfBirth or
			bio:event/bio:Birth/bio:date">
	  <tr class="dateOfBirth">
	    <td class="fieldName td1">
	      <xsl:value-of select="key('fvx:MSG', 'dateOfBirth:')"/>
	    </td>
	    <td>
	      <xsl:value-of select="foaf:dateOfBirth |
				    bio:event/bio:Birth/bio:date"/>
	    </td>
	  </tr>
	</xsl:when>
      </xsl:choose>

      <tr><td class="vspace"></td></tr>

      <xsl:apply-templates select="foaf:mbox"/>
      <xsl:apply-templates select="foaf:jabberID"/>
      <xsl:apply-templates select="foaf:icqChatID"/>
      <xsl:apply-templates select="foaf:msnChatID"/>
      <xsl:apply-templates select="foaf:aimChatID"/>
      <xsl:apply-templates select="foaf:yahooChatID"/>
      <xsl:apply-templates select="foaf:phone"/>

      <xsl:choose>
	<xsl:when test="foaf:homepage">
	  <xsl:apply-templates select="foaf:homepage"/>
	</xsl:when>
	<xsl:when test="foaf:page">
	  <xsl:apply-templates select="foaf:page"/>
	</xsl:when>
      </xsl:choose>

      <xsl:if test="foaf:weblog/@rdf:resource or
		    foaf:weblog/foaf:Document/@rdf:about or
		    foaf:blog/@rdf:resource">
	<tr class="weblog" valign="top">
	  <td class="fieldName td1">
	    <xsl:value-of select="key('fvx:MSG', 'weblog:')"/>
	  </td>
	  <td>
	    <a class="url">
	      <xsl:attribute name="href">
		<xsl:value-of select="foaf:weblog/@rdf:resource |
				      foaf:weblog/foaf:Document/@rdf:about |
				      foaf:blog/@rdf:resource"/>
	      </xsl:attribute>
	      <xsl:value-of select="foaf:weblog/@rdf:resource |
				    foaf:weblog/foaf:Document/@rdf:about |
				    foaf:blog/@rdf:resource"/>
	    </a>
	    <xsl:if test="rdfs:seeAlso/rss:channel or
			  foaf:weblog/foaf:Document/rdfs:seeAlso/@rdf:resource">
	      <xsl:text>&#160;&#160;</xsl:text>
	      <a>
		<xsl:attribute name="href">
		  <xsl:value-of select="rdfs:seeAlso/rss:channel/@rdf:about |
					foaf:weblog/foaf:Document/rdfs:seeAlso/@rdf:resource"/>
		</xsl:attribute>
		<img src="{$HOST}images/feed.png" style="vertical-align:middle"
		     alt="[webfeed]" />
	      </a>
	    </xsl:if>
	  </td>
	</tr>
      </xsl:if>

      <xsl:apply-templates select="contact:home |
				   vcard:ADR[@rdf:parseType = 'Resource']"/>

      <xsl:if test="foaf:workplaceHomepage or
		    foaf:workplaceHomePage">
	<tr><td class="vspace"></td></tr>
	<xsl:apply-templates select="foaf:workplaceHomepage |
				     foaf:workplaceHomePage"/>
      </xsl:if>

      <xsl:apply-templates select="contact:office"/>

      <xsl:if test="foaf:pubkeyAddress">
	<tr><td class="vspace"></td></tr>
	<xsl:apply-templates select="foaf:pubkeyAddress"/>
      </xsl:if>
    </table>

    <xsl:if test="foaf:holdsAccount/foaf:OnlineAccount/foaf:accountProfilePage or
		  foaf:holdsAccount/foaf:OnlineAccount/@rdf:about or
		  foaf:holdsAccount/@rdf:resource or
		  foaf:holdsAccount[@rdf:parseType='Resource']/foaf:accountProfilePage">
      <div class="onlineAccount">
	<div class="vspace fieldName">
	  <xsl:value-of select="key('fvx:MSG', 'onlineAccount:')"/>
	</div>
	<xsl:choose>
	  <xsl:when test="foaf:holdsAccount/foaf:OnlineAccount">
	    <xsl:apply-templates
		select="foaf:holdsAccount/foaf:OnlineAccount |
			../rdf:Description[rdf:type/@rdf:resource
			= 'http://xmlns.com/foaf/0.1/OnlineAccount']"/>
	  </xsl:when>
	  <xsl:when test="key('foaf:persons',
			  foaf:holdsAccount/@rdf:resource)">
	    <xsl:apply-templates select="key('foaf:persons',
					 foaf:holdsAccount/@rdf:resource)"/>
	  </xsl:when>
	  <xsl:when test="foaf:holdsAccount[@rdf:parseType='Resource']/foaf:accountProfilePage">
	    <xsl:apply-templates select="foaf:holdsAccount"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="foaf:holdsAccount/@rdf:resource"/>
	  </xsl:otherwise>
	</xsl:choose>
      </div>
    </xsl:if>

    <xsl:if test="foaf:plan">
      <div class="plan">
	<div class="vspace fieldName">
	  <xsl:value-of select="key('fvx:MSG', 'plan:')"/>
	</div>
	<div>
	  <xsl:value-of select="foaf:plan"/>
	</div>
      </div>
    </xsl:if>

    <xsl:if test="foaf:geekcode">
      <div class="geekcode">
	<div class="vspace fieldName">
	  <xsl:value-of select="key('fvx:MSG', 'geekcode:')"/>
	</div>
	<div>
	  <xsl:value-of select="foaf:geekcode"/>
	</div>
      </div>
    </xsl:if>

    <xsl:if test="rdfs:seeAlso/ical:Vcalendar/ical:component/ical:Vevent">
      <div class="seeAlso">
	<div class="vspace fieldName">
	  <xsl:value-of select="key('fvx:MSG', 'event:')"/>
	</div>
	<xsl:apply-templates
	    select="rdfs:seeAlso/ical:Vcalendar/ical:component/ical:Vevent"/>
      </div>
    </xsl:if>

    <xsl:if test="foaf:currentProject">
      <div class="currentProject">
	<div class="vspace fieldName">
	  <xsl:value-of select="key('fvx:MSG', 'currentProject:')"/>
	</div>
	<xsl:apply-templates select="foaf:currentProject"/>
      </div>
    </xsl:if>

    <xsl:if test="foaf:pastProject">
      <div class="pastProject">
	<div class="vspace fieldName">
	  <xsl:value-of select="key('fvx:MSG', 'pastProject:')"/>
	</div>
	<xsl:apply-templates select="foaf:pastProject"/>
      </div>
    </xsl:if>

    <xsl:if test="foaf:schoolHomepage">
      <div class="school">
	<div class="vspace fieldName">
	  <xsl:value-of select="key('fvx:MSG', 'school:')"/>
	</div>
	<xsl:apply-templates select="foaf:schoolHomepage"/>
      </div>
    </xsl:if>

    <xsl:if test="foaf:interest">
      <div class="interest">
	<div class="vspace fieldName">
	  <xsl:value-of select="key('fvx:MSG', 'interest:')"/>
	</div>
	<xsl:apply-templates select="foaf:interest"/>
      </div>
    </xsl:if>

    <xsl:if test="foaf:knows or rel:*">
      <xsl:variable name="max" select="'25'"/>
      <xsl:variable name="id" select="generate-id()"/>
      <div class="knows">
	<div class="vspace fieldName">
	  <xsl:value-of select="key('fvx:MSG', 'knows:')"/>
	</div>
	<xsl:choose>
	  <xsl:when test="$EMBED = '1' and count(foaf:knows) &gt; $max">
	    <xsl:apply-templates select="foaf:knows[position() &lt;= $max]"/>
	    <span id="fvxkms_{$id}" style="display:none">
	      <xsl:text>, </xsl:text>
	      <xsl:apply-templates select="foaf:knows[position() &gt; $max]"/>
	    </span>
	    <xsl:text> </xsl:text>
	    <a id="fvxkml_{$id}" href="#" class="more"
	       onclick="var _fvxkms=document.getElementById('fvxkms_{$id}');
			var _fvxkml=document.getElementById('fvxkml_{$id}');
			if (_fvxkml)_fvxkml.style.display='none';
			if (_fvxkms)_fvxkms.style.display='inline';
			return false;">
	      <xsl:value-of select="count(foaf:knows) - $max"/>
	      <xsl:text> </xsl:text>
	      <xsl:value-of select="key('fvx:MSG', 'more')"/>
	    </a>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="foaf:knows |
					 rel:*"/>
	  </xsl:otherwise>
	</xsl:choose>
      </div>
    </xsl:if>

    <xsl:if test="rdfs:seeAlso[not(rss:channel)]">
      <div class="seeAlso">
	<div class="vspace fieldName">
	  <xsl:value-of select="key('fvx:MSG', 'seeAlso:')"/>
	</div>
	<xsl:apply-templates select="rdfs:seeAlso[not(rss:channel)] |
				     rdfs:seeAlso/ical:Vcalendar"/>
      </div>
    </xsl:if>

    <xsl:if test="$EMBED != '1' and owl:sameAs">
      <div class="sameAs">
	<div class="vspace fieldName">
	  <xsl:if test="not(rdfs:seeAlso[not(rss:channel)])">
	    <xsl:value-of select="key('fvx:MSG', 'seeAlso:')"/>
	  </xsl:if>
	</div>
	<xsl:apply-templates select="owl:sameAs"/>
      </div>
    </xsl:if>

    <xsl:if test="$EMBED = '1'">
      <div class="expand">
	<a class="fvxlink small right">
	  <xsl:attribute name="href">
	    <xsl:value-of select="$HOST"/>
	    <xsl:text>?uri=</xsl:text>
	    <xsl:call-template name="string-replace">
	      <xsl:with-param name="subject" select="$URI"/>
	      <xsl:with-param name="search" select="'&amp;'"/>
	      <xsl:with-param name="replace" select="'%26'"/>
	    </xsl:call-template>
	    <xsl:if test="$HASH != ''">
	      <xsl:text>&amp;hash=</xsl:text>
	      <xsl:value-of select="$HASH"/>
	    </xsl:if>
	    <xsl:if test="$HL != ''">
	      <xsl:text>&amp;hl=</xsl:text>
	      <xsl:value-of select="$HL"/>
	    </xsl:if>
	  </xsl:attribute>
	  <xsl:value-of select="key('fvx:MSG', 'expand')"/>
	</a>
      </div>
    </xsl:if>
    <xsl:if test="$EMBED != '1'">
      <div class="source">
	<a href="{$URI}" class="fvxlink small right">
	  <xsl:value-of select="key('fvx:MSG', 'source')"/>
	</a>
      </div>
    </xsl:if>

  </div>
</xsl:template>

<xsl:template match="rdfs:seeAlso |
		     owl:sameAs">
  <div>
    <xsl:call-template name="seeAlsoLink">
      <xsl:with-param name="name">
	<xsl:call-template name="cutLongText">
	  <xsl:with-param name="txt" select="@dc:title |
					     @rdf:resource |
					     foaf:Document/@rdf:about |
					     rdf:Description/@rdf:about"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="href" select="@rdf:resource |
					  foaf:Document/@rdf:about |
					  rdf:Description/rdfs:seeAlso/@rdf:resource"/>
    </xsl:call-template>
  </div>
</xsl:template>

<xsl:template match="foaf:nick">
  <span class="nickname">
    <xsl:value-of select="."/>
  </span>
  <xsl:if test="position() != last()">
    <xsl:text>, </xsl:text>
  </xsl:if> 
</xsl:template>

<xsl:template match="foaf:homepage |
		     foaf:page">
  <xsl:call-template name="simpleAnchor">
    <xsl:with-param name="name" select="key('fvx:MSG', 'www')"/>
    <xsl:with-param name="href">
      <xsl:choose>
	<xsl:when test="@rdf:resource or
			foaf:Document/@rdf:about or
			rdf:Description/@rdf:about">
	  <xsl:value-of select="@rdf:resource |
				foaf:Document/@rdf:about |
				rdf:Description/@rdf:about"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="./text()"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
    <xsl:with-param name="class" select="'url uid'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foaf:workplaceHomepage |
		     foaf:workplaceHomePage">
  <xsl:call-template name="simpleAnchor">
    <xsl:with-param name="name">
      <xsl:if test="$EMBED = '1'">
	<xsl:value-of select="key('fvx:MSG', 'work')"/>
      </xsl:if>
      <xsl:if test="$EMBED != '1'">
	<xsl:value-of select="key('fvx:MSG', 'workplace')"/>
      </xsl:if>
    </xsl:with-param>
    <xsl:with-param name="href" select="./@rdf:resource |
					./foaf:Document/@rdf:about |
					./rdf:Description/@rdf:about"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foaf:schoolHomepage">
  <div>
    <a>
      <xsl:attribute name="href">
	<xsl:value-of select="./@rdf:resource |
			      ./foaf:Document/@rdf:about"/>
      </xsl:attribute>
      <xsl:call-template name="cutLongText">
	<xsl:with-param name="txt" select="./@rdf:resource |
					   ./foaf:Document/@rdf:about"/>
      </xsl:call-template>
    </a>
  </div>
</xsl:template>

<xsl:template match="foaf:holdsAccount/foaf:OnlineAccount |
		     foaf:holdsAccount[@rdf:parseType='Resource'] |
		     rdf:Description[rdf:type/@rdf:resource
		     = 'http://xmlns.com/foaf/0.1/OnlineAccount'] |
		     sioc:User[child::foaf:accountProfilePage]">
  <xsl:choose>
    <xsl:when test="foaf:accountProfilePage and
		    foaf:accountServiceHomepage">
      <a class="url">
	<xsl:attribute name="href">
	  <xsl:value-of select="foaf:accountProfilePage/@rdf:resource"/>
	</xsl:attribute>
	<xsl:attribute name="title">
	  <xsl:value-of select="foaf:accountServiceHomepage/@rdf:resource"/>
	</xsl:attribute>
	<xsl:if test="foaf:accountServiceHomepage/@rdf:resource">
	  <xsl:call-template name="favicon">
	    <xsl:with-param name="uri"
			    select="foaf:accountServiceHomepage/@rdf:resource"/>
	  </xsl:call-template>
	</xsl:if>
      </a>
    </xsl:when>
    <xsl:when test="@rdf:about and foaf:accountServiceHomepage">
      <a class="url">
	<xsl:attribute name="href">
	  <xsl:value-of select="@rdf:about"/>
	</xsl:attribute>
	<xsl:attribute name="title">
	  <xsl:value-of select="foaf:accountServiceHomepage/@rdf:resource"/>
	</xsl:attribute>
	<xsl:if test="foaf:accountServiceHomepage/@rdf:resource">
	  <xsl:call-template name="favicon">
	    <xsl:with-param name="uri"
			    select="foaf:accountServiceHomepage/@rdf:resource"/>
	  </xsl:call-template>
	</xsl:if>
      </a>
    </xsl:when>
  </xsl:choose>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="foaf:holdsAccount/@rdf:resource">
  <a>
    <xsl:attribute name="href">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <xsl:attribute name="title">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <xsl:call-template name="favicon">
      <xsl:with-param name="uri" select="."/>
    </xsl:call-template>
  </a>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="foaf:mbox">
  <xsl:if test="@rdf:resource">
    <xsl:call-template name="protoAnchor">
      <xsl:with-param name="name"  select="key('fvx:MSG', 'email')"/>
      <xsl:with-param name="href"  select="./@rdf:resource"/>
      <xsl:with-param name="proto" select="'mailto:'"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="foaf:phone">
  <xsl:call-template name="protoAnchor">
    <xsl:with-param name="name"  select="key('fvx:MSG', 'phone')"/>
    <xsl:with-param name="href"  select="./@rdf:resource"/>
    <xsl:with-param name="proto" select="'tel:'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foaf:jabberID">
  <xsl:call-template name="protoAnchor">
    <xsl:with-param name="name"  select="key('fvx:MSG', 'jabber')"/>
    <xsl:with-param name="href">
      <xsl:choose>
	<xsl:when test="@rdf:resource">
	  <xsl:value-of select="@rdf:resource"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
    <xsl:with-param name="proto" select="'xmpp:'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foaf:icqChatID">
  <xsl:call-template name="protoAnchor">
    <xsl:with-param name="name" select="key('fvx:MSG', 'icq')"/>
    <xsl:with-param name="href">
      <xsl:choose>
	<xsl:when test="@rdf:resource">
	  <xsl:value-of select="@rdf:resource"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
    <xsl:with-param name="proto" select="'icq:'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foaf:msnChatID">
  <xsl:call-template name="protoAnchor">
    <xsl:with-param name="name" select="key('fvx:MSG', 'msn')"/>
    <xsl:with-param name="href">
      <xsl:choose>
	<xsl:when test="@rdf:resource">
	  <xsl:value-of select="@rdf:resource"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
    <xsl:with-param name="proto" select="'msnim:'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foaf:aimChatID">
  <xsl:call-template name="protoAnchor">
    <xsl:with-param name="name" select="key('fvx:MSG', 'aim')"/>
    <xsl:with-param name="href">
      <xsl:choose>
	<xsl:when test="@rdf:resource">
	  <xsl:value-of select="@rdf:resource"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
    <xsl:with-param name="proto" select="'aim:'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foaf:yahooChatID">
  <xsl:call-template name="protoAnchor">
    <xsl:with-param name="name" select="key('fvx:MSG', 'yahoo')"/>
    <xsl:with-param name="href">
      <xsl:choose>
	<xsl:when test="@rdf:resource">
	  <xsl:value-of select="@rdf:resource"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
    <xsl:with-param name="proto" select="'ymsgr:'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="geo:Point|geo:location">
  <xsl:choose>
    <xsl:when test="rdf:Description/geo:lat">
      <xsl:call-template name="map-location">
	<xsl:with-param name="lat" select="rdf:Description/geo:lat"/>
	<xsl:with-param name="long" select="rdf:Description/geo:long"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="geo:lat">
      <xsl:call-template name="map-location">
	<xsl:with-param name="lat" select="geo:lat"/>
	<xsl:with-param name="long" select="geo:long"/>
      </xsl:call-template>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template name="map-location">
  <xsl:param name="lat"/>
  <xsl:param name="long"/>
  <a href="http://maps.google.com/maps?ll={normalize-space($lat)},{normalize-space($long)}&amp;spn=0.033,0.058">
    <img src="{$HOST}images/googlemaps.png" width="16" height="16"
	 alt="Google Maps" title="Google Maps" />
  </a>
  <span class="geo" style="display:none">
    <xsl:text>GEO:</xsl:text>
    <span class="latitude">
      <xsl:value-of select="$lat"/>
    </span>
    <span class="longitude">
      <xsl:value-of select="$long"/>
    </span>
  </span>
</xsl:template>

<xsl:template match="foaf:pubkeyAddress">
  <xsl:call-template name="simpleAnchor">
    <xsl:with-param name="name" select="key('fvx:MSG', 'pubkey')"/>
    <xsl:with-param name="href" select="./@rdf:resource"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foaf:knows |
		     rel:*">
  <xsl:choose>
    <xsl:when test="./foaf:Person">
      <xsl:apply-templates select="./foaf:Person"/>
    </xsl:when>
    <xsl:when test="@rdf:parseType = 'Resource'">
      <xsl:call-template name="seeAlsoLink">
	<xsl:with-param name="name" select="foaf:name"/>
	<xsl:with-param name="href" select="rdfs:seeAlso/@rdf:resource |
					    foaf:homepage/@rdf:resource |
					    foaf:weblog/@rdf:resource"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="@rdf:resource">
      <xsl:variable name="p" select="key('foaf:persons', @rdf:resource)"/>
      <xsl:call-template name="seeAlsoLink">
	<xsl:with-param name="name">
	  <xsl:choose>
	    <xsl:when test="$p">
	      <xsl:value-of select="$p/foaf:name |
				    $p/foaf:nick |
				    $p/foaf:holdsAccount/sioc:User/sioc:name |
				    $p/foaf:holdsAccount/foaf:OnlineAccount/foaf:homepage/@rdf:resource |
				    $p/rdf:value"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="@rdf:resource"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:with-param>
	<xsl:with-param name="href" select="@rdf:resource"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="@rdf:nodeID">
      <xsl:variable name="p" select="key('foaf:persons', @rdf:nodeID)"/>
      <xsl:choose>
	<xsl:when test="$p/rdfs:seeAlso/@rdf:resource">
	  <xsl:call-template name="seeAlsoLink">
	    <xsl:with-param name="name" select="$p/foaf:name |
						$p/foaf:nick"/>
	    <xsl:with-param name="href" select="$p/rdfs:seeAlso/@rdf:resource"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$p/foaf:name"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
  </xsl:choose>
  <xsl:if test="position() != last()">
    <xsl:text>, </xsl:text>
  </xsl:if> 
</xsl:template>

<xsl:template match="foaf:knows/foaf:Person |
		     rel:*/foaf:Person">
  <xsl:choose>
    <xsl:when test="rdfs:seeAlso">
      <xsl:call-template name="seeAlsoLink">
	<xsl:with-param name="name" select="foaf:name |
					    ./@foaf:name |
					    foaf:nick |
					    rdfs:seeAlso/@rdf:resource"/>
	<xsl:with-param name="href">
	  <xsl:choose>
	    <xsl:when test="rdfs:seeAlso/@rdf:resource">
	      <xsl:value-of select="rdfs:seeAlso/@rdf:resource"/>
	    </xsl:when>
	    <xsl:when test="foaf:homepage/@rdf:resource">
	      <xsl:value-of select="foaf:homepage/@rdf:resource"/>
	    </xsl:when>
	  </xsl:choose>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="@rdf:about">
      <xsl:call-template name="seeAlsoLink">
	<xsl:with-param name="name" select="foaf:name |
					    ./@foaf:name |
					    foaf:nick"/>
	<xsl:with-param name="href">
	  <xsl:value-of select="@rdf:about"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="foaf:homepage or
		    foaf:weblog">
      <a>
	<xsl:attribute name="href">
	  <xsl:value-of select="foaf:homepage/@rdf:resource |
				foaf:weblog/@rdf:resource |
				foaf:weblog/foaf:Document/@rdf:about"/>
	</xsl:attribute>
	<xsl:value-of select="foaf:name |
			      ./@foaf:name |
			      foaf:nick"/>
      </a>
    </xsl:when>
    <xsl:when test="foaf:mbox">
      <a>
	<xsl:attribute name="href">
	  <xsl:value-of select="foaf:mbox/@rdf:resource"/>
	</xsl:attribute>
	<xsl:call-template name="cutLongText">
	  <xsl:with-param name="txt"
			  select="substring-after(foaf:mbox/@rdf:resource, 'mailto:')"/>
	</xsl:call-template>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="foaf:name |
			    ./@foaf:name |
			    foaf:nick"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="position() != last()">
    <xsl:text>, </xsl:text>
  </xsl:if> 
</xsl:template>

<xsl:template match="foaf:interest">
  <div>
    <a>
      <xsl:attribute name="href">
	<xsl:value-of select="@rdf:resource |
			      rdf:Description/@rdf:about |
			      foaf:Document/@rdf:about"/>
      </xsl:attribute>
      <xsl:value-of select="@rdf:resource |
			    rdf:Description/@dc:title |
			    rdf:Description/@dct:title |
			    rdf:Description/dc:title |
			    rdf:Description/dct:title |
			    @dc:title |
			    rdf:Description/@rdfs:label |
			    rdf:Description/rdfs:label |
			    foaf:Document/dc:title |
			    foaf:Document/@rdf:about"/>
    </a>
  </div>
</xsl:template>

<xsl:template match="foaf:currentProject |
		     foaf:pastProject">
  <div>
    <a>
      <xsl:attribute name="href">
	<xsl:value-of select="@rdf:resource |
			      rdf:Description/@rdf:about |
			      foaf:Project/@rdf:about |
			      foaf:Project/foaf:homepage/@rdf:resource |
			      foaf:Project/rdfs:seeAlso/@rdf:resource |
			      foaf:Project/dc:identifier/@rdf:resource |
			      doap:Project/doap:homepage/@rdf:resource |
			      doap:Project/rdf:Description/@rdf:about"/>
      </xsl:attribute>
      <xsl:value-of select="@rdf:resource |
			    rdf:Description/@dc:title |
			    rdf:Description/dc:title |
			    rdf:Description/dct:title |
			    rdf:Description/@rdfs:label |
			    foaf:Project/foaf:name |
			    foaf:Project/dc:title |
			    foaf:Project/rdfs:label[1] |
			    doap:Project/dc:title |
			    doap:Project/rdf:Description/rdfs:label"/>
    </a>
    <xsl:if test="$EMBED != '1' and
		  (rdf:Description/dc:description or
		  foaf:Project/dc:description)">
      <xsl:text> - </xsl:text>
      <xsl:value-of select="rdf:Description/dc:description |
			    foaf:Project/dc:description"/>
    </xsl:if>
  </div>
</xsl:template>

<xsl:template match="contact:home |
		     contact:office">
  <tr><td class="vspace"></td></tr>
  <tr valign="top">
    <td colspan="2" class="fieldName">
      <xsl:if test="local-name() = 'home'">
	<xsl:value-of select="key('fvx:MSG', 'homeAddress:')"/>
      </xsl:if>
      <xsl:if test="local-name() = 'office'">
	<xsl:value-of select="key('fvx:MSG', 'officeAddress:')"/>
      </xsl:if>
    </td>
  </tr>
  <tr valign="top">
    <td colspan="2" style="padding-left:7px">
      <xsl:apply-templates
	  select="contact:address |
		  ../../contact:ContactLocation[@rdf:about = current()/@rdf:resource]"/>
      <xsl:apply-templates select="geo:location|geo:Point|contact:address/geo:Point"/>
      <xsl:if test="geo:lat and geo:long">
	<xsl:call-template name="map-location">
	  <xsl:with-param name="lat" select="geo:lat"/>
	  <xsl:with-param name="long" select="geo:long"/>
	</xsl:call-template>
      </xsl:if>
    </td>
  </tr>
</xsl:template>

<xsl:template match="contact:ContactLocation">
  <xsl:apply-templates select="contact:address |
			       contact:address/contact:Address"/>
</xsl:template>

<xsl:template match="contact:address |
		     contact:Address">
  <span class="adr">
    <xsl:if test="contact:street2">
      <span class="extended-address">
	<xsl:value-of select="contact:street2"/>
      </span>
      <br />
    </xsl:if>
    <span class="street-address">
      <xsl:value-of select="contact:street"/>
    </span>
    <br />
    <span class="locality">
      <xsl:value-of select="contact:city"/>
    </span>
    <xsl:text> </xsl:text>
    <span class="postal-code">
      <xsl:value-of select="contact:postalCode"/>
    </span>
    <br />
    <span class="country-name">
      <xsl:value-of select="contact:country"/>
    </span>
  </span>
</xsl:template>

<xsl:template match="vcard:ADR">
  <tr><td class="vspace"></td></tr>
  <tr valign="top">
    <td colspan="2" class="fieldName">
      <xsl:value-of select="key('fvx:MSG', 'homeAddress:')"/>
    </td>
  </tr>
  <tr valign="top">
    <td colspan="2" style="padding-left:7px">
      <span class="adr">
	<xsl:if test="vcard:Street2">
	  <span class="extended-address">
	    <xsl:value-of select="vcard:Street2"/>
	  </span>
	  <br />
	</xsl:if>
	<span class="street-address">
	  <xsl:value-of select="vcard:Street"/>
	</span>
	<br />
	<span class="locality">
	  <xsl:value-of select="vcard:Locality"/>
	</span>
	<br />
	<span class="region">
	  <xsl:value-of select="vcard:Region"/>
	</span>
	<xsl:text> </xsl:text>
	<span class="postal-code">
	  <xsl:value-of select="vcard:Pcode"/>
	</span>
	<br />
	<span class="country-name">
	  <xsl:value-of select="vcard:Country"/>
	</span>
      </span>
    </td>
  </tr>
</xsl:template>

<xsl:template match="ical:Vcalendar">
  <xsl:call-template name="seeAlsoLink">
    <xsl:with-param name="name">
      <xsl:call-template name="cutLongText">
	<xsl:with-param name="txt" select="@rdf:about"/>
      </xsl:call-template>
    </xsl:with-param>
    <xsl:with-param name="href" select="@rdf:about"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="ical:Vcalendar/ical:component/ical:Vevent">
  <div class="vevent">
    <a class="url">
      <xsl:attribute name="href">
	<xsl:value-of select="@rdf:about"/>
      </xsl:attribute>
      <span class="summary">
	<xsl:value-of select="ical:summary"/>
      </span>
    </a>
    <xsl:if test="$EMBED != '1' and ical:description">
      <xsl:text> - </xsl:text>
      <xsl:value-of select="ical:description[1]"/>
    </xsl:if>
    <xsl:text>, </xsl:text>
    <span class="dtstart">
      <xsl:value-of select="ical:dtstart"/>
    </span>
    <xsl:text> - </xsl:text>
    <span class="dtend">
      <xsl:value-of select="ical:dtend"/>
    </span>
    <span class="location" style="display:none">
      <xsl:value-of select="ical:location"/>
    </span>
    <xsl:if test="ical:geo">
      <xsl:call-template name="map-location">
	<xsl:with-param name="lat"
			select="substring-before(ical:geo, ',')"/>
	<xsl:with-param name="long"
			select="substring-after(ical:geo, ',')"/>
      </xsl:call-template>
    </xsl:if>
  </div>
</xsl:template>

<xsl:template name="simpleAnchor">
  <xsl:param name="name"/>
  <xsl:param name="href"/>
  <xsl:param name="class" select="'url'"/>
  <tr valign="top">
    <td class="fieldName td1">
      <xsl:value-of select="$name"/>
      <xsl:text>: </xsl:text>
    </td>
    <td>
      <a class="{$class}">
	<xsl:attribute name="href">
	  <xsl:value-of select="$href"/>
	</xsl:attribute>
	<xsl:value-of select="$href"/>
      </a>
    </td>
  </tr>
</xsl:template>

<xsl:template name="protoAnchor">
  <xsl:param name="name"/>
  <xsl:param name="href"/>
  <xsl:param name="proto"/>
  <xsl:if test="$href != ''">
    <tr>
      <td class="fieldName td1">
	<xsl:value-of select="$name"/>
	<xsl:text>: </xsl:text>
      </td>
      <td>
	<xsl:choose>
	  <xsl:when test="contains($href, $proto)">
	    <a>
	      <xsl:attribute name="class">
		<xsl:choose>
		  <xsl:when test="$proto = 'mailto:'">
		    <xsl:text>email</xsl:text>
		  </xsl:when>
		  <xsl:when test="$proto = 'tel:'">
		    <xsl:text>tel</xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:text>url</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
	      </xsl:attribute>
	      <xsl:attribute name="href">
		<xsl:value-of select="$href"/>
	      </xsl:attribute>
	      <xsl:value-of select="substring-after($href, $proto)"/>
	    </a>
	  </xsl:when>
	  <xsl:when test="not(contains($href, $proto)) and
			  not(contains($href, ':'))">
	    <a>
	      <xsl:attribute name="class">
		<xsl:choose>
		  <xsl:when test="$proto = 'mailto:'">
		    <xsl:text>email</xsl:text>
		  </xsl:when>
		  <xsl:when test="$proto = 'tel:'">
		    <xsl:text>tel</xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:text>url</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
	      </xsl:attribute>
	      <xsl:attribute name="href">
		<xsl:value-of select="concat($proto, $href)"/>
	      </xsl:attribute>
	      <xsl:value-of select="$href"/>
	    </a>
	  </xsl:when>
	  <xsl:otherwise>
	    <a>
	      <xsl:attribute name="class">
		<xsl:choose>
		  <xsl:when test="$proto = 'mailto:'">
		    <xsl:text>email</xsl:text>
		  </xsl:when>
		  <xsl:when test="$proto = 'tel:'">
		    <xsl:text>tel</xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:text>url</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
	      </xsl:attribute>
	      <xsl:attribute name="href">
		<xsl:value-of select="$href"/>
	      </xsl:attribute>
	      <xsl:value-of select="$href"/>
	    </a>
	  </xsl:otherwise>
	</xsl:choose>
      </td>
    </tr>
  </xsl:if>
</xsl:template>

<xsl:template name="seeAlsoLink">
  <xsl:param name="name"/>
  <xsl:param name="href"/>
  <a>
    <xsl:attribute name="href">
      <xsl:value-of select="$HOST"/>
      <xsl:text>?uri=</xsl:text>
      <xsl:choose>
	<xsl:when test="contains($href, '#')">
          <xsl:call-template name="string-replace">
            <xsl:with-param name="subject" select="substring-before($href, '#')"/>
            <xsl:with-param name="search" select="'&amp;'"/>
            <xsl:with-param name="replace" select="'%26'"/>
          </xsl:call-template>
	  <xsl:text disable-output-escaping="yes">&amp;hash=</xsl:text>
	  <xsl:value-of select="substring-after($href, '#')"/>
	</xsl:when>
	<xsl:otherwise>
          <xsl:call-template name="string-replace">
            <xsl:with-param name="subject" select="$href"/>
            <xsl:with-param name="search" select="'&amp;'"/>
            <xsl:with-param name="replace" select="'%26'"/>
          </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$HL != ''">
	<xsl:text>&amp;hl=</xsl:text>
	<xsl:value-of select="$HL"/>
      </xsl:if>
    </xsl:attribute>
    <xsl:call-template name="cutLongText">
      <xsl:with-param name="txt" select="$name"/>
    </xsl:call-template>
  </a>
</xsl:template>

<xsl:template match="doap:Project">
  <div class="Project">
    <xsl:if test="doap:name">
      <div class="doapName">
	<span class="name project-name">
	  <xsl:value-of select="doap:name"/>
	</span>
      </div>
    </xsl:if>

    <table class="projectData" cellspacing="0">
      <xsl:if test="doap:homepage">
	<xsl:call-template name="simpleAnchor">
	  <xsl:with-param name="name" select="key('fvx:MSG', 'www')"/>
	  <xsl:with-param name="href" select="doap:homepage/@rdf:resource |
					      doap:homepage/text()"/>
	</xsl:call-template>
      </xsl:if>
    </table>

    <xsl:if test="doap:description or doap:shortdesc">
      <div class="doapDescription">
	<div class="vspace fieldName">
	  <xsl:value-of select="key('fvx:MSG', 'description')"/>
	</div>
	<xsl:choose>
	  <xsl:when test="doap:description">
	    <div class="description">
	      <xsl:value-of select="doap:description"/>
	    </div>
	  </xsl:when>
	  <xsl:when test="doap:shortdesc">
	    <div class="shortdesc">
	      <xsl:value-of select="doap:shortdesc"/>
	    </div>
	  </xsl:when>
	</xsl:choose>
      </div>
    </xsl:if>
  </div>

  <xsl:if test="doap:maintainer or doap:developer or
		doap:documenter or doap:translator or
		doap:tester or doap:helper">
    <h2><xsl:value-of select="key('fvx:MSG', 'members')"/></h2>
    <xsl:apply-templates select="doap:maintainer/foaf:Person"/>
    <xsl:apply-templates select="doap:developer/foaf:Person"/>
    <xsl:apply-templates select="doap:documenter/foaf:Person"/>
    <xsl:apply-templates select="doap:translator/foaf:Person"/>
    <xsl:apply-templates select="doap:tester/foaf:Person"/>
    <xsl:apply-templates select="doap:helper/foaf:Person"/>
  </xsl:if>
</xsl:template>

<xsl:template name="favicon">
  <xsl:param name="uri"/>
  <xsl:variable name="H">
    <xsl:call-template name="strip-trailing-slashes">
      <xsl:with-param name="s" select="$uri"/>
    </xsl:call-template>
  </xsl:variable>
  <img src="{$H}/favicon.ico" width="16" height="16" alt=""
       onerror="this.src='{$HOST}/images/world.png'"/>
</xsl:template>

<xsl:template name="strip-trailing-slashes">
  <xsl:param name="s"/>
  <xsl:choose>
    <xsl:when test="substring($s, string-length($s)) = '/'">
      <xsl:call-template name="strip-trailing-slashes">
	<xsl:with-param name="s" select="substring($s, 1,
					 string-length($s) - 1)"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$s"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="string-replace">
  <xsl:param name="subject"/>
  <xsl:param name="search"/>
  <xsl:param name="replace"/>
  <xsl:choose>
    <xsl:when test="contains($subject, $search)">
      <xsl:variable name="before" select="substring-before($subject, $search)"/>
      <xsl:variable name="after" select="substring-after($subject, $search)"/>
      <xsl:value-of select="$before"/>
      <xsl:value-of select="$replace"/>
      <xsl:call-template name="string-replace">
        <xsl:with-param name="subject" select="$after"/>
        <xsl:with-param name="search" select="$search"/>
        <xsl:with-param name="replace" select="$replace"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$subject"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="cutLongText">
  <xsl:param name="txt"/>
  <xsl:param name="len">30</xsl:param>
  <xsl:choose>
    <xsl:when test="$EMBED = '1' and string-length($txt) > $len">
      <xsl:variable name="l" select="string-length($txt)"/>
      <xsl:variable name="n" select="round($len div 2)"/>
      <xsl:value-of select="concat(substring($txt, 0, $n - 3), '...',
			           substring($txt, $l - $n, $l))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$txt"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
