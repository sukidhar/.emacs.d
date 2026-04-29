;;; custom-post.el --- user post-customization file    -*- lexical-binding: t -*-
;;; Code:

;; Ensure mise shims are on PATH (early-init may be overridden by macOS)
(let ((mise-shims (expand-file-name "~/.local/share/mise/shims")))
  (unless (string-match-p "mise/shims" (getenv "PATH"))
    (setenv "PATH" (concat mise-shims ":" (getenv "PATH")))
    (add-to-list 'exec-path mise-shims)))

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
  (vterm-module-cmake-args "-DCMAKE_OSX_DEPLOYMENT_TARGET= -DCMAKE_SHARED_MODULE_SUFFIX=.dylib")
  (vterm-kill-buffer-on-exit t)
  (vterm-shell "/opt/homebrew/bin/fish -l")
)

(use-package vterm-toggle
  :ensure t
  :after vterm
  :custom
  (vterm-toggle-fullscreen-p nil)
  (vterm-toggle-scope 'project)
  (vterm-toggle-project-root t)
  (vterm-toggle-reset-window-configration-after-exit 'kill-window-only)
  :config
  (add-hook 'vterm-mode-hook (lambda () (run-at-time 0 nil #'helix-insert)))
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                   (let ((buffer (get-buffer buffer-or-name)))
                     (with-current-buffer buffer
                       (or (equal major-mode 'vterm-mode)
                           (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (reusable-frames . visible)
                 (window-height . 0.3))))

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
  (let ((toggle-map (make-sparse-keymap)))
    (define-key toggle-map "t" #'treemacs-display-current-project-exclusively)
    (define-key toggle-map "r" #'tabspaces-restore-session)
    (define-key toggle-map "s" #'tabspaces-save-session)
    (helix-define-key 'space "t" toggle-map))
  (let ((claude-map (make-sparse-keymap)))
    (define-key claude-map "c" #'claudemacs-start-menu)
    (define-key claude-map "t" (lambda () (interactive)
                                          (claudemacs-toggle-buffer)
                                          (when (string-match-p "^\\*claudemacs" (buffer-name))
                                            (helix-insert))))
    (define-key claude-map "e" #'claudemacs-transient-menu)
    (define-key claude-map "f" #'claudemacs-add-current-file-reference)
    (define-key claude-map "a" #'claudemacs-ask-without-context)
    (define-key claude-map "k" #'claudemacs-kill)
    (helix-define-key 'space "c" claude-map))
  (let ((project-map (make-sparse-keymap)))
    (define-key project-map "p" #'project-switch-project)
    (helix-define-key 'space "p" project-map))
  (helix-define-key 'goto "w" #'avy-goto-char-timer)
  (helix-define-key 'normal (kbd "C-`") #'vterm-toggle)
  (helix-define-key 'insert (kbd "C-`") #'vterm-toggle)
  (helix-define-key 'normal (kbd "C-~") #'vterm-toggle-cd)
  (helix-define-key 'insert (kbd "C-~") #'vterm-toggle-cd)
  (helix-mode))

(use-package eat
  :ensure t)

(use-package claudemacs
  :ensure t
  :commands (claudemacs-toggle-buffer claudemacs-start-menu claudemacs-kill
             claudemacs-transient-menu claudemacs-add-current-file-reference
             claudemacs-execute-request claudemacs-ask-without-context)
  :vc (:url "https://github.com/cpoile/claudemacs" :branch "main")
  :bind (:map prog-mode-map
         ("C-c C-e" . claudemacs-transient-menu))
  :config
  (add-to-list 'display-buffer-alist
               '("^\\*claudemacs" (display-buffer-in-side-window)
                 (side . right) (window-width . 0.4)))
  (with-eval-after-load 'eat
    (define-key eat-semi-char-mode-map (kbd "C-c t") #'claudemacs-toggle-buffer))
  (add-hook 'eat-exit-hook
            (lambda (_process)
              (when-let* ((buf (current-buffer))
                          (win (get-buffer-window buf)))
                (when (string-match-p "^\\*claudemacs" (buffer-name buf))
                  (delete-window win))))))

(setq initial-buffer-choice (lambda () (get-buffer-create dashboard-buffer-name)))

(setq auto-save-visited-interval 5)
(auto-save-visited-mode +1)

(setq frame-title-format '("Catix - %b")
      icon-title-format frame-title-format)

(with-eval-after-load 'corfu
  (when (fboundp 'global-company-mode) (global-company-mode -1))
  (add-hook 'corfu-mode-hook (lambda () (when (bound-and-true-p company-mode) (company-mode -1)))))

(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-disabled-clients 'jsts-ls))

(use-package apheleia
  :ensure t
  :config
  (setf (alist-get 'prettier apheleia-formatters)
        '("npx" "prettier" "--stdin-filepath" filepath))
  (setf (alist-get 'js-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'js-ts-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'typescript-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'typescript-ts-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'tsx-ts-mode apheleia-mode-alist) '(prettier))
  (apheleia-global-mode +1))

(use-package rainbow-mode
  :ensure t
  :hook (css-mode css-ts-mode heex-ts-mode elixir-ts-mode web-mode html-mode))

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
)

(with-eval-after-load 'doom-modeline
  (setq doom-modeline-buffer-file-name-style 'truncate-upto-project
        doom-modeline-minor-modes nil
        doom-modeline-lsp t
        doom-modeline-env-version t
        doom-modeline-buffer-encoding nil
        doom-modeline-indent-info t
        doom-modeline-vcs-max-length 20
        doom-modeline-project-detection 'project))

;;; custom-post.el ends here
