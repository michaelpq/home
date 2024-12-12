;;--------------------------------------------------------------------------
;; .emacs
;;  Settings for Emacs
;;  Copyright (c) 2010-2024, Michael Paquier
;;--------------------------------------------------------------------------

;;--------------------------------------------------------------------------
;; System configuration
;;--------------------------------------------------------------------------

;; UI and startup settings
(setq inhibit-splash-screen t
      inhibit-startup-message t
      initial-scratch-message nil)
(menu-bar-mode -1)
(global-hl-line-mode)
(column-number-mode 1)
(set-cursor-color "blue")

;; File handling
(setq make-backup-files nil
      auto-save-default nil
      vc-follow-symlinks t)

;; Editing behavior
(setq-default transient-mark-mode t)
(setq next-line-add-newlines nil
      c-tab-always-indent nil
      backward-delete-char-untabify-method nil
      x-select-enable-clipboard t)

;; Key bindings
(global-unset-key (kbd "C-z"))
(put 'upcase-region 'disabled nil)

;;--------------------------------------------------------------------------
;; Formatting
;;--------------------------------------------------------------------------

;; Shell scripting
(defun private-sh-mode ()
  "Personal settings for shell scripting"
  (interactive)
  (setq tab-width 4))
(add-hook 'sh-mode-hook 'private-sh-mode)

;; PostgreSQL settings
(c-add-style "pgsql"
             '((c-file-style . "bsd")
               (fill-column . 78)
               (indent-tabs-mode . t)
               (c-basic-offset . 4)
               (c-auto-align-backslashes . nil)
               (tab-width . 4)
               (c-offsets-alist . ((case-label . +)
                                   (label . -)
                                   (statement-case-open . +)))))

(defun pgsql-c-mode ()
  (c-mode)
  (c-set-style "pgsql"))

(setq auto-mode-alist
      (append '(("\\(postgres\\|pgsql\\).*\\.[chyl]\\'" . pgsql-c-mode)
                ("\\(postgres\\|pgsql\\).*\\.cc\\'" . pgsql-c-mode))
              auto-mode-alist))

;; SGML documentation
(add-hook 'sgml-mode-hook
          (defun postgresql-sgml-mode-hook ()
            (when (string-match "\\(postgres\\|pgsql\\).*\\.sgml\\'" buffer-file-name)
              (setq fill-column 78
                    indent-tabs-mode nil
                    sgml-basic-offset 1))))

;; Perl settings
(defun pgsql-perl-mode ()
  "Perl style adjusted for PostgreSQL project"
  (setq tab-width 4
        perl-indent-level 4
        perl-continued-statement-offset 4
        perl-continued-brace-offset 4
        perl-brace-offset 0
        perl-brace-imaginary-offset 0
        perl-label-offset -2
        indent-tabs-mode t))

(add-hook 'perl-mode-hook
          (lambda ()
            (when (string-match "postgres" buffer-file-name)
              (pgsql-perl-mode))))

;; Tab handling
(defun private-build-tab-stop-list (width)
  (let ((num-tab-stops (/ 80 width))
        (counter 1)
        (ls nil))
    (while (<= counter num-tab-stops)
      (setq ls (cons (* width counter) ls))
      (setq counter (1+ counter)))
    (set (make-local-variable 'tab-stop-list) (nreverse ls))))

(defun c-tab-mode-common-hook ()
  (setq tab-width 4)
  (private-build-tab-stop-list tab-width)
  (setq c-basic-offset tab-width))

(defun sh-tab-mode-common-hook ()
  (setq tab-width 4)
  (private-build-tab-stop-list tab-width)
  (setq c-basic-offset tab-width))

(add-hook 'c-mode-common-hook 'c-tab-mode-common-hook)
(add-hook 'sh-mode-hook 'sh-tab-mode-common-hook)

;; Delete trailing whitespaces
(dolist (hook '(c-mode-hook c++-mode-hook perl-mode-hook python-mode-hook sh-mode-hook))
  (add-hook hook
            (lambda ()
              (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t))))

;; Highlight lines over 80 characters
(defun 80-col-limit ()
  (defface line-overflow
    '((t (:background "orange" :foreground "black")))
    "Face to use for `hl-line-face'.")
  (highlight-regexp "^.\\{81,\\}$" 'line-overflow))

(dolist (hook '(c-mode-hook c++-mode-hook perl-mode-hook python-mode-hook sh-mode-hook sgml-mode-hook))
  (add-hook hook
            (lambda ()
              (add-hook 'find-file-hook '80-col-limit))))

;; Display current function name in code
(which-function-mode 1)

;; Mutt settings
(add-to-list 'auto-mode-alist '("/mutt" . mail-mode))
(add-hook 'mail-mode-hook 'turn-on-auto-fill)

;; Git commit mode
(define-derived-mode git-commit-mode text-mode "GitCommit"
  "Mode for writing git commit files."
  (setq fill-column 72)
  (auto-fill-mode +1)
  (set (make-local-variable 'comment-start-skip) "#.*$"))

(add-to-list 'auto-mode-alist
             '("/\\(?:COMMIT\\|NOTES\\|TAG\\|PULLREQ\\)_EDITMSG\\'" . git-commit-mode))

;;--------------------------------------------------------------------------
;; Navigation and Controls
;;--------------------------------------------------------------------------

;; Scrolling
(setq scroll-step 1
      scroll-conservatively 10000)

;; Font-lock
(global-font-lock-mode t)

;; Mac-specific settings
(when (string-match "apple-darwin" system-configuration)
  (setq mac-allow-anti-aliasing t
        mac-command-modifier 'meta
        mac-option-modifier 'none))

;; Key bindings
(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)
(global-set-key [f4] 'goto-line)
(global-set-key [f5] 'query-replace)
(global-set-key [f6] 'switch-to-buffer)
(global-set-key "\C-t" 'copy-region-as-kill)
(global-set-key "\C-w" 'kill-region)
(global-set-key "\C-y" 'yank)
(global-set-key (kbd "TAB") 'tab-to-tab-stop)
(global-set-key "\C-u" 'set-mark-command)

;;--------------------------------------------------------------------------
;; Load additional private settings
;;--------------------------------------------------------------------------

(when (file-exists-p "~/.emacs_extra")
  (load-file "~/.emacs_extra"))
