/*
   FOAF.Vix foaf-vix.js
   Copyright (C) 2006, 2008 Wojciech Polak

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
*/

function init () {
  var personName = getElementsByClassName (document, 'span', 'person-name');
  personName = personName.length ? personName[0] : null;
  if (personName) {
    document.title = personName.innerHTML.replace (/<\/?[^>]+>/gi, '')
      + ' - FOAF';
  }
  var imageMaxWidth = 350;
  var ownerImage = getElementsByClassName (document, 'img', 'ownerImage');
  ownerImage = ownerImage.length ? ownerImage[0] : null;
  if (ownerImage && ownerImage.complete) {
    if (ownerImage.width > imageMaxWidth)
      ownerImage.width = imageMaxWidth;
  }
  else if (ownerImage) {
    ownerImage.onload = function () {
      if (this.complete) {
	if (this.width > imageMaxWidth)
	  this.width = imageMaxWidth;
      }
    };
  }
}

function getElementsByClassName (obj, strTagName, strClassName) {
  var arr = (strTagName == '*' && document.all) ?
    document.all : obj.getElementsByTagName (strTagName);
  var ret = [];
  strClassName = strClassName.replace (/\-/g, "\\-");
  var regex = new RegExp ("(^|\\s)" + strClassName + "(\\s|$)");
  var el;
  for (var i = 0; i < arr.length; i++) {
    el = arr[i];
    if (regex.test (el.className))
      ret.push (el);
  }
  return ret;
}

if (document.location.hash.length) {
  var r = document.location.toString ();
  r = r.replace (new RegExp (document.location.hash), '');
  r += '&hash=' + document.location.hash.substr (1);
  document.location.replace (r);
}

window.onload = init;
