;;; monkeyc-mode.el --- Emacs mode for monkeyc programming language

;; Copyright © 2023 Jack Baldry

;; This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;; See the GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License along with this program.
;; If not, see <https://www.gnu.org/licenses/>.

;; Author: Jack Baldry <jack.baldry@grafana.com>
;; Version: 1.0
;; Package-Requires:
;; URL: https://github.com/jdbaldry/garmin-football

;;; Commentary:

;;; Code:
(defvar monkeyc-mode-hook nil "Hook executed when monkeyc-mode is run.")

(defvar monkeyc-mode-map (make-sparse-keymap) "Keymap for Monkeyc major mode.")

(defvar monkeyc-tab-width 1 "Number of tabs characters to insert for indentation.")

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.mc\\'" . monkeyc-mode))

(rx-define bin (any ?0 ?1))
(rx-define oct (any "0-7"))

(rx-define readable-digits (digit-charset)
  (seq digit-charset (* (or (seq ?_ digit-charset) digit-charset))))

(rx-define bin-digits (readable-digits bin))
(rx-define dec-digits (readable-digits digit))
(rx-define hex-digits (readable-digits hex))
(rx-define oct-digits (readable-digits oct))

(rx-define bin-lit (seq ?0 (any ?b ?B) (? ?_) (* bin-digits)))
(rx-define dec-lit (seq (or ?0 (seq (any "1-9") (* (seq (? ?_) dec-digits))))))
(rx-define hex-lit (seq ?0 (any ?x ?X) (? ?_) (* hex-digits)))
(rx-define oct-lit (seq ?0 (? (any ?o ?O)) (? ?_) (* oct-digits)))

(rx-define dec-exp (seq (any ?e ?E) (? (any ?- ?+)) dec-digits))
(rx-define dec-float-lit (or (seq dec-digits ?. (* dec-digits) (* dec-exp))
                             (seq dec-digits dec-exp)
                             (seq ?. dec-digits (* dec-exp))))

(rx-define hex-exp (seq (any ?p ?P) (? (any ?- ?+)) dec-digits))
(rx-define hex-man (seq (or (seq (? ?_) hex-digits ?. (* hex-digits))
                            (seq (? ?_) hex-digits)
                            (seq ?. hex-digits))))
(rx-define hex-float-lit (seq ?0 (any ?x ?X) hex-man hex-exp))

(rx-define monkeyc-identifier (seq (any alpha ?_) (* (any alnum ?_))))

;; Integers are parsed with strconv.ParseInt which supports a leading sign.
(rx-define monkeyc-block-header (seq bol monkeyc-identifier (* (group ?. monkeyc-identifier))))
(rx-define monkeyc-constants (or "true" "false" "null"))
(rx-define monkeyc-float (or dec-float-lit hex-float-lit))
(rx-define monkeyc-int (seq (any ?- whitespace) (or bin-lit dec-lit hex-lit oct-lit) eow))
;; https://developer.garmin.com/connect-iq/reference-guides/monkey-c-reference/#keywords.
(rx-define monkeyc-keywords (seq bow (or
                                      "and"
                                      "as"
                                      "break"
                                      "catch"
                                      "case"
                                      "class"
                                      "const"
                                      "continue"
                                      "default"
                                      "do"
                                      "else"
                                      "enum"
                                      "extends"
                                      "false"
                                      "finally"
                                      "for"
                                      "function"
                                      "has"
                                      "hidden"
                                      "if"
                                      "instanceof"
                                      "me"
                                      "module"
                                      "NaN"
                                      "native"
                                      "new"
                                      "null"
                                      "or"
                                      "private"
                                      "protected"
                                      "public"
                                      "return"
                                      "self"
                                      "static"
                                      "switch"
                                      "throw"
                                      "true"
                                      "try"
                                      "using"
                                      "var"
                                      "while"
                                      )
                                 eow))

;; TODO: introduce levels of font lock.
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Levels-of-Font-Lock.html
(defconst monkeyc-font-lock-keywords
  (let ((monkeyc-block-header-regexp (rx monkeyc-block-header))
        (monkeyc-constant-regexp (rx monkeyc-constants))
        (monkeyc-keyword-regexp (rx monkeyc-keywords))
        (monkeyc-float-regexp (rx monkeyc-float))
        (monkeyc-int-regexp (rx monkeyc-int)))

    `((,monkeyc-block-header-regexp . (0 font-lock-variable-name-face t))
      (,monkeyc-constant-regexp . font-lock-constant-face)
      (,monkeyc-keyword-regexp . font-lock-keyword-face)
      (,monkeyc-float-regexp . font-lock-constant-face)
      (,monkeyc-int-regexp . font-lock-constant-face)))
  "Syntax highlighting for `monkeyc-mode'.")

(defvar monkeyc-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?_ "w" st)
    ;; From: https://www.emacswiki.org/emacs/ModeTutorial
    ;; > 1) That the character '/' is the start of a two-character comment sequence ('1'),
    ;; > that it may also be the second character of a two-character comment-start sequence ('2'),
    ;; > that it is the end of a two-character comment-start sequence ('4'),
    ;; > and that comment sequences that have this character as the second character in the sequence
    ;; > is a “b-style” comment ('b').
    ;; > It’s a rule that comments that begin with a “b-style” sequence must end with either the same
    ;; > or some other “b-style” sequence.
    ;; > 2) That the character '*' is the second character of a two-character comment-start sequence ('2')
    ;; > and that it is the start of a two-character comment-end sequence ('3').
    ;; > 3) That the character '\n' (which is the newline character) ends a “b-style” comment.
    (modify-syntax-entry ?/ ". 124b" st)
    (modify-syntax-entry ?* ". 23" st)
    (modify-syntax-entry ?\n "> b" st)
    st)
  "Syntax table for `monkeyc-mode'.")

;;;###autoload
(define-derived-mode monkeyc-mode prog-mode "Monkeyc"
  "Major mode for editing Monkeyc language files." ()
  (kill-all-local-variables)
  (set-syntax-table monkeyc-mode-syntax-table)
  (use-local-map monkeyc-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(monkeyc-font-lock-keywords))
  (setq major-mode 'monkeyc-mode)
  (setq mode-name "Monkeyc")
  (setq indent-tabs-mode nil)
  (setq tab-width monkeyc-tab-width)
  (setq tab-stop-list nil)
  (setq indent-line-function 'indent-relative)
  (run-hooks 'monkeyc-mode-hook))


(provide 'monkeyc-mode)
;;; monkeyc-mode.el ends here
