;; init-elixir.el --- Initialize elixir configurations.	-*- lexical-binding: t -*-

;; Copyright (C) 2019-2026 N.Ahmet BASTUG

;; Author: N.Ahmet BASTUG <bastugn@itu.edu.tr>
;; URL: https://github.com/kosantosbik/.emacs.d

;; This file is not part of GNU Emacs.
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

;;; Commentary:
;;
;; Elixir configurations.
;;

;;; Code:

(eval-when-compile
  (require 'init-custom))

;; Tree-sitter modes
(if (centaur-treesit-available-p)
    (progn
      (use-package elixir-ts-mode
        :functions centaur-treesit-available-p
        :mode (("\\.elixir\\'" . elixir-ts-mode)
               ("\\.ex\\'"     . elixir-ts-mode)
               ("\\.exs\\'"    . elixir-ts-mode)
               ("mix\\.lock"   . elixir-ts-mode)))
      (use-package heex-ts-mode
        :mode "\\.heex\\'"))
  (use-package elixir-mode))

;; Emmet expansion in templates and html/css
(use-package emmet-mode
  :hook (heex-ts-mode web-mode sgml-mode html-mode html-ts-mode css-mode css-ts-mode))

;; Format elixir/heex with mix format instead of LSP formatter
(defun my/elixir-mix-format-on-save ()
  (when (fboundp 'apheleia-mode) (apheleia-mode -1))
  (add-hook 'after-save-hook
            (lambda ()
              (let ((default-directory (locate-dominating-file buffer-file-name "mix.exs"))
                    (file buffer-file-name)
                    (buf (current-buffer)))
                (when default-directory
                  (let ((proc (start-process
                               "mix-format" nil
                               "fish" "-lc"
                               (format "mix format %s" (shell-quote-argument file)))))
                    (set-process-sentinel
                     proc
                     (lambda (p _event)
                       (when (and (eq (process-status p) 'exit)
                                  (= (process-exit-status p) 0)
                                  (buffer-live-p buf))
                         (with-current-buffer buf
                           (revert-buffer t t t)))))))))
            nil t))

(add-hook 'elixir-ts-mode-hook #'my/elixir-mix-format-on-save)
(add-hook 'heex-ts-mode-hook #'my/elixir-mix-format-on-save)

;; LSP configuration
(pcase centaur-lsp
  ('lsp-mode
   (with-eval-after-load 'lsp-mode
     ;; Disable built-in elixir-ls to avoid conflicts
     (add-to-list 'lsp-disabled-clients 'elixir-ls)

     (add-to-list 'lsp-language-id-configuration '(elixir-ts-mode . "elixir"))
     (add-to-list 'lsp-language-id-configuration '(heex-ts-mode . "phoenix-heex"))

     ;; Dexter — fast Elixir language server (elixir-tools / remoteoss)
     (lsp-register-client
      (make-lsp-client
       :new-connection (lsp-stdio-connection
                        '("/Users/suki/.local/share/mise/shims/dexter" "lsp"))
       :activation-fn (lsp-activate-on "elixir" "phoenix-heex")
       :server-id 'dexter-elixir))

     ;; Tailwind CSS as add-on server (heex, html, css)
     (let ((handlers (make-hash-table :test 'equal)))
       (puthash "@/tailwindCSS/projectInitialized" #'ignore handlers)
       (lsp-register-client
        (make-lsp-client
         :new-connection (lsp-stdio-connection '("tailwindcss-language-server" "--stdio"))
         :activation-fn (lsp-activate-on "phoenix-heex" "html" "css")
         :server-id 'tailwindcss
         :add-on? t
         :notification-handlers handlers))))

   ;; heex derives from html-mode not prog-mode — needs explicit lsp hook
   (add-hook 'heex-ts-mode-hook #'lsp-deferred)
   ;; html/css get lsp for tailwind + native html-ls
   (add-hook 'html-mode-hook #'lsp-deferred)
   (add-hook 'css-mode-hook #'lsp-deferred))

  ('eglot
   (add-hook 'heex-ts-mode-hook #'eglot-ensure)))

(provide 'init-elixir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-elixir.el ends here
