;;--------------------------------------------------------------------------
;; .emacs
;;	emacs settings
;;	Copyright (c) 2010-2012, Michael Paquier
;;--------------------------------------------------------------------------

;;--------------------------------------------------------------------------
;; Upload initialization packages
;;--------------------------------------------------------------------------
(when (file-exists-p "~/.emacs.d")
  (when (let* ((my-lisp-dir "~/.emacs.d/")
        (default-directory my-lisp-dir))
    (setq load-path (cons my-lisp-dir load-path))
    (normal-top-level-add-subdirs-to-load-path))))
(when (file-exists-p "~/.emacs.d/elpa/package.el")
  (when (load (expand-file-name "~/.emacs.d/elpa/package.el"))
    (package-initialize)))

;;--------------------------------------------------------------------------
;; System configuration
;;--------------------------------------------------------------------------

;; Remove splash screen
(setq inhibit-splash-screen t)
;; enable visual feedback on selections
(setq-default transient-mark-mode t)
;; Remove annoying backup files, creating files like aa.txt~
(setq make-backup-files nil)
; Disable auto save, creating files like #aa.txt#
(setq auto-save-default nil)
;; Stop at the end of the file, not just add lines
(setq next-line-add-newlines nil)
(setq c-tab-always-indent nil)
;; Cursor color
(set-cursor-color "blue")
;; Set the font
(set-frame-font "-*-fixedsysttf-*-*-*-*-15-*-*-*-*-*-*-*")
;; Display time
(display-time)
;; Remove menu bar
(menu-bar-mode -1)
;; Remove tool bar
;; This is possible only if a window system is used
(if window-system
  (tool-bar-mode -1))
;; Print column number
(column-number-mode 1)
;; Suppress startup verbosity.
(setq inhibit-startup-message t
      initial-scratch-message nil)

;;--------------------------------------------------------------------------
;; Code formatting
;;--------------------------------------------------------------------------

;; PostgreSQL settings
;; Use of a named style makes it easy to use the style elsewhere
(c-add-style "pgsql"
  '("bsd"
   (fill-column . 79)
   (indent-tabs-mode . t)
   (c-basic-offset   . 4)
   (tab-width . 4)
   (c-offsets-alist .
   ((case-label . +))))
  nil) ; t = set this mode, nil = don't
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
;;; PostgreSQL sgml documentation
(defun pgsql-sgml-mode ()
  "SGML mode adjusted for PostgreSQL project"
  (interactive)
  (sgml-mode)

  (setq indent-tabs-mode nil)
  (setq sgml-basic-offset 1)
)
(setq auto-mode-alist
  (cons '("\\(postgres\\|pgsql\\).*\\.sgml\\'" . pgsql-sgml-mode)
        auto-mode-alist))
;; Add files with extension .sgmlin to sgml mode (Postgres-XC exclusive)
(setq auto-mode-alist
  (cons '("\\(postgres\\|pgsql\\).*\\.sgmlin\\'" . pgsql-sgml-mode)
        auto-mode-alist))

;; Manage TAB entry to 4-width tabs
(defun my-build-tab-stop-list (width)
  (let ((num-tab-stops (/ 80 width))
        (counter 1)
        (ls nil))
    (while (<= counter num-tab-stops)
      (setq ls (cons (* width counter) ls))
      (setq counter (1+ counter)))
      (set (make-local-variable 'tab-stop-list) (nreverse ls))))
(defun my-c-mode-common-hook ()
  (setq tab-width 4) ;; change this to taste, this is what K&R uses :)
  (my-build-tab-stop-list tab-width)
  (setq c-basic-offset tab-width))
  (setq c-backspace-function 'backward-delete-char) ;;essential to change the behaviour of backspace for a tab...
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

;; Delete trailing whitespaces for C, C++ and Python
(add-hook 'c-mode-hook '(lambda ()
  (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))
(add-hook 'c++-mode-hook '(lambda ()
  (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))
(add-hook 'python-mode-hook '(lambda ()
  (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))

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
