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

(use-package emmet-mode
  :hook (heex-ts-mode web-mode sgml-mode css-mode))

(pcase centaur-lsp
  ('lsp-mode
   (with-eval-after-load 'lsp-mode
     (add-to-list 'lsp-language-id-configuration '(elixir-ts-mode . "elixir"))
     (add-to-list 'lsp-language-id-configuration '(heex-ts-mode . "html"))

     ;; tailwindcss: add-on for .heex
     (lsp-register-client
      (make-lsp-client
       :new-connection (lsp-stdio-connection '("tailwindcss-language-server" "--stdio"))
       :activation-fn (lsp-activate-on "html")
       :server-id 'tailwindcss-heex
       :add-on? t
       :notification-handlers (ht ("@/tailwindCSS/projectInitialized" #'ignore)))))

   (add-hook 'heex-ts-mode-hook #'lsp-deferred)
   (add-hook 'heex-ts-mode-hook
             (lambda ()
               (setq-local lsp-enable-formatting nil)
               (apheleia-mode -1)
               (add-hook 'after-save-hook
                         (lambda ()
                           (let ((default-directory (locate-dominating-file buffer-file-name "mix.exs")))
                             (when default-directory
                               (let ((exit-code (call-process "mix" nil nil nil "format" buffer-file-name)))
                                 (when (= exit-code 0)
                                   (revert-buffer t t t))))))
                         nil t))))

  ('eglot
   (add-hook 'heex-ts-mode-hook #'eglot-ensure)))

(provide 'init-elixir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-elixir.el ends here
