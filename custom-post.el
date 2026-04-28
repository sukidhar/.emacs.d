;;; custom-post.el --- user post-customization file    -*- lexical-binding: t -*-
;;; Code:

(defun fix-case-sensitive-path (args)
  "Resolve true filesystem case for file paths to avoid gopls errors."
  (let ((filename (car args)))
    (when filename
      (cons (file-truename filename) (cdr args)))))
(advice-add 'find-file :filter-args #'fix-case-sensitive-path)

(use-package vterm
  :ensure t
  :defer t
  :custom
  (vterm-always-compile-module t)
  (vterm-module-cmake-args "-DCMAKE_OSX_DEPLOYMENT_TARGET= -DCMAKE_SHARED_MODULE_SUFFIX=.dylib"))

(defvar my/lazygit--prev-win-config nil)

(defun my/lazygit--on-exit (process _msg)
  (when (memq (process-status process) '(exit signal))
    (let ((buf (process-buffer process)))
      (when (buffer-live-p buf)
        (kill-buffer buf)))
    (when my/lazygit--prev-win-config
      (set-window-configuration my/lazygit--prev-win-config)
      (setq my/lazygit--prev-win-config nil))))

(defun my/lazygit-toggle ()
  "Toggle lazygit in a full-window vterm terminal."
  (interactive)
  (let ((buf (get-buffer "*lazygit*")))
    (if (and buf (get-buffer-window buf))
        (progn
          (kill-buffer buf)
          (when my/lazygit--prev-win-config
            (set-window-configuration my/lazygit--prev-win-config)
            (setq my/lazygit--prev-win-config nil)))
      (setq my/lazygit--prev-win-config (current-window-configuration))
      (let ((default-directory (or (vc-root-dir) default-directory)))
        (require 'vterm)
        (setq vterm-shell "lazygit")
        (setq vterm-kill-buffer-on-exit t)
        (vterm "*lazygit*")
        (setq vterm-shell (default-value 'vterm-shell))
        (set-process-sentinel (get-buffer-process "*lazygit*") #'my/lazygit--on-exit)))))

(use-package helix
  :ensure t
  :vc (:url "https://github.com/mgmarlow/helix-mode" :branch "main")
  :demand t
  :config
  (helix-define-key 'normal (kbd "C-M-7") #'transwin-toggle)
  (helix-define-key 'normal (kbd "C-M-8") #'transwin-dec)
  (helix-define-key 'normal (kbd "C-M-9") #'transwin-inc)
  (let ((git-map (make-sparse-keymap)))
    (define-key git-map "g" #'my/lazygit-toggle)
    (helix-define-key 'space "g" git-map))
  (helix-define-key 'goto "w" #'avy-goto-word-1)
  (helix-mode))

(use-package catppuccin-theme
  :ensure t
  :demand t
  :config
  (setq catppuccin-flavor 'mocha)
  (load-theme 'catppuccin t))

(defun my/force-black-bg ()
  (set-frame-parameter nil 'alpha '(90 . 90))
  (set-face-background 'default "#000000")
  (set-face-background 'fringe "#000000")
  (set-face-background 'line-number "#000000")
  (set-face-background 'line-number-current-line "#000000")
  (when (facep 'solaire-default-face)
    (set-face-background 'solaire-default-face "#000000"))
  (when (facep 'solaire-fringe-face)
    (set-face-background 'solaire-fringe-face "#000000")))

(add-hook 'after-init-hook #'my/force-black-bg 100)
(add-hook 'server-after-make-frame-hook #'my/force-black-bg)
(add-hook 'window-setup-hook #'my/force-black-bg)
(add-hook 'enable-theme-functions (lambda (_) (my/force-black-bg)))

(unless (getenv "GROQ_KEY")
  (setenv "GROQ_KEY"
          (string-trim
           (shell-command-to-string "fish -c 'echo $GROQ_KEY'"))))

(use-package minuet
  :ensure t
  :demand t
  :bind
  (("M-y" . minuet-complete-with-minibuffer)
   ("M-i" . minuet-show-suggestion)
   :map minuet-active-mode-map
   ("M-p" . minuet-previous-suggestion)
   ("M-n" . minuet-next-suggestion)
   ("M-A" . minuet-accept-suggestion)
   ("M-a" . minuet-accept-suggestion-line)
   ("M-e" . minuet-dismiss-suggestion))
  :config
  (setq minuet-provider 'openai-compatible)
  (setq minuet-auto-suggestion-debounce-delay 0.6)
  (setq minuet-auto-suggestion-throttle-delay 2.0)
  (setq minuet-n-completions 2)
  (setq minuet-auto-suggestion-block-predicates
        (list (lambda () (not (bound-and-true-p helix-insert-mode)))))
  (plist-put minuet-openai-compatible-options :end-point "https://api.groq.com/openai/v1/chat/completions")
  (plist-put minuet-openai-compatible-options :model "llama-3.3-70b-versatile")
  (plist-put minuet-openai-compatible-options :name "groq")
  (plist-put minuet-openai-compatible-options :api-key "GROQ_KEY")
  (add-hook 'prog-mode-hook #'minuet-auto-suggestion-mode)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (derived-mode-p 'prog-mode)
        (minuet-auto-suggestion-mode 1)))))

;;; custom-post.el ends here
