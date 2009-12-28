;;;; PO <-> XML converter for Foaf.vix
;;;; Copyright (C) 2008 Sergey Poznyakoff
;;;; 
;;;; This program is free software; you can redistribute it and/or modify
;;;; it under the terms of the GNU General Public License as published by
;;;; the Free Software Foundation; either version 3 of the License, or
;;;; (at your option) any later version.
;;;;
;;;; This program is distributed in the hope that it will be useful,
;;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;;; GNU General Public License for more details.
;;;;
;;;; You should have received a copy of the GNU General Public License
;;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;;;

(define-module (xmltrans makepo)
  #:export (begin-processing parse-command-line end-processing))

(use-modules (xmltools xmltrans)
	     (ice-9 format)
	     (ice-9 rdelim)
	     (ice-9 regex)
	     (ice-9 getopt-long))

(debug-enable 'debug)
(debug-enable 'backtrace)


(define gettext-file #f)
(define package-name "PACKAGE")
(define package-version "VERSION")
(define bug-address "BUG-EMAIL-ADDRESS")
(define charset "UTF-8")
(define leading-comment '())

(define (out-po-header)
  (let ((timestamp (localtime (current-time))))
    (set-tm:gmtoff timestamp (- (tm:gmtoff timestamp)))
    (format #t "\
# SOME DESCRIPTIVE TITLE.
# Copyright (C) YEAR YOUR-NAME
# This file is distributed under the same license as the ~A package.
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
#, fuzzy
msgid \"\"
msgstr \"\"
\"Project-Id-Version: ~A ~A\\n\"
\"Report-Msgid-Bugs-To: ~A\\n\"
\"POT-Creation-Date: ~A\\n\"
\"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\\n\"
\"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\n\"
\"Language-Team: LANGUAGE <LL@li.org>\\n\"
\"MIME-Version: 1.0\\n\"
\"Content-Type: text/plain; charset=~A\\n\"
\"Content-Transfer-Encoding: 8bit\\n\"
"
	  package-name
	  package-name package-version
	  bug-address
	  (strftime "%Y-%m-%d %H:%M:%S%z" timestamp)
	  charset)))

;; Display STR, replacing " with \" and <newline> with \n
(define (display-escape str)
  (let loop ((str str))
    (cond
     ((string-index str #\newline)
      => (lambda (w)
	   (display (substring str 0 w))
	   (display "\\n")
	   (loop (substring str (1+ w)))))
     ((string-index str #\")
      => (lambda (w)
	   (display (substring str 0 w))
	   (display "\\\"")
	   (loop (substring str (1+ w)))))
     ((string-index str #\\)
      => (lambda (w)
	   (display (substring str 0 w))
	   (display "\\\\")
	   (loop (substring str (1+ w)))))
     (else
      (display str)))))

;; 
(define (unescape str)
  (let loop ((acc '())
	     (str str))
    (cond
     ((string-index str #\\) =>
      (lambda (w)
	(let ((s (case (string-ref str (1+ w))
		   ((#\a)   #\bel)
		   ((#\b)   #\bs)
		   ((#\f)   #\vt)
		   ((#\n)   #\nl)
		   ((#\r)   #\cr)
		   ((#\t)   #\ht)
		   (else
		    (string-ref str (1+ w))))))
	  (loop (append acc (list (substring str 0 w) (string s)))
		(substring str (+ 2 w))))))
     ((= (string-length str) 0)
      (apply string-append acc))
     (else
      (apply string-append (append acc (list str)))))))

(define (error . rest)
  (with-output-to-port
      (current-error-port)
    (lambda ()
      (for-each
       display
       rest))))

(define line-num 0)

(define (collect-line initial)
  (unescape 
   (call-with-current-continuation
    (lambda (exit)
      (let ((input-list (list initial)))
	(do ((line (read-line) (read-line)))
	    ((eof-object? line)
	     (apply string-append input-list))
	  (set! line-num (1+ line-num))
	  (cond
	   ((string-match "^[ \t]*\"([^\"]*)\"" line) =>
	    (lambda (match)
	      (set! input-list (append input-list
				       (list (match:substring match 1))))))
	   (else
	    (exit (apply string-append input-list))))))))))

(define (read-po-file file)
  (let ((msg-list '())
	(msgid "")
	(want-leading-comment #t))
    (with-input-from-file
	file
      (lambda ()
	(do ((line (read-line) (read-line)))
	    ((eof-object? line) #f)
	  (set! line-num (1+ line-num))
	  (cond
	   ((string-match "^[ \t]*#(.*)" line) =>
	    ;; Ignore comments, except for an initial one
	    (lambda (match)
	      (if want-leading-comment
		  (set! leading-comment
			(append leading-comment
				(list (match:substring match 1)))))))
	   (else
	    (set! want-leading-comment #f)
	    (cond
	     ((string-match "^[ \t]*$" line)) ;; Ignore empty lines
	     ((string-match "^msgid[ \t]+\"([^\"]*)\"" line) =>
	      (lambda (match)
		(set! msgid (unescape (match:substring match 1)))))
	     ((string-match "^msgstr[ \t]+\"([^\"]*)\"" line) =>
	      (lambda (match)
		(set! msg-list (cons
				(cons msgid
				      (collect-line (match:substring match 1)))
				msg-list))))
	     (else
	      (set! want-leading-comment #f)
	      (error file ":" line-num ": suspicious line\n"))))))))
    msg-list))
  


(define po-entries '())

(xmltrans:end-tag
 "msg"
 (tag attr text)
 (set! po-entries
       (append po-entries
	       (list
		(cond
		 (gettext-file
		  (cons attr 
			(let ((trans (assoc text gettext-file)))
			  (if trans
			      (cdr trans)
			      text))))
		 (else
		  (cons
		   (string-append
		    (xmltrans:input-file-name)
		    ":"
		    (number->string
		     (xmltrans:input-line-number)))
		   text))))))
 #f)      


;;;; Command line parser
(define (cons? p)
  (and (pair? p) (not (list? p))))

(define (usage)
  (display "usage: makepo.scm OPTIONS\n")
  (display "OPTIONS are:\n")
  (display "  --gettext=PO-FILE         operate in gettext mode\n")
  (display "  --package-name=NAME       set package name\n")
  (display "  --package-version=STRING  set package version\n")
  (display "  --bug-address=EMAIL       set bug-reporting address\n")
  (display "  --charset=STRING          set charset\n")
  (display "  --help\n")
  (display "  --debug NUMBER\n")
  0)

(define (parse-command-line arglist)
  (let ((grammar `((debug (single-char #\d)
			  (value #t))
		   (gettext (value #t))
		   (package-name (value #t))
		   (package-version (value #t))
		   (bug-address (value #t))
		   (charset (value #t))
		   (help (single-char #\h))))
	(input-files '()))
    (for-each
     (lambda (x)
       (cond
	((cons? x)
	 (case (car x)
	   ((debug)
	    (xmltrans:set-debug-level (string->number (cdr x))))
	   ((gettext)
	    (set! gettext-file (read-po-file (cdr x))))
	   ((package-version)
	    (set! package-version (cdr x)))
	   ((package-name)
	    (set! package-name (cdr x)))
	   ((bug-address)
	    (set! bug-address (cdr x)))
	   ((charset)
	    (set! charset (cdr x)))
	   ((help)
	    (exit (usage)))))
	(else
	 (set! input-files (cdr x)))))
     (getopt-long arglist grammar))
    input-files))


(define (begin-processing)
  #t)

(define (end-processing)
  (cond
   ((null? po-entries)
    (display "No messages were collected\n" (standard-error-port))
    (exit 1))
   (gettext-file
    (display "<!-- This file is generated automatically, please do not edit.")
    (if (not (null? leading-comment))
	(begin
	  (newline)
	  (for-each
	   (lambda (text)
	     (display text)
	     (newline))
	   leading-comment)))
    (display " -->\n")
    (display "<messagebundle>\n")
    (for-each
     (lambda (elt)
       (display " <msg")
       (for-each
	(lambda (attr)
	  (format #t " ~A=\"~A\"" (car attr) (cdr attr)))
	(car elt))
       (display ">")
       (display (cdr elt))
       (display "</msg>")
       (newline))
     po-entries)
    (display "</messagebundle>\n"))
   (else
    (out-po-header)
    (newline)
    (for-each
     (lambda (elt)
       (format #t "#: ~A~%" (car elt))
       (display "msgid \"")
       (display-escape (cdr elt))
       (display "\"\n")
       (display "msgstr \"\"")
       (newline)
       (newline))
     po-entries)))
  #t)