;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Maple Mono NF CN")
      doom-variable-pitch-font (font-spec :family "JetBrainsMono Nerd Font"))

;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-spacegrey)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; keymap
(map! "C-h" #'backward-delete-char-untabify)        ;; C-h == backspace
(map! :g "M-0" #'treemacs-select-window)            ;; M-0 focus on treemacs
(after! vertico
  (vertico-mouse-mode t))

;; auctex 设置默认latex引擎为xelatex
(setq-default TeX-engine 'xetex)

;; 设置org-roam的日记位置，用于和logseq同步
(setq! org-roam-dailies-directory "journals")

;; 设置默认的参考文献引用文件
(setq! citar-bibliography '("~/org/ref.bib"))
(setq! citar-library-paths '("~/zotero_attachments/")
       citar-notes-paths '("~/org/roam/refs/"))
(setq! citar-org-roam-subdir "refs")

;; 设置ogr-noter笔记位置
(setq! org-noter-notes-search-path '("~/org/" "~/org/roam/" "~/org/roam/refs/"))

;; latex formatter
(after! latex
  (setq-hook! 'LaTeX-mode-hook +format-with 'latexindent))

;; python formatter
(after! python
  (set-formatter! 'ruff :modes '(python-mode python-ts-mode))
  (setq-hook! 'python-mode-hook +format-with 'ruff))

;; json formatter
(after! json
  (setq-hook! 'json-ts-mode-hook +format-with 'prettier))

;; yaml formatter
(after! yaml
  (setq-hook! 'yaml-mode-hook +format-with 'prettier))

;; c/c++ formatter
(after! cc
  (setq-hook! '(c-mode-hook c++-mode-hook c-ts-mode-hook c++-ts-mode-hook) +format-with 'clang-format))

;; TODO c/c++ lsp use neocmakelsp, eglot default use --stdio is error
(after! eglot
  (set-eglot-client! '(cmake-mode cmake-ts-mode) '("neocmakelsp" "stdio")))

;; TODO cita and org-noter integretion
(defun citar-add-org-noter-document-property(key &optional entry)
  "Set various properties PROPERTIES drawer when new Citar note is created."
  (interactive)
  (let* ((file-list-temp (list (citar--select-resource key :files t)))
         (file-path-temp (alist-get 'file file-list-temp))
         (cite-author (cdr (citar-get-field-with-value'(author) key)))
         (cite-url (cdr (citar-get-field-with-value '(url) key))) )

    (org-set-property "DIR" "attachments")
    (org-set-property "NOTER_DOCUMENT" file-path-temp)
    (org-set-property "Custom_ID" key)
    (org-set-property "AUTHOR" cite-author)
    (org-set-property "URL"    cite-url)
    (org-roam-ref-add (concat "@" key))
    (org-id-get-create) ))

(advice-add 'citar-create-note :after #'citar-add-org-noter-document-property)
(after! citar-org-roam
  (add-to-list 'org-roam-capture-templates
               '("c" "citar literature note" plain "%?"
                 :target (file+head "%(expand-file-name citar-org-roam-subdir org-roam-directory)/${citar-citekey}.org"
                                    "#+title: ${citar-title}\n#+subtitle: ${citar-author}, ${citar-date}\n#+created: %U\n#+last_modified: %U\n\n")
                 :unnarrowed t)))

(setq! citar-org-roam-capture-template-key "c")

;; vertico-postframe 命令栏居中
(setq! vertico-multiform-commands
       '((t posframe
          (vertico-posframe-poshandler . posframe-poshandler-frame-center)
          (vertico-posframe-fallback-mode . vertico-buffer-mode))))
(setq! vertico-multiform-mode 1)

;; AI插件配置
(use-package! gptel
  :config
  (setq!
   gptel-model 'gemini-2.5-flash
   gptel-backend (gptel-make-gemini "Gemini" :stream t :key gptel-api-key)))

;; 翻译插件
(use-package! gt
  :config
  (map! "C-c g" #'gt-translate)
  (setq!
   gt-langs '(en zh)
   gt-default-translator (gt-translator
                          :engines (gt-google-engine)
                          :render (gt-buffer-render)))
  (setq! gt-source-text-transformer
         (lambda (c engine )
           (string-replace "\n" " " c)))
  (setq! gt-http-backend (pdd-url-backend :proxy "socks5://127.0.0.1:7897")))

;; 密码管理
(use-package! secrets
  :config
  (message "Secret Service 已加载"))
