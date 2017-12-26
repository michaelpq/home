;;--------------------------------------------------------------------------
;; .emacs
;;	Settings for emacs
;;	Copyright (c) 2010-2017, Michael Paquier
;;--------------------------------------------------------------------------

;;--------------------------------------------------------------------------
;; System configuration
;;--------------------------------------------------------------------------

;; Remove splash screen
(setq inhibit-splash-screen t)

;; enable visual feedback on selections
(setq-default transient-mark-mode t)

;; Remove annoying backup files, creating files like aa.txt~
(setq make-backup-files nil)

;; Disable auto save, creating files like #aa.txt#
(setq auto-save-default nil)

;; Stop at the end of the file, not just add lines
(setq next-line-add-newlines nil)
(setq c-tab-always-indent nil)

;; Delete complete TAB when using backward delete and not convert into spaces
(setq backward-delete-char-untabify-method nil)

;; Cursor color
(set-cursor-color "blue")

;; Remove menu bar
(menu-bar-mode -1)

;; Print column number
(column-number-mode 1)

;; Suppress startup verbosity.
(setq inhibit-startup-message t
      initial-scratch-message nil)

;; Use the clipboard, pretty please, so that copy/paste "works"
(setq x-select-enable-clipboard t)

;; Highlight current line
(global-hl-line-mode)

;; Always follow soft links to real files when opening them
(setq vc-follow-symlinks t)

;; Disable Ctl-Z to prevent an unwanted exit
(global-unset-key (kbd "C-z"))

;;--------------------------------------------------------------------------
;; Formatting
;;--------------------------------------------------------------------------

;; Shell scripting
(defun private-sh-mode ()
  "Personal settings for shell scripting"
  (interactive)
  (setq tab-width 4)
  ;; Add personal settings here
)
(add-hook 'sh-mode-hook 'private-sh-mode)

;; PostgreSQL settings
;; Use of a named style makes it easy to use the style elsewhere
(c-add-style "pgsql"
  '((c-file-style . "bsd")
   (fill-column . 78)
   (indent-tabs-mode . t)
   (c-basic-offset   . 4)
   (c-auto-align-backslashes . nil)
   (tab-width . 4)
   (c-offsets-alist . ((case-label . +)
                       (label . -)
                       (statement-case-open . +)))))
(defun pgsql-c-mode ()
  (c-mode)
  (c-set-style "pgsql")
)
(setq auto-mode-alist
  (cons '("\\(postgres\\|pgsql\\).*\\.[chyl]\\'" . pgsql-c-mode)
        auto-mode-alist))
(setq auto-mode-alist
  (cons '("\\(postgres\\|pgsql\\).*\\.cc\\'" . pgsql-c-mode)
        auto-mode-alist))

;; SGML documentation
(add-hook 'sgml-mode-hook
	  (defun postgresql-sgml-mode-hook ()
	    (when (string-match "\\(postgres\\|pgsql\\).*\\.sgml\\'" buffer-file-name)
	      (setq fill-column 78)
	      (setq indent-tabs-mode nil)
	                     (setq sgml-basic-offset 1))))

;; Perl settings
(defun pgsql-perl-mode ()
  "Perl style adjusted for PostgreSQL project"
  (tab-width . 4)
  (perl-indent-level . 4)
  (perl-continued-statement-offset . 4)
  (perl-continued-brace-offset . 4)
  (perl-brace-offset . 0)
  (perl-brace-imaginary-offset . 0)
  (perl-label-offset . -2)
  (setq indent-tabs-mode t)
)
(add-hook 'perl-mode-hook
           (lambda ()
             (if (string-match "postgres" buffer-file-name)
                 (pgsql-perl-mode))))

