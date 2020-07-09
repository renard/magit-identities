;;; magit-identities.el --- Use several identities in magit.

;; Copyright © 2012 Sébastien Gross <seb•ɑƬ•chezwam•ɖɵʈ•org>

;; Author: Sébastien Gross <seb•ɑƬ•chezwam•ɖɵʈ•org>
;; Keywords: emacs, 
;; Created: 2012-08-30
;; Last changed: 2020-07-09 23:43:53
;; Licence: WTFPL, grab your copy here: http://sam.zoy.org/wtfpl/

;; This file is NOT part of GNU Emacs.

;;; Commentary:
;; 
;; Configure identities for `magit' such as `gnus-identities`.
;;


;;; Code:


(require 'magit)
(require 'cl)

(provide 'magit-identities)

(defcustom magit-identities-alist nil
  "List of all identities. Each item is a list of:

\(identity
  regexp
  \(list of fields\)\)

IDENTITY is a unique symbol defining the identity.

The remote repository location (see
`magit-identities-get-repo-string') is match against REGEXP.

LIST OF FIELD is a list suitable cells for
`magit-log-edit-set-fields': (field-symbol . \"content\")

Order matters: first matched identity is used."
  :group 'magit
  :type 'alist)

(defun magit-identities-get-repo-string ()
  "Return a the repository string using following format:

   remote-branch@remote::remote-url"
  (let* ((branch (magit-get-current-branch))
	 (remote (and branch (magit-get "branch" branch "remote")))
	 (remote-branch
	  (or (and branch
		   (substring-no-properties (magit-get-upstream-branch branch)))
	      branch))
	 (remote-url (and remote (magit-get "remote" remote "url"))))
    (format "%s@%s::%s" remote-branch remote remote-url)))

(defun magit-identities-get-id (repository)
  "Given REPOSITORY return a matching id from
`magit-identities-alist'."
  (loop for (id regexp name email) in magit-identities-alist
	when (string-match-p regexp repository)
	return id))

;;;###autoload
(defun magit-identities-set-default-id()
  "Set default identity for current checkout."
  (magit-identities-change
   (symbol-name (magit-identities-get-id
		 (magit-identities-get-repo-string)))))

;;;###autoload
(defun magit-identities-change(id)
  "Change identity to ID taken from `magit-identities-change'."
    (interactive
     (list (completing-read
	    "Identity: "
	    (loop for i in magit-identities-alist
		  collect (symbol-name (car i)))
	    nil 1 )))
    (apply #'magit-identities-set-id
	   (cddr (assoc (intern id) magit-identities-alist))))

(define-key magit-mode-map (kbd "C-c C-p") 'magit-identities-change)


;; ;;;###autoload
;; (add-hook 'magit-log-edit-mode-hook 'magit-identities-set-id)

(defun magit-identities-set-id (name email)
  "Set identity using both NAME and EMAIL to the local repository."
  (let ((cur-name (car (magit-git-lines "config" "user.name")))
	(cur-email (car (magit-git-lines "config" "user.email"))))
    ;;(message "'%s' '%s' | '%s' '%s'" name cur-name email cur-email)
    (unless (equal cur-name name)
      (magit-run-git "config" "--local" "--replace-all" "user.name" name))
    (unless (equal cur-email email)
      (magit-run-git "config" "--local" "--replace-all" "user.email" email))))


;; magit-identities.el ends here
