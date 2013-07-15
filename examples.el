
;;---------------------------------------------------------------------------
;; Temp-latte-mode recipe examples
;;
;; Recipes are either defined like a function, or defined by a key, value 
;; pair for direct replacement.
;;---------------------------------------------------------------------------  

;;-----------------------------------------------------
;; Emacs-lisp-mode recipes
;;-----------------------------------------------------  
;; replace lm iwth lambda, but the point in the arg list
(tl/define-recipe "lm" emacs-lisp-mode
  (tl/kill-key)
  (insert "(lambda ())")
  (backward-char 2)
  (indent-according-to-mode))

;; replace df with defun, put the point at the function name position
(tl/define-recipe "df" emacs-lisp-mode
  (let ((sp (point-at-bol)))
    (tl/kill-key)
    (insert "(defun ()\n\"\"\n)")
    (indent-region sp (point))
    (search-backward "(")))

;; replace dv with defvar, put the point at the variable name position
(tl/define-recipe "dv" emacs-lisp-mode
  (tl/kill-key)
  (insert "(defvar  \"\")")
  (backward-char 4)
  (indent-according-to-mode))

;;-----------------------------------------------------
;; org-mode recipes
;;-----------------------------------------------------  

;; insert a source block, put the point in the language spec position.
(tl/define-recipe "src" org-mode
  (tl/kill-key)
  (insert "#+BEGIN_SRC\n\n#+END_SRC")
  (org-indent-line)
  (forward-line -1)
  (org-indent-line)
  (forward-line -1)
  (end-of-line)
  (insert " "))

;;---------------------------------------------------------------------------
;; All-mode recipes (note the nil)
;;---------------------------------------------------------------------------  
;; insert your username at point
(tl/define-recipe "me" nil
  (tl/kill-key)
  (insert (getenv "username")))

;; insert the date at point
(tl/define-recipe "date" nil
  (tl/kill-key)
  (insert (format-time-string "%Y-%m-%d %T")))

;;---------------------------------------------------------------------------
;; Simple replacement recipes
;;---------------------------------------------------------------------------  
(tl/define-recipe "b" c-mode "bool")
(tl/define-recipe "i" c-mode "int")
(tl/define-recipe "d" c-mode "double")
(tl/define-recipe "f" c-mode "float")

(tl/define-recipe "bs" c-mode "bool[]")
(tl/define-recipe "is" c-mode "int[]")
(tl/define-recipe "ds" c-mode "double[]")
(tl/define-recipe "fs" c-mode "float[]")

