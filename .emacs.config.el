;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq package-archives '(("gnu"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("org-cn". "http://mirrors.tuna.tsinghua.edu.cn/elpa/org/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))


(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

(setq evil-snipe-override-evil-repeat-keys nil)
(setq doom-leader-key ",")
(setq doom-localleader-key ",")

;;;###autoload
(defun gcl/edit-zsh-configuration()
  (interactive)
  (find-file "~/.zshrc"))

;;;###autoload
(defun gcl/goto-match-paren (arg)
  "Go to the matching if on (){}[], similar to vi style of % ."
  (interactive "p")
  (cond ((looking-at "[\[\(\{]") (evil-jump-item))
        ((looking-back "[\]\)\}]" 1) (evil-jump-item))
        ((looking-at "[\]\)\}]") (forward-char) (evil-jump-item))
        ((looking-back "[\[\(\{]" 1) (backward-char) (evil-jump-item))
        (t nil)))

;;;###autoload
(defun gcl/string-inflection-cycle-auto ()
  "switching by major-mode"
  (interactive)
  (cond
   ;; for emacs-lisp-mode
   ((eq major-mode 'emacs-lisp-mode)
    (string-inflection-all-cycle))
   ;; for python
   ((eq major-mode 'python-mode)
    (string-inflection-python-style-cycle))
   ;; for java
   ((eq major-mode 'java-mode)
    (string-inflection-java-style-cycle))
   (t
    ;; default
    (string-inflection-all-cycle))))

;;;###autoload
(defun dired-timesort (filename &optional wildcards)
  (let ((dired-listing-switches "-lhat"))
    (dired filename wildcards)))

;;;###autoload
(defun gcl/embrace-prog-mode-hook ()
  (dolist (lst '((?` "`" . "`")))
    (embrace-add-pair (car lst) (cadr lst) (cddr lst))))



;; Current time and date
(defvar current-date-time-format "%a %b %d %H:%M:%S %Z %Y"
  "Format of date to insert with `insert-current-date-time' func
See help of `format-time-string' for possible replacements")

(defvar current-time-format "%H:%M"
  "Format of date to insert with `insert-current-time' func.
Note the weekly scope of the command's precision.")

;;;###autoload
(defun insert-current-date-time ()
  "insert the current date and time into current buffer.
Uses `current-date-time-format' for the formatting the date/time."
  (interactive)
  (insert (format-time-string current-date-time-format (current-time)))
  )

;;;###autoload
(defun insert-current-time ()
  "insert the current time (1-week scope) into the current buffer."
  (interactive)
  (insert (format-time-string current-time-format (current-time)))
  )
;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
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
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;;Key Configuration for Doom as Vanilla Emacs
;;(setq evil-default-state 'emacs)

(after! ranger--debug
  :config
  (setq ranger-show-literal nil))

(use-package! ivy-cider
  :after cider-mode)


(use-package company
  :ensure t
  :hook (prog-mode . company-mode)
  :bind (:map company-active-map
         ("C-p" . #'company-select-previous)
         ("C-n" . #'company-select-next)
         ("<tab>" . #'company-complete-common-or-cycle)
         :map company-search-map
         ("C-p" . #'company-select-previous)
         ("C-n" . #'company-select-next))
  :config
  (setq company-tooltip-align-annotations t
        company-idle-delay 0.1
        company-show-numbers t)
  (bind-key [remap completion-at-point] #'company-complete company-mode-map))

(use-package cc-mode
  :ensure nil
  :defines lsp-clients-clangd-executable lsp-clients-clangd-args
  :mode ("\\.cxx\\'" . cc-mode)
  :hook (c-mode . (lambda ()
                    (setq comment-start "// "
                          comment-end "")))
  :config
  (defconst ccls-args nil)
  (defconst clangd-args '("-j=2"
                          "--background-index"
                          "--clang-tidy"
                          "--cross-file-rename"
                          "--completion-style=bundled"
                          "--pch-storage=memory"
                          "--header-insertion=iwyu"
                          "--header-insertion-decorators"))
  (with-eval-after-load 'lsp-mode
    ;; Prefer `clangd' over `ccls'
    (cond ((executable-find "clangd") (setq lsp-clients-clangd-executable "clangd"
                                            lsp-clients-clangd-args clangd-args))
          ((executable-find "ccls") (setq lsp-clients-clangd-executable "ccls"
                                          lsp-clients-clangd-args ccls-args))))
  :custom
  (c-comment-prefix-regexp '((c-mode   . "//+!?\\|\\**")
                             (c++-mode . "//+!?\\|\\**")
                             (awk-mode . "#+")
                             (other    . "//+\\|\\**")))
  (c-doc-comment-style `((c-mode   . gtkdoc)
                         (c++-mode . ,(if (>= emacs-major-version 28) 'doxygen 'gtkdoc))))
  (c-basic-offset 4)
  (c-label-minimum-indentation 0)
  (c-offsets-alist '(;; a multi-line C style block comment
                     ;;
                     ;; /**
                     ;;  * text
                     ;;  */
                     ;; int foo();
                     (c                     . c-lineup-C-comments)
                     ;; a multi-line string
                     ;;
                     ;; const char* s = "hello,\
                     ;; world";
                     (string                . c-lineup-dont-change)
                     ;; brace of function
                     ;;
                     ;; int add1(int x) {
                     ;;     return ++x;
                     ;; }
                     (defun-open            . 0)
                     (defun-close           . 0)
                     (defun-block-intro     . +)
                     ;; brace of class
                     ;;
                     ;; class Foo {
                     ;; public:                                 // <- access-label
                     ;; };
                     (class-open            . 0)
                     (class-close           . 0)
                     (access-label          . -)
                     ;; brace of class method
                     ;;
                     ;; class Foo {
                     ;;     friend class Bar;                   // <- friend
                     ;;     int getVar() {                      // <- inclass
                     ;;         return 42;
                     ;;     }
                     ;; };
                     (inline-open           . 0)
                     (inline-close          . 0)
                     (inclass               . +)
                     (friend                . 0)
                     ;; `noexcept' specifier indentation
                     (func-decl-cont        . +)
                     ;; brace of list
                     ;;
                     ;; int nums[] =
                     ;; {
                     ;;     0,
                     ;;     1,
                     ;;     {2},
                     ;; };
                     (brace-list-open       . 0)
                     (brace-list-close      . 0)
                     (brace-list-intro      . +)
                     (brace-list-entry      . 0)
                     (brace-entry-open      . 0)
                     ;; brace of namespace
                     ;;
                     ;; namespace ns {
                     ;; const int var = 42;
                     ;; }
                     (namespace-open        . 0)
                     (namespace-close       . 0)
                     (innamespace           . 0)
                     ;; brace of statement block
                     ;;
                     ;; int send_mail() {
                     ;;     std::mutex io_mtx;
                     ;;     {
                     ;;         std::lock_guard<std::mutex> lk(io_mtx);
                     ;;         // ...
                     ;;     }
                     ;; }
                     (block-open            . 0)
                     (block-close           . 0)
                     ;; topmost definition
                     ;;
                     ;; struct
                     ;; foo {};
                     (topmost-intro         . 0)
                     (topmost-intro-cont    . c-lineup-topmost-intro-cont)
                     ;; class member initialization list
                     ;;
                     ;; struct foo {
                     ;;     foo(int a, int b) :
                     ;;         a_(a),
                     ;;         b_(b) {}
                     ;; };
                     (member-init-intro     . +)
                     (member-init-cont      . c-lineup-multi-inher)
                     ;; class inheritance
                     ;;
                     ;; struct Derived : public Base1,
                     ;;                  public Base2 {
                     ;; };
                     (inher-intro           . +)
                     (inher-cont            . c-lineup-multi-inher)
                     ;; A C statement
                     ;;
                     ;; int main(int argc, char* argv[]) {
                     ;;     const int var1 = 42;
                     ;;     const int var2 = (argc > 1) ? 314   // <- a new statement starts
                     ;;                                 : 512;  // <- statement-cont
                     ;;     {
                     ;;         const int var3 = 42;            // <- statement-block-intro
                     ;;     }
                     ;;
                     ;;     switch (argc) {
                     ;;     case 0:                             // <- case-label
                     ;;         break;                          // <- statement-case-intro
                     ;;
                     ;;     case 1:
                     ;;         {                               // <- statement-case-open
                     ;;             const int tmp = 101;
                     ;;         }
                     ;;         break;
                     ;;     }
                     ;;
                     ;;     if (argc == 1)
                     ;;         assert(argc == 1);              // <- substatement
                     ;;
                     ;;     if (argc == 1)
                     ;;     {                                   // <- substatement-open
                     ;;         assert(argc == 1);
                     ;;     }
                     ;;
                     ;;     // comments                         // <- comment-intro
                     ;;     if (argc == 1)
                     ;;     glabel:                             // <- substatement-label
                     ;;         assert(argc == 1);
                     ;;
                     ;; error:                                  // <- label, with zero `c-label-minimum-indentation'
                     ;;     return -1;
                     ;; }
                     (statement             . 0)
                     (statement-cont        . (c-lineup-ternary-bodies +))
                     (statement-block-intro . +)
                     (statement-case-intro  . +)
                     (statement-case-open   . +)
                     (substatement          . +)
                     (substatement-open     . 0)
                     (substatement-label    . 0)
                     (case-label            . 0)
                     (label                 . 0)
                     (do-while-closure      . 0)
                     (else-clause           . 0)
                     (catch-clause          . 0)
                     (comment-intro         . c-lineup-comment)
                     ;; funcall with arglist
                     ;;
                     ;; sum(
                     ;;     1, 2, 3
                     ;; );
                     (arglist-intro         . +)
                     (arglist-cont          . 0)
                     (arglist-cont-nonempty . c-lineup-arglist)
                     (arglist-close         . c-lineup-close-paren)
                     ;; operator>> and operator<< for cin/cout
                     ;;
                     ;; std::cin >> a
                     ;;          >> b;
                     ;; std::cout << a
                     ;;           << b;
                     (stream-op             . c-lineup-streamop)
                     ;; macros
                     ;;
                     ;; #define ALIST(G)                                \
                     ;;     G(1)                                        \
                     ;;     G(2)
                     (cpp-macro             . -1000)
                     (cpp-macro-cont        . +)
                     ;; extern
                     ;;
                     ;; extern "C" {
                     ;; void test();
                     ;; }
                     (extern-lang-open      . 0)
                     (extern-lang-close     . 0)
                     (inextern-lang         . 0)
                     ;; lambda
                     ;;
                     ;; auto f = [](int a, int b) {
                     ;;     return a + b;
                     ;; };
                     (inlambda              . 0)
                     (lambda-intro-cont     . +)
                     ;; GNU extension, a compound statement as expression
                     ;;
                     ;; int x = 1, y = 2;
                     ;; int z = ({
                     ;;     int ret;
                     ;;     if (y > 0)
                     ;;         ret = y;
                     ;;     else
                     ;;         ret = x - y;
                     ;;     ret;
                     ;; });
                     (inexpr-statement      . 0)
                     ;; c++ template args
                     ;;
                     ;; dummy<int,
                     ;;       char,
                     ;;       double>(0, 0, 0);
                     (template-args-cont    . (c-lineup-template-args +)))))

(after! cc-mode
  (set-company-backend! 'c-mode
    '(:separate company-irony-c-headers company-irony)))

(use-package! lsp-mode
  :hook
  (haskell-mode . lsp)
  (python-mode . lsp)
  (rustic-mode . lsp)
  (rust-mode . lsp)
  (reason-mode . lsp)
  :config
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection "reason-language-server")
                    :major-modes '(reason-mode)
                    :notification-handlers (ht ("client/registerCapability" 'ignore))
                    :priority 1
                    :server-id 'reason-ls))
  :commands
  lsp
  :ensure t)


(use-package! lsp-ui
  :commands
  lsp-ui-mode)


(use-package! sqlformat
  :hook
  (sql-mode . sqlformat-on-save-mode)
  :config
  (setq sqlformat-command 'pgformatter))

(setq lsp-clients-clangd-args '("-j=2"
                                "--background-index"
                                "--clang-tidy"
                                "--completion-style=detailed"
                                "--header-insertion=never"
                                "--header-insertion-decorators=0"))
(after! lsp-clangd (set-lsp-priority! 'clangd 2))


;; key-mapping
(global-set-key (kbd "<f8>") 'quickrun)

;;(use-package benchmark-init
;;  :ensure t
;;  :config
  ;; To disable collection of benchmark data after init is done.
