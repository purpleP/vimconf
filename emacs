(require 'package)
(require 'ido)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))

(defun ensure-package-installed (&rest packages)
  "Assure every package is installed, ask for installation if it’s not.

Return a list of installed packages or nil for every skipped package."
  (mapcar
   (lambda (package)
     (if (package-installed-p package)
         nil
       (if (y-or-n-p (format "Package %s is missing. Install it? " package))
           (package-install package)
         package)))
   packages))

;; Make sure to have downloaded archive description.
(or (file-exists-p package-user-dir)
    (package-refresh-contents))

;; Activate installed packages
(setq package-enable-at-startup nil)
(package-initialize)

(ensure-package-installed
  'evil
  'evil-numbers
  'solarized-theme
  'nlinum-relative
  'auto-complete
  'ac-haskell-process
  'jedi
  'autopair
  'helm
  'projectile
  'sentence-navigation
)
(evil-mode t)

(define-key evil-insert-state-map (kbd "C-r") 'evil-paste-from-register)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (solarized-dark)))
 '(custom-safe-themes
   (quote
    ("d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" default)))
 '(evil-search-module (quote evil-search))
 '(package-selected-packages
   (quote
    (sentence-navigation evil-numbers wgrep ag nlinum-relative solarized-theme evil)))
 '(python-shell-virtualenv-root "~/.venv/"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-builtin-face ((t (:foreground "#b58900" :slant normal :weight normal))))
 '(font-lock-constant-face ((t (:foreground "#2aa198" :weight normal))))
 '(font-lock-keyword-face ((t (:foreground "#859900" :weight normal))))
 '(font-lock-variable-name-face ((t (:foreground "#839496"))))
 '(nlinum-relative-current-face ((t (:inherit linum :background "#002b36" :foreground "#586e75" :weight bold)))))

(defun set-line-numbers-background ()
    (set-face-background 'linum "#073642")
    (set-face-background 'fringe "#073642")
)

;;; esc quits
(defun minibuffer-keyboard-quit ()
  "Abort recursive edit.
In Delete Selection mode, if the mark is active, just deactivate it;
then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))
(global-unset-key (kbd "C-h"))
(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)
(define-key evil-insert-state-map (kbd "C-l") 'forward-char)
(define-key evil-window-map (kbd "C-j") 'evil-window-down)
(define-key evil-window-map (kbd "C-k") 'evil-window-up)
(define-key evil-window-map (kbd "C-h") 'evil-window-left)
(define-key evil-window-map (kbd "C-l") 'evil-window-right)
(define-key evil-window-map (kbd "C-q") 'delete-window)
(define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)
(define-key evil-visual-state-map (kbd "C-u") 'evil-scroll-up)
(setq inhibit-splash-screen t)
(switch-to-buffer "**")
(setq linum-relative-current-symbol "")
(require 'nlinum-relative)
(require 'wgrep)
(nlinum-relative-setup-evil)
(nlinum-relative-mode t)
(setq nlinum-relative-redisplay-delay 0)
(setq nlinum-relative-current-symbol "")
(setq nlinum-relative-offset 0)
(global-nlinum-relative-mode t)
(add-hook 'nlinum-mode-hook 'set-line-numbers-background)
(add-hook 'after-load-theme-hook 'set-mode-line-background t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(toggle-scroll-bar -1)

(ac-config-default)
(set-face-background 'ac-candidate-face "#839496")
(set-face-foreground 'ac-candidate-face "#073642")
(set-face-background 'ac-selection-face "#586e75")
(set-face-foreground 'ac-selection-face "#eee8d5")

(add-hook 'interactive-haskell-mode-hook 'ac-haskell-process-setup)
(add-hook 'haskell-interactive-mode-hook 'ac-haskell-process-setup)
(eval-after-load "auto-complete"
  '(add-to-list 'ac-modes 'haskell-interactive-mode))

(setq python-environment-default-root-name "~/.venv/")
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)
(autopair-global-mode)
(with-eval-after-load
  'evil (defalias #'forward-evil-word #'forward-evil-symbol)
)

(require 'helm-config)
(helm-mode t)
(global-set-key (kbd "M-x") 'helm-M-x)
(setq backup-directory-alist `(("." . "~/.saves")))
(global-unset-key (kbd "C-x"))
(global-unset-key (kbd "C-a"))
(define-key evil-normal-state-map (kbd "C-a" ) 'evil-numbers/inc-at-pt)
(define-key evil-normal-state-map (kbd "C-x" ) 'evil-numbers/dec-at-pt)
(setq helm-M-x-fuzzy-match t)
(setq helm-completion-in-region-fuzzy-match t)

(define-key evil-motion-state-map ")" 'sentence-nav-evil-forward)
(define-key evil-motion-state-map "(" 'sentence-nav-evil-backward)
(define-key evil-motion-state-map "g)" 'sentence-nav-evil-forward-end)
(define-key evil-motion-state-map "g(" 'sentence-nav-evil-backward-end)
(define-key evil-outer-text-objects-map "s" 'sentence-nav-evil-a-sentence)
(define-key evil-inner-text-objects-map "s" 'sentence-nav-evil-inner-sentence)
