<!--
    FOAF.Vix fvx-json.xsl (2010-03-18)
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

<xsl:output method="text"/>

<xsl:param name="HOST">http://foaf-visualizer.org/</xsl:param>

<xsl:variable name="URI" select="/rdf:RDF/fvx:fvx/fvx:uri"/>
<xsl:variable name="HASH" select="/rdf:RDF/fvx:fvx/fvx:hash"/>
<xsl:variable name="HL" select="/rdf:RDF/fvx:fvx/fvx:hl"/>

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
  <xsl:text>{</xsl:text>
  <xsl:apply-templates select="rdf:RDF"/>
  <xsl:text>"generator":"</xsl:text>
  <xsl:value-of select="$HOST"/>
  <xsl:text>"}</xsl:text>
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
      <xsl:text>"vcard":</xsl:text>
      <xsl:apply-templates select="key('foaf:persons', $URI)"/>
    </xsl:when>

    <xsl:when test="$HASH != '' and key('doap:projects', $URI)">
      <xsl:text>"project":</xsl:text>
      <xsl:apply-templates select="key('doap:projects', $URI)"/>
    </xsl:when>

    <xsl:otherwise>
      <xsl:choose>
	<xsl:when test="$DEFAULT != '' and key('foaf:persons', $DEFAULT)">
	  <xsl:text>"vcard":</xsl:text>
	  <xsl:apply-templates select="key('foaf:persons', $DEFAULT)"/>
	</xsl:when>

	<xsl:when test="foaf:Group/foaf:member">
	  <xsl:text>"vcard":</xsl:text>
	  <xsl:apply-templates select="foaf:Group"/>
	  <xsl:if test="foaf:Group/foaf:member/foaf:Person or
			foaf:Group/foaf:member/foaf:Agent">
	    <xsl:text>"members":[</xsl:text>
	    <xsl:apply-templates select="foaf:Group/foaf:member/foaf:Person |
					 foaf:Group/foaf:member/foaf:Agent"/>
	    <xsl:text>],</xsl:text>
	  </xsl:if>
	</xsl:when>

	<xsl:when test="foaf:Organization/foaf:name">
	  <xsl:text>"vcard":</xsl:text>
	  <xsl:apply-templates select="foaf:Organization"/>
	  <xsl:if test="foaf:Organization/foaf:member/foaf:Person or
			foaf:Organization/foaf:member/foaf:Agent">
	    <xsl:text>"members":[</xsl:text>
	    <xsl:apply-templates select="foaf:Organization/foaf:member/foaf:Person |
					 foaf:Organization/foaf:member/foaf:Agent"/>
	    <xsl:text>],</xsl:text>
	  </xsl:if>
	</xsl:when>

	<xsl:when test="foaf:Person[1] or
			foaf:PersonalProfileDocument/foaf:primaryTopic/foaf:Person[1] or
			foaf:PersonalProfileDocument//foaf:Person[not(parent::foaf:knows)] or
			foaf:PersonalProfileDocument//dct:Agent or
			rdf:Description//foaf:Person[not(parent::foaf:knows)] or
			rdf:Description//foaf:Agent[1] or
			dct:Agent[1]">
	  <xsl:text>"vcard":</xsl:text>
	  <xsl:apply-templates select="foaf:Person[1] |
				       foaf:PersonalProfileDocument/foaf:primaryTopic/foaf:Person[1] |
				       foaf:PersonalProfileDocument//foaf:Person[not(parent::foaf:knows)] |
				       foaf:PersonalProfileDocument//dct:Agent |
				       rdf:Description//foaf:Person[not(parent::foaf:knows)] |
				       rdf:Description//foaf:Agent[1] |
				       dct:Agent[1]"/>
	</xsl:when>

	<xsl:when test="doap:Project[1]">
	  <xsl:text>"project":</xsl:text>
	  <xsl:apply-templates select="doap:Project[1]"/>
	</xsl:when>

	<xsl:when test="rdf:Description[@rdf:about = $URI]/foaf:*">
	  <xsl:text>"vcard":</xsl:text>
	  <xsl:apply-templates select="rdf:Description[@rdf:about = $URI]/foaf:*"/>
	</xsl:when>

	<xsl:when test="rdf:Description/foaf:*">
	  <xsl:text>"vcard":</xsl:text>
	  <xsl:apply-templates select="rdf:Description/foaf:*"/>
	</xsl:when>

	<xsl:otherwise>
	  <xsl:text>unknownFormat</xsl:text>
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

  <xsl:text>{</xsl:text>

  <xsl:choose>
    <xsl:when test="foaf:firstName and foaf:surname">
      <xsl:text>"fn":{"givenName":</xsl:text>
      <xsl:apply-templates select="foaf:firstName[1]" mode="sv"/>
      <xsl:text>,"familyName":</xsl:text>
      <xsl:apply-templates select="foaf:surname[1]" mode="sv"/>
      <xsl:text>},</xsl:text>
    </xsl:when>
    <xsl:when test="foaf:givenName and foaf:familyName">
      <xsl:text>"fn":{"givenName":</xsl:text>
      <xsl:apply-templates select="foaf:givenName[1]" mode="sv"/>
      <xsl:text>,</xsl:text>
      <xsl:text>"familyName":</xsl:text>
      <xsl:apply-templates select="foaf:familyName[1]" mode="sv"/>
      <xsl:text>},</xsl:text>
    </xsl:when>
    <xsl:when test="foaf:givenname and foaf:family_name">
      <xsl:text>"fn":{"givenName":</xsl:text>
      <xsl:apply-templates select="foaf:givenname[1]" mode="sv"/>
      <xsl:text>,</xsl:text>
      <xsl:text>"familyName":</xsl:text>
      <xsl:apply-templates select="foaf:family_name[1]" mode="sv"/>
      <xsl:text>},</xsl:text>
    </xsl:when>
    <xsl:when test="foaf:name">
      <xsl:text>"fn":{"name":</xsl:text>
      <xsl:apply-templates select="foaf:name[1]" mode="sv"/>
      <xsl:text>},</xsl:text>
    </xsl:when>
  </xsl:choose>

  <xsl:if test="foaf:nick">
    <xsl:text>"nick":[</xsl:text>
    <xsl:apply-templates select="foaf:nick"/>
    <xsl:text>],</xsl:text>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="foaf:img/@rdf:resource or
		    foaf:img/foaf:Image/@rdf:about">
      <xsl:text>"photo":"</xsl:text>
      <xsl:value-of select="foaf:img/@rdf:resource |
			    foaf:img/foaf:Image/@rdf:about"/>
      <xsl:text>",</xsl:text>
    </xsl:when>
    <xsl:when test="foaf:depiction[1]/@rdf:resource">
      <xsl:text>"photo":"</xsl:text>
      <xsl:value-of select="foaf:depiction[1]/@rdf:resource"/>
      <xsl:text>",</xsl:text>
    </xsl:when>
    <xsl:when test="foaf:depiction[1]/foaf:Image/@rdf:about">
      <xsl:text>"photo":"</xsl:text>
      <xsl:value-of select="foaf:depiction[1]/foaf:Image/@rdf:about"/>
      <xsl:text>",</xsl:text>
    </xsl:when>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="foaf:birthday">
      <xsl:text>"birthday":"</xsl:text>
      <xsl:value-of select="foaf:birthday"/>
      <xsl:text>",</xsl:text>
    </xsl:when>
    <xsl:when test="foaf:dateOfBirth or
		    bio:event/bio:Birth/bio:date">
      <xsl:text>"dateOfBirth":"</xsl:text>
      <xsl:value-of select="foaf:dateOfBirth |
			    bio:event/bio:Birth/bio:date"/>
      <xsl:text>",</xsl:text>
    </xsl:when>
  </xsl:choose>

  <xsl:if test="foaf:mbox">
    <xsl:text>"email":[</xsl:text>
    <xsl:apply-templates select="foaf:mbox"/>
    <xsl:text>],</xsl:text>
  </xsl:if>
  <xsl:if test="foaf:jabberID">
    <xsl:text>"jabber":[</xsl:text>
    <xsl:apply-templates select="foaf:jabberID"/>
    <xsl:text>],</xsl:text>
  </xsl:if>
  <xsl:if test="foaf:icqChatID">
    <xsl:text>"icq":[</xsl:text>
    <xsl:apply-templates select="foaf:icqChatID"/>
    <xsl:text>],</xsl:text>
  </xsl:if>
  <xsl:if test="foaf:msnChatID">
    <xsl:text>"msn":[</xsl:text>
    <xsl:apply-templates select="foaf:msnChatID"/>
    <xsl:text>],</xsl:text>
  </xsl:if>
  <xsl:if test="foaf:aimChatID">
    <xsl:text>"aim":[</xsl:text>
    <xsl:apply-templates select="foaf:aimChatID"/>
    <xsl:text>],</xsl:text>
  </xsl:if>
  <xsl:if test="foaf:yahooChatID">
    <xsl:text>"yahoo":[</xsl:text>
    <xsl:apply-templates select="foaf:yahooChatID"/>
    <xsl:text>],</xsl:text>
  </xsl:if>
  <xsl:if test="foaf:phone">
    <xsl:text>"phone":[</xsl:text>
    <xsl:apply-templates select="foaf:phone"/>
    <xsl:text>],</xsl:text>
  </xsl:if>

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
    <xsl:text>"weblog":"</xsl:text>
    <xsl:value-of select="foaf:weblog/@rdf:resource |
			  foaf:weblog/foaf:Document/@rdf:about |
			  foaf:blog/@rdf:resource"/>
    <xsl:text>",</xsl:text>
    <xsl:if test="rdfs:seeAlso/rss:channel or
		  foaf:weblog/foaf:Document/rdfs:seeAlso/@rdf:resource">
      <xsl:text>"feed":"</xsl:text>
      <xsl:value-of select="rdfs:seeAlso/rss:channel/@rdf:about |
			    foaf:weblog/foaf:Document/rdfs:seeAlso/@rdf:resource"/>
      <xsl:text>",</xsl:text>
    </xsl:if>
  </xsl:if>

  <xsl:apply-templates select="contact:home |
			       vcard:ADR[@rdf:parseType = 'Resource']"/>

  <xsl:if test="foaf:workplaceHomepage or
		foaf:workplaceHomePage">
    <xsl:apply-templates select="foaf:workplaceHomepage |
				 foaf:workplaceHomePage"/>
  </xsl:if>

  <xsl:apply-templates select="contact:office"/>

  <xsl:if test="foaf:pubkeyAddress">
    <xsl:apply-templates select="foaf:pubkeyAddress"/>
  </xsl:if>

  <xsl:if test="foaf:holdsAccount/foaf:OnlineAccount/foaf:accountProfilePage or
		foaf:holdsAccount/foaf:OnlineAccount/@rdf:about or
		foaf:holdsAccount/@rdf:resource or
		foaf:holdsAccount[@rdf:parseType='Resource']/foaf:accountProfilePage">
    <xsl:text>"onlineAccount":[</xsl:text>
    <xsl:choose>
      <xsl:when test="foaf:holdsAccount/foaf:OnlineAccount">
	<xsl:apply-templates
	    select="foaf:holdsAccount/foaf:OnlineAccount |
		    ../rdf:Description[rdf:type/@rdf:resource
		    = 'http://xmlns.com/foaf/0.1/OnlineAccount']"/>
      </xsl:when>
      <xsl:when test="key('foaf:persons', foaf:holdsAccount/@rdf:resource)">
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
    <xsl:text>],</xsl:text>
  </xsl:if>

  <xsl:if test="foaf:plan">
    <xsl:text>"plan":</xsl:text>
    <xsl:apply-templates select="foaf:plan" mode="sv"/>
    <xsl:text>,</xsl:text>
  </xsl:if>

  <xsl:if test="foaf:geekcode">
    <xsl:text>"geekcode":</xsl:text>
    <xsl:apply-templates select="foaf:geekcode" mode="sv"/>
    <xsl:text>,</xsl:text>
  </xsl:if>

  <xsl:if test="rdfs:seeAlso/ical:Vcalendar/ical:component/ical:Vevent">
    <xsl:text>"vevent":[</xsl:text>
    <xsl:apply-templates
	select="rdfs:seeAlso/ical:Vcalendar/ical:component/ical:Vevent"/>
    <xsl:text>],</xsl:text>
  </xsl:if>

  <xsl:if test="foaf:currentProject">
    <xsl:text>"currentProject":[</xsl:text>
    <xsl:apply-templates select="foaf:currentProject"/>
    <xsl:text>],</xsl:text>
  </xsl:if>

  <xsl:if test="foaf:pastProject">
    <xsl:text>"pastProject":[</xsl:text>
    <xsl:apply-templates select="foaf:pastProject"/>
    <xsl:text>],</xsl:text>
  </xsl:if>

  <xsl:if test="foaf:schoolHomepage">
    <xsl:text>"school":[</xsl:text>
    <xsl:apply-templates select="foaf:schoolHomepage"/>
    <xsl:text>],</xsl:text>
  </xsl:if>

  <xsl:if test="foaf:interest">
    <xsl:text>"interest":[</xsl:text>
    <xsl:apply-templates select="foaf:interest"/>
    <xsl:text>],</xsl:text>
  </xsl:if>

  <xsl:if test="foaf:knows or rel:*">
    <xsl:text>"knows":[</xsl:text>
    <xsl:apply-templates select="foaf:knows |
				 rel:*"/>
    <xsl:text>],</xsl:text>
  </xsl:if>

  <xsl:if test="rdfs:seeAlso[not(rss:channel)]">
    <xsl:text>"seeAlso":[</xsl:text>
    <xsl:apply-templates select="rdfs:seeAlso[not(rss:channel)] |
				 rdfs:seeAlso/ical:Vcalendar"/>
    <xsl:text>],</xsl:text>
  </xsl:if>

  <xsl:if test="owl:sameAs">
    <xsl:text>"sameAs":[</xsl:text>
    <xsl:apply-templates select="owl:sameAs"/>
    <xsl:text>],</xsl:text>
  </xsl:if>

  <xsl:text>"source":"</xsl:text>
  <xsl:value-of select="$URI"/>
  <xsl:text>"</xsl:text>

  <xsl:text>},&#10;</xsl:text>
</xsl:template>

<xsl:template match="rdfs:seeAlso">
  <xsl:call-template name="seeAlsoLink">
    <xsl:with-param name="name" select="@dc:title |
					@rdf:resource |
					foaf:Document/@rdf:about |
					rdf:Description/@rdf:about"/>
    <xsl:with-param name="href" select="@rdf:resource |
					foaf:Document/@rdf:about |
					rdf:Description/rdfs:seeAlso/@rdf:resource"/>
  </xsl:call-template>
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="foaf:nick">
  <xsl:text>"</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>"</xsl:text>
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if> 
</xsl:template>

<xsl:template match="foaf:homepage |
		     foaf:page">
  <xsl:call-template name="simpleAnchor">
    <xsl:with-param name="name" select="'homepage'"/>
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
  </xsl:call-template>
</xsl:template>

<xsl:template match="foaf:workplaceHomepage |
		     foaf:workplaceHomePage">
  <xsl:call-template name="simpleAnchor">
    <xsl:with-param name="name" select="'workplace'"/>
    <xsl:with-param name="href" select="./@rdf:resource |
					./foaf:Document/@rdf:about |
					./rdf:Description/@rdf:about"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foaf:schoolHomepage">
  <xsl:text>"</xsl:text>
  <xsl:value-of select="./@rdf:resource |
			./foaf:Document/@rdf:about"/>
  <xsl:text>"</xsl:text>
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if> 
</xsl:template>

<xsl:template match="foaf:holdsAccount/foaf:OnlineAccount |
		     foaf:holdsAccount[@rdf:parseType='Resource'] |
		     rdf:Description[rdf:type/@rdf:resource
		     = 'http://xmlns.com/foaf/0.1/OnlineAccount'] |
		     sioc:User[child::foaf:accountProfilePage]">
  <xsl:choose>
    <xsl:when test="foaf:accountProfilePage and
		    foaf:accountServiceHomepage">
      <xsl:text>{"uri":"</xsl:text>
      <xsl:value-of select="foaf:accountProfilePage/@rdf:resource"/>
      <xsl:text>","title":"</xsl:text>
      <xsl:value-of select="foaf:accountServiceHomepage/@rdf:resource"/>
      <xsl:text>"</xsl:text>
      <xsl:if test="foaf:accountServiceHomepage/@rdf:resource">
	<xsl:text>,"favicon":"</xsl:text>
	<xsl:call-template name="favicon">
	  <xsl:with-param name="uri"
			  select="foaf:accountServiceHomepage/@rdf:resource"/>
	</xsl:call-template>
	<xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:text>}</xsl:text>
      <xsl:if test="position() != last()">
	<xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:when>
    <xsl:when test="@rdf:about and foaf:accountServiceHomepage">
      <xsl:text>{"uri":"</xsl:text>
      <xsl:value-of select="@rdf:about"/>
      <xsl:text>","title":"</xsl:text>
      <xsl:value-of select="foaf:accountServiceHomepage/@rdf:resource"/>
      <xsl:text>"</xsl:text>
      <xsl:if test="foaf:accountServiceHomepage/@rdf:resource">
	<xsl:text>,"favicon":"</xsl:text>
	<xsl:call-template name="favicon">
	  <xsl:with-param name="uri"
			  select="foaf:accountServiceHomepage/@rdf:resource"/>
	</xsl:call-template>
	<xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:text>}</xsl:text>
      <xsl:if test="position() != last()">
	<xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="foaf:holdsAccount/@rdf:resource">
  <xsl:text>{"uri":"</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>","title":"</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>"}</xsl:text>
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="foaf:mbox">
  <xsl:if test="@rdf:resource">
    <xsl:call-template name="protoAnchor">
      <xsl:with-param name="href"  select="./@rdf:resource"/>
      <xsl:with-param name="proto" select="'mailto:'"/>
    </xsl:call-template>
    <xsl:if test="position() != last()">
      <xsl:text>,</xsl:text>
    </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template match="foaf:phone">
  <xsl:call-template name="protoAnchor">
    <xsl:with-param name="href"  select="./@rdf:resource"/>
    <xsl:with-param name="proto" select="'tel:'"/>
  </xsl:call-template>
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="foaf:jabberID">
  <xsl:call-template name="protoAnchor">
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
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="foaf:icqChatID">
  <xsl:call-template name="protoAnchor">
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
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="foaf:msnChatID">
  <xsl:call-template name="protoAnchor">
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
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="foaf:aimChatID">
  <xsl:call-template name="protoAnchor">
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
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="foaf:yahooChatID">
  <xsl:call-template name="protoAnchor">
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
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if>
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
  <xsl:text>,"lat":"</xsl:text>
  <xsl:value-of select="$lat"/>
  <xsl:text>","long":"</xsl:text>
  <xsl:value-of select="$long"/>
  <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="foaf:pubkeyAddress">
  <xsl:call-template name="simpleAnchor">
    <xsl:with-param name="name" select="'pubkey'"/>
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
	  <xsl:text>{"name":</xsl:text>
	  <xsl:apply-templates select="$p/foaf:name" mode="sv"/>
	  <xsl:text>}</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
  </xsl:choose>
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
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
      <xsl:text>{"name":"</xsl:text>
      <xsl:value-of select="foaf:name |
			    ./@foaf:name |
			    foaf:nick"/>
      <xsl:text>","uri":"</xsl:text>
      <xsl:value-of select="foaf:homepage/@rdf:resource |
			    foaf:weblog/@rdf:resource |
			    foaf:weblog/foaf:Document/@rdf:about"/>
      <xsl:text>"}</xsl:text>
    </xsl:when>
    <xsl:when test="foaf:mbox">
      <xsl:text>{"uri":"</xsl:text>
      <xsl:value-of select="foaf:mbox/@rdf:resource"/>
      <xsl:text>"}</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>{"name":"</xsl:text>
      <xsl:value-of select="foaf:name |
			    ./@foaf:name |
			    foaf:nick"/>
      <xsl:text>"}</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="foaf:interest">
  <xsl:text>{"name":"</xsl:text>
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
  <xsl:text>","uri":"</xsl:text>
  <xsl:value-of select="@rdf:resource |
			rdf:Description/@rdf:about |
			foaf:Document/@rdf:about"/>
  <xsl:text>"}</xsl:text>
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="foaf:currentProject |
		     foaf:pastProject">
  <xsl:text>{"name":"</xsl:text>
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
  <xsl:text>","uri":"</xsl:text>
  <xsl:value-of select="@rdf:resource |
			rdf:Description/@rdf:about |
			foaf:Project/@rdf:about |
			foaf:Project/foaf:homepage/@rdf:resource |
			foaf:Project/rdfs:seeAlso/@rdf:resource |
			foaf:Project/dc:identifier/@rdf:resource |
			doap:Project/doap:homepage/@rdf:resource |
			doap:Project/rdf:Description/@rdf:about"/>
  <xsl:text>"</xsl:text>
  <xsl:if test="rdf:Description/dc:description or
		foaf:Project/dc:description">
    <xsl:text>,"desc":</xsl:text>
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="rdf:Description/dc:description |
				       foaf:Project/dc:description"/>
    </xsl:call-template>
  </xsl:if>
  <xsl:text>}</xsl:text>
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="contact:home |
		     contact:office">
  <xsl:if test="local-name() = 'home'">
    <xsl:text>"homeAddress":{</xsl:text>
  </xsl:if>
  <xsl:if test="local-name() = 'office'">
    <xsl:text>"officeAddress":{</xsl:text>
  </xsl:if>
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
  <xsl:text>},</xsl:text>
</xsl:template>

<xsl:template match="contact:ContactLocation">
  <xsl:apply-templates select="contact:address |
			       contact:address/contact:Address"/>
</xsl:template>

<xsl:template match="contact:address |
		     contact:Address">
  <xsl:if test="contact:street2">
    <xsl:text>"extendedAddress":"</xsl:text>
    <xsl:value-of select="contact:street2"/>
    <xsl:text>",</xsl:text>
  </xsl:if>
  <xsl:text>"streetAddress":"</xsl:text>
  <xsl:value-of select="contact:street"/>
  <xsl:text>","locality":"</xsl:text>
  <xsl:value-of select="contact:city"/>
  <xsl:text>","postalCode":"</xsl:text>
  <xsl:value-of select="contact:postalCode"/>
  <xsl:text>","countryName":"</xsl:text>
  <xsl:value-of select="contact:country"/>
  <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="vcard:ADR">
  <xsl:text>"homeAddress":{</xsl:text>
  <xsl:if test="vcard:Street2">
    <xsl:text>"extendedAddress":"</xsl:text>
    <xsl:value-of select="vcard:Street2"/>
    <xsl:text>",</xsl:text>
  </xsl:if>
  <xsl:text>"streetAddress":"</xsl:text>
  <xsl:value-of select="vcard:Street"/>
  <xsl:text>","locality":"</xsl:text>
  <xsl:value-of select="vcard:Locality"/>
  <xsl:text>","region":"</xsl:text>
  <xsl:value-of select="vcard:Region"/>
  <xsl:text>","postalCode":"</xsl:text>
  <xsl:value-of select="vcard:Pcode"/>
  <xsl:text>","countryName":"</xsl:text>
  <xsl:value-of select="vcard:Country"/>
  <xsl:text>"</xsl:text>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="ical:Vcalendar">
  <xsl:call-template name="seeAlsoLink">
    <xsl:with-param name="name" select="@rdf:about"/>
    <xsl:with-param name="href" select="@rdf:about"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="ical:Vcalendar/ical:component/ical:Vevent">
  <xsl:text>{"url":"</xsl:text>
  <xsl:value-of select="@rdf:about"/>
  <xsl:text>","summary":</xsl:text>
  <xsl:call-template name="escape-string">
    <xsl:with-param name="s" select="ical:summary"/>
  </xsl:call-template>
  <xsl:text>,"description":</xsl:text>
  <xsl:call-template name="escape-string">
    <xsl:with-param name="s" select="ical:description[1]"/>
  </xsl:call-template>
  <xsl:text>,"dtstart":"</xsl:text>
  <xsl:value-of select="ical:dtstart"/>
  <xsl:text>","dtend":"</xsl:text>
  <xsl:value-of select="ical:dtend"/>
  <xsl:text>","location":"</xsl:text>
  <xsl:value-of select="ical:location"/>
  <xsl:text>"</xsl:text>
  <xsl:if test="ical:geo">
    <xsl:text>,"geo":"</xsl:text>
    <xsl:value-of select="ical:geo"/>
    <xsl:text>"</xsl:text>
  </xsl:if>
  <xsl:text>}</xsl:text>
  <xsl:if test="position() != last()">
    <xsl:text>,</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template name="simpleAnchor">
  <xsl:param name="name"/>
  <xsl:param name="href"/>
  <xsl:text>"</xsl:text>
  <xsl:value-of select="$name"/>
  <xsl:text>":"</xsl:text>
  <xsl:value-of select="$href"/>
  <xsl:text>",</xsl:text>
</xsl:template>

<xsl:template name="protoAnchor">
  <xsl:param name="href"/>
  <xsl:param name="proto"/>
  <xsl:text>"</xsl:text>
  <xsl:choose>
    <xsl:when test="contains($href, $proto)">
      <xsl:value-of select="substring-after($href, $proto)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$href"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template name="seeAlsoLink">
  <xsl:param name="name"/>
  <xsl:param name="href"/>
  <xsl:text>{"name":"</xsl:text>
  <xsl:value-of select="$name"/>
  <xsl:text>","uri":"</xsl:text>
  <xsl:value-of select="$href"/>
  <xsl:text>","rdf":"1"}</xsl:text>
</xsl:template>

<xsl:template match="doap:Project">
  <xsl:if test="doap:name">
    <xsl:text>"projectName":"</xsl:text>
    <xsl:value-of select="doap:name"/>
    <xsl:text>",</xsl:text>
  </xsl:if>

  <xsl:if test="doap:homepage">
    <xsl:call-template name="simpleAnchor">
      <xsl:with-param name="name" select="'homepage'"/>
      <xsl:with-param name="href" select="doap:homepage/@rdf:resource |
					  doap:homepage/text()"/>
    </xsl:call-template>
  </xsl:if>

  <xsl:if test="doap:description or doap:shortdesc">
    <xsl:choose>
      <xsl:when test="doap:description">
	<xsl:text>"description":"</xsl:text>
	<xsl:value-of select="doap:description"/>
	<xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:when test="doap:shortdesc">
	<xsl:text>"shortdesc":"</xsl:text>
	<xsl:value-of select="doap:shortdesc"/>
	<xsl:text>",</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:if>

  <xsl:if test="doap:maintainer or doap:developer or
		doap:documenter or doap:translator or
		doap:tester or doap:helper">
    <xsl:text>"members":[</xsl:text>
    <xsl:apply-templates select="doap:maintainer/foaf:Person"/>
    <xsl:apply-templates select="doap:developer/foaf:Person"/>
    <xsl:apply-templates select="doap:documenter/foaf:Person"/>
    <xsl:apply-templates select="doap:translator/foaf:Person"/>
    <xsl:apply-templates select="doap:tester/foaf:Person"/>
    <xsl:apply-templates select="doap:helper/foaf:Person"/>
    <xsl:text>],</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template name="favicon">
  <xsl:param name="uri"/>
  <xsl:variable name="H">
    <xsl:call-template name="strip-trailing-slashes">
      <xsl:with-param name="s" select="$uri"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:value-of select="concat($H, '/favicon.ico')"/>
</xsl:template>

<xsl:template match="foaf:*" mode="sv">
  <xsl:call-template name="escape-string">
    <xsl:with-param name="s" select="."/>
  </xsl:call-template>
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

<xsl:template name="escape-string">
  <xsl:param name="s"/>
  <xsl:text>"</xsl:text>
  <xsl:call-template name="escape-string-bs">
    <xsl:with-param name="s" select="$s"/>
  </xsl:call-template>
  <xsl:text>"</xsl:text>
</xsl:template>
  
<xsl:template name="escape-string-bs">
  <xsl:param name="s"/>
  <xsl:choose>
    <xsl:when test="contains($s, '\')">
      <xsl:call-template name="escape-string-quot">
	<xsl:with-param name="s" select="concat(substring-before($s, '\'), '\\')"/>
      </xsl:call-template>
      <xsl:call-template name="escape-string-bs">
	<xsl:with-param name="s" select="substring-after($s, '\')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="escape-string-quot">
	<xsl:with-param name="s" select="$s"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<xsl:template name="escape-string-quot">
  <xsl:param name="s"/>
  <xsl:choose>
    <xsl:when test="contains($s, '&quot;')">
      <xsl:call-template name="encode-string">
	<xsl:with-param name="s" select="concat(substring-before($s, '&quot;'),
					 '\&quot;')"/>
      </xsl:call-template>
      <xsl:call-template name="escape-string-quot">
	<xsl:with-param name="s" select="substring-after($s, '&quot;')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="encode-string">
	<xsl:with-param name="s" select="$s"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="encode-string">
  <xsl:param name="s"/>
  <xsl:choose>
    <xsl:when test="contains($s, '&#xA;')">
      <xsl:call-template name="encode-string">
	<xsl:with-param name="s" select="concat(substring-before($s, '&#xA;'),
					 '\n', substring-after($s, '&#xA;'))"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="contains($s, '&#xD;')">
      <xsl:call-template name="encode-string">
	<xsl:with-param name="s" select="concat(substring-before($s, '&#xD;'),
					 '\r', substring-after($s, '&#xD;'))"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="contains($s, '&#x9;')">
      <xsl:call-template name="encode-string">
	<xsl:with-param name="s" select="concat(substring-before($s, '&#x9;'),
					 '\t', substring-after($s, '&#x9;'))"/>
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

</xsl:stylesheet>