;; Manage TAB entry to 4-width tabs
(defun private-build-tab-stop-list (width)
  (let ((num-tab-stops (/ 80 width))
        (counter 1)
        (ls nil))
    (while (<= counter num-tab-stops)
      (setq ls (cons (* width counter) ls))
      (setq counter (1+ counter)))
      (set (make-local-variable 'tab-stop-list) (nreverse ls))))
;; This is essential to change the behaviour of backspace for a tab...
(defun c-tab-mode-common-hook ()
  (setq tab-width 4)
  (private-build-tab-stop-list tab-width)
  (setq c-basic-offset tab-width))
(defun sh-tab-mode-common-hook ()
  (setq tab-width 4)
  (private-build-tab-stop-list tab-width)
  (setq c-basic-offset tab-width))
;; Finally add this hook for necessary languages
(add-hook 'c-mode-common-hook 'c-tab-mode-common-hook)	;; C language
(add-hook 'sh-mode-hook 'sh-tab-mode-common-hook)	;; Shell-script

;; Delete trailing whitespaces for several languages
(add-hook 'c-mode-hook '(lambda ()
  (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))
(add-hook 'c++-mode-hook '(lambda ()
  (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))
(add-hook 'perl-mode-hook '(lambda ()
  (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))
(add-hook 'python-mode-hook '(lambda ()
  (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))
(add-hook 'sh-mode-hook '(lambda ()
  (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))

;; Highlight lines with strictly more than 80 characters
(defun 80-col-limit nil
  (defface line-overflow
    '((t (:background "orange" :foreground "black")))
    "Face to use for `hl-line-face'.")
  (highlight-regexp "^.\\{81,\\}$" 'line-overflow)
)
(add-hook 'c-mode-hook '(lambda ()
  (add-hook 'find-file-hook '80-col-limit)))
(add-hook 'c++-mode-hook '(lambda ()
  (add-hook 'find-file-hook '80-col-limit)))
(add-hook 'perl-mode-hook '(lambda ()
  (add-hook 'find-file-hook '80-col-limit)))
(add-hook 'python-mode-hook '(lambda ()
  (add-hook 'find-file-hook '80-col-limit)))
(add-hook 'sh-mode-hook '(lambda ()
  (add-hook 'find-file-hook '80-col-limit)))
(add-hook 'sgml-mode-hook '(lambda ()
  (add-hook 'find-file-hook '80-col-limit)))

;; Display current function name in code
(which-function-mode 1)

;; Mutt settings to enable auto-fill-mode for messages.
;; This is enabled for all files which include "mutt" in their names.
(add-to-list 'auto-mode-alist '(".*mutt.*" . message-mode))

;;--------------------------------------------------------------------------
;; Navigation
;;--------------------------------------------------------------------------

;; Scroll line by line
(setq scroll-step            1
      scroll-conservatively  10000)
;; Turn on font-lock mode
(global-font-lock-mode t)

;;--------------------------------------------------------------------------
;; Controls
;;--------------------------------------------------------------------------

;; Under mac, have Command as Meta and keep Option for localized input
(when (string-match "apple-darwin" system-configuration)
  (setq mac-allow-anti-aliasing t)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'none))

;; Deletion key
(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)

;; f4~f6 settings
(global-set-key [f4] 'goto-line)
(global-set-key [f5] 'query-replace)
(global-set-key [f6] 'switch-to-buffer)

;; Copy/Paste/Cut
(global-set-key "\C-t" 'copy-region-as-kill) ; Copy
(global-set-key "\C-w" 'kill-region)         ; Cut
(global-set-key "\C-y" 'yank)                ; Paste

;; Special handling for TAB
(global-set-key (kbd "TAB") 'tab-to-tab-stop)

;; Rectangular selection area, activate a mark to begin selection
(global-set-key "\C-@" 'set-mark-command)

;;--------------------------------------------------------------------------
;; Others
;;--------------------------------------------------------------------------

;; Private settings for emacs
;; Bypass if it does not exist.
(when (file-exists-p "~/.emacs_extra")
  (load-file "~/.emacs_extra"))
