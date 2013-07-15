;;; temp-lattes.el --- Abbrev like expansion templates
;; 
;; Filename: temp-lattes.el
;; Description: Abbrev like expansion templates
;; Author: Jordon Biondo
;; Maintainer: Jordon Biondo <biondoj@mail.gvsu.edu>
;; Created: Mon Jul 15 18:08:18 2013 (-0400)
;; Version: .1
;; Last-Updated: Mon Jul 15 18:35:49 2013 (-0400)
;;           By: jorbi
;;     Update #: 2
;; URL: 
;; Doc URL: 
;; Keywords: 
;; Compatibility: 
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Commentary: 
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Change Log:
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Code:


;;---------------------------------------------------------------------------
;; Temp-Lattes
;;---------------------------------------------------------------------------
(defvar tl/keymap (let ((tl-km (make-sparse-keymap)))
		    (define-key tl-km (kbd "M-SPC") 'tl/brew)
		    tl-km)
  "Keymap for temp-latte-mode.")


(define-minor-mode temp-latte-mode
  "A minor mode for very similar to abbrev-mode, but offers a little more control
over expansion. see `tl/define-recipe' for useage information.

Default Bindings:
\tM-SPC:\t tl/brew"
  
  :init-value nil
  :lighter " latte"
  :global t
  :keymap tl/keymap)

(defvar tl/recipe-book (make-hash-table :test 'equal)
  "Temp-latte recipe table.
A recipe is a string/lambda pair.")

(defvar tl/recipe-modes (make-hash-table :test 'equal)
  "Temp-latte mode table.
A recipe-mode is a string/major-mode pair specifying the major mode in which
the recipe will be active.")


(defmacro tl/define-recipe (str mode &rest body)
  "Define a new template recipe that will expand from the key STR when in MODE.
MODE is an unquoted name of a major mode in which the recipe will be active, if nil,
the recipe will be active in all major modes.
BODY may be a function body that will be executed when the key is expanded or a
string that will replace the key at brew time.

Example:
The following creates a recipe for lm in emacs-lisp-mode. when expanded
lm becomes (lambda()) and the cursor is moved into the argument parenthesis.

In the definition, the variable tl/key will be set to the recipe key, in this case tl/key
is \"lm\"
 (tl/define-recipe \"lm\" emacs-lisp-mode
   (backward-delete-char (length tl/key))
   (insert \"(lambda ())\")
   (backward-char 2)
   (indent-according-to-mode))"
  (declare (indent defun))
  (if (not (stringp str)) (signal 'wrong-type-argument str))
  (if (and (= (length body) 1) (stringp (first body)))
      `(progn (puthash ,str (lambda (tl/key)
			      (delete-char ,(- (length str)))
			      (insert ,(first body))) ,(quote tl/recipe-book))
	      (puthash ,str (quote ,mode) ,(quote tl/recipe-modes)))
    `(progn (puthash ,str (lambda (tl/key) ,@body) ,(quote tl/recipe-book))
	    (puthash ,str (quote ,mode) ,(quote tl/recipe-modes)))))

(defmacro tl/kill-key()
  "Macro for use in recipes that will delete the recipe key's text from the point.
  This should be the first call in the recipe. It is equivilant to starting a recipe 
with:
 (backward-delete-char (length tl/key))"
  `(if (boundp 'tl/key)
       (save-excursion
	 (if (and (looking-at "\\>") 
		  (progn (backward-char (length tl/key))
			 (looking-at tl/key)))
	     (delete-char (length tl/key))))))

(defun tl/dump-recipe (str)
  "Remove the recipe definition from `tl/recipe-book' with a key of STR."
  (remhash str tl/recipe-modes)
  (remhash str tl/recipe-book))

(defun tl/craft-recipe (key)
  "Attempt to brew a latte with a recipe key of WORD.
If there is no such recipe, print an message saying so."
  (let ((action (gethash key tl/recipe-book))
	(action-mode (gethash key tl/recipe-modes)))
    (if (and action (or (not action-mode) (equal action-mode major-mode)))
	(apply action (list key))
      (tl/no-recipe (current-word)))))

(defun tl/brew ()
  "Brew a latte from the recipe key at point.
The point needs to be at the end of the key text"
  (interactive)
  (if (looking-at "\\>") (tl/craft-recipe (current-word))
    (tl/no-key)))

(defun tl/no-recipe(key)
  "Prints a no recipe found error message for KEY."
  (princ (format "no recipe found for \"%s\"" key)))

(defun tl/no-key()
  "Prints a no recipe key message.."
  (princ "no recipe key at point, must be at the end of a recipe key"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; temp-lattes.el ends here
