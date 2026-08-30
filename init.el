;; init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; 包管理器设置
(require 'package)

;; 使用国内镜像源加速
(setq package-archives
      '(("gnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
        ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
        ("melpa" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

;; 兼容 Emacs 27 以下版本（新版会自动初始化）
(package-initialize)

;; 安装 use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; 1. 加载 dired-x 扩展（如果尚未加载）
(require 'dired-x)

;; 2. 在进入 dired 模式时，自动打开 omit 模式
(add-hook 'dired-mode-hook 'dired-omit-mode)

;; 隐藏所有以 "." 开头的文件/目录，但保留 "." 和 ".."
;; 正则表达式含义：以 "." 开头，且第二个字符不是 "."（也不允许是行尾）
(setq dired-omit-files "\\`\\.[^.]\\|\\`\\.[^.]\\'")

(with-eval-after-load 'dired
  ;; C-c C-c 进入编辑模式
  (define-key dired-mode-map (kbd "C-c C-c") 'wdired-change-to-wdired-mode)

  ;; 其他好用的设置
  (setq dired-listing-switches "-alh")        ; 人性化显示
  (setq dired-dwim-target t)                  ; 智能目标目录
  (setq delete-by-moving-to-trash t)          ; 删除到回收站
  (setq dired-recursive-deletes 'top)         ; 递归删除
  (setq dired-recursive-copies 'always))      ; 递归复制

;; 关闭自动保存
(setq auto-save-default nil)
(setq auto-save-list-file-prefix nil)

;; 关闭备份文件
(setq make-backup-files nil)
(setq backup-inhibited t)

;; 关闭锁文件
(setq create-lockfiles nil)

(toggle-frame-fullscreen)

;; 选中即删除
(delete-selection-mode 1)

(setq ring-bell-function 'ignore)

;; 单独设置中文字体，使用完整路径
(set-fontset-font t 'han
                  (font-spec :file "/home/shorin/.local/share/fonts/pingFangSC/PingFangSC-Medium.otf"))

;; 1. 字体配置文件路径
(defvar my-font-config-file
  (expand-file-name "font-config.el" user-emacs-directory)
  "字体配置文件路径")

;; 2. 默认字体设置
(defvar my-default-font-family "Iosevka"
  "默认字体名称")
(defvar my-default-font-size 12
  "默认字体大小（点数）")

;; 3. 保存字体配置
(defun my-save-font-config ()
  "保存当前字体设置到 font-config.el"
  (interactive)
  (with-temp-file my-font-config-file
    (insert
     (format ";; 由 my-save-font-config 自动生成\n")
     (format "(set-face-attribute 'default nil\n")
     (format "                    :family \"%s\"\n"
             (face-attribute 'default :family))
     (format "                    :height %d)\n"
             (face-attribute 'default :height))
     (format "(setq my-current-font-family \"%s\"\n"
             (face-attribute 'default :family))
     (format "      my-current-font-size %d)\n"
             (/ (face-attribute 'default :height) 10))))
  (message "字体配置已保存到 %s" my-font-config-file))

;; 4. 加载字体配置
(defun my-load-font-config ()
  "加载保存的字体配置"
  (interactive)
  (if (file-exists-p my-font-config-file)
      (progn
        (load my-font-config-file)
        (message "已加载字体配置: %s (%s pt)"
                 (face-attribute 'default :family)
                 (/ (face-attribute 'default :height) 10)))
    (message "字体配置文件不存在，使用默认字体")
    (set-face-attribute 'default nil
                        :family my-default-font-family
                        :height (* 10 my-default-font-size))))

;; 5. 设置字体
(defun my/set-font (family &optional size)
  "交互式设置 Emacs 字体 FAMILY 和 SIZE
如果未指定 SIZE，则保持当前大小"
  (interactive
   (let ((current-family (face-attribute 'default :family))
         (current-size (/ (face-attribute 'default :height) 10)))
     (list
      ;; 选择字体族
      (completing-read
       (format "Font family [%s]: " current-family)
       (font-family-list)
       nil
       t
       current-family)
      ;; 选择字体大小
      (read-number
       (format "Font size (points) [%d]: " current-size)
       current-size))))

  (set-face-attribute 'default nil
                      :family family
                      :height (* 10 size))

  (message "当前字体: %s (%s pt)" family size)

  ;; 询问是否保存
  (when (y-or-n-p "是否保存此字体配置？")
    (my-save-font-config)))

;; 6. 增大/减小字体
(defun my/increase-font-size (&optional increment)
  "增大字体大小，INCREMENT 默认为 +1"
  (interactive "p")
  (let* ((increment (or increment 1))
         (current-size (/ (face-attribute 'default :height) 10))
         (new-size (+ current-size increment)))
    (set-face-attribute 'default nil
                        :height (* 10 new-size))
    (message "当前字体大小: %s pt" new-size)))

(defun my/decrease-font-size (&optional decrement)
  "减小字体大小，DECREMENT 默认为 -1"
  (interactive "p")
  (my/increase-font-size (- (or decrement 1))))

;; 7. 重置字体大小
(defun my/reset-font-size ()
  "重置字体大小为默认值"
  (interactive)
  (set-face-attribute 'default nil
                      :height (* 10 my-default-font-size))
  (message "字体已重置为: %s pt" my-default-font-size))

;; 8. 切换 Iosevka 变体
(defun my/switch-iosevka-variant (variant)
  "切换到指定的 Iosevka 变体
VARIANT 可选: 'Iosevka', 'Iosevka Term', 'Iosevka Fixed', 'Iosevka Curly'"
  (interactive
   (list
    (completing-read
     "Iosevka variant: "
     '("Iosevka" "Iosevka Term" "Iosevka Fixed"
       "Iosevka Curly" "Iosevka Curly Term"
       "Iosevka Aile" "Iosevka Etoile")
     nil t)))
  (let ((current-size (/ (face-attribute 'default :height) 10)))
    (set-face-attribute 'default nil
                        :family variant
                        :height (* 10 current-size))
    (message "已切换至 %s (%s pt)" variant current-size)
    (when (y-or-n-p "是否保存此配置？")
      (my-save-font-config))))

(setq inhibit-startup-screen t)
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)
(show-paren-mode t)
(setq query-replace-highlight t)
(setq isearch-lazy-highlight t)
(setq-default case-fold-search)
(setq use-short-answers t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(global-auto-revert-mode t)
(electric-pair-mode t)
(setq compile-command "")
(setq company-backends '(company-capf company-dabbrev-code company-files company-keywords company-ispell))

(global-set-key (kbd "C-S-<left>") 'windmove-left)
(global-set-key (kbd "C-S-<down>") 'windmove-down)
(global-set-key (kbd "C-S-<up>") 'windmove-up)
(global-set-key (kbd "C-S-<right>") 'windmove-right)
(global-set-key (kbd "C-z") 'set-mark-command)
(global-set-key (kbd "C-M-z") 'rectangle-mark-mode)

(global-set-key (kbd "C-,") 'rc/duplicate-line)

(defun rc/duplicate-line ()
  "复制当前行 (Duplicate current line)"
  (interactive)
  (let ((column (- (point) (point-at-bol)))  ;; 记录光标列位置
    (line (let ((s (thing-at-point 'line t))) ;; 获取当前行内容
            (if s (string-remove-suffix "\n" s) "")))) ;; 移除换行符
    (move-end-of-line 1)  ;; 移动到行尾
    (newline)             ;; 插入新行
    (insert line)         ;; 插入复制的行内容
    (move-beginning-of-line 1) ;; 移动到行首
    (forward-char column)))    ;; 恢复光标位置

(use-package which-key
  :ensure t
  :init (which-key-mode)
  :diminish which-key-mode
  :custom (which-key-idle-delay 0.5)
  :config (which-key-setup-side-window-right-bottom))

;; 补全框架
(use-package vertico
  :ensure t
  :config
  (vertico-mode 1))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic)) ;; orderless 风格
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :ensure t
  :config
  (marginalia-mode 1))

(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)        ;; 激活操作菜单
   ("M-." . embark-dwim)))     ;; 智能执行操作

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

(use-package git-gutter
  :ensure t
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0.2)
  (setq git-gutter:live-mode t)
  (global-git-gutter-mode t))

(use-package move-text
  :ensure t
  :bind (("M-p" . move-text-up)
	 ("M-n" . move-text-down)))

(use-package monokai-theme
  :ensure t)

(use-package catppuccin-theme
  :ensure t)

(use-package gruber-darker-theme
  :ensure t)

(use-package doom-themes
  :ensure t)

(use-package dashboard
  :ensure t
  :config
  ;; 设置启动时显示 dashboard
  (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
  ;; dashboard 显示项目
  (setq dashboard-items '((recents . 5)  ; 最近文件
                          (bookmarks . 5) ; 书签
                          (projects . 5))) ; 项目
  (setq dashboard-banner-logo-title "isovika emacs") ; 标题
;;  (setq dashboard-footer-messages '("人生如戏呀，靓仔！\n hi" "Life is like a drama!"))
(setq dashboard-footer-messages '("人生如戏呀，靓仔！" "Life is like a drama!"))

  ;; 居中对齐
  (setq dashboard-center-content t)
  (dashboard-setup-startup-hook))

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map)))

;; rainbow-delimiters
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode)   ;; 在编程模式下启用
  ;; 如果需要排除某些模式，可以在这里配置
  :config
  ;; (add-hook 'some-mode-hook (lambda () (rainbow-delimiters-mode -1)))
)

(use-package colorful-mode
  :ensure t
  :config (global-colorful-mode t))

;; undo-tree
(use-package undo-tree
  :ensure t
  :init
  (global-undo-tree-mode 1)        ; 启用全局 undo-tree
  :config
  (setq undo-tree-auto-save-history nil)
  (global-set-key (kbd "C-c u") 'undo-tree-visualize))  ; 可视化撤销树

(use-package eglot
  :ensure t
  :hook (prog-mode . eglot-ensure))

(use-package company
  :ensure t
  :hook (after-init . global-company-mode) ;; 启动时启用
  :custom
  ;; 延迟 0.1 秒弹出候选
  (company-idle-delay 0.01)
  ;; 输入 2 个字符开始补全
  (company-minimum-prefix-length 1)
  ;; 候选列表最多显示 20 条
  (company-tooltip-limit 20)
  ;; 对齐注释
  (company-tooltip-align-annotations t)
  ;; 显示快捷键提示
  (company-show-quick-access)
  :config
  (add-to-list 'company-frontends 'company-preview-frontend)
  (add-hook 'after-init-hook 'company-tng-mode)) ;; Tab and go
  ;;(setq company-yasnippet-alias-completion t) ;; snippet

(use-package nix-mode :ensure t)
(use-package vterm
  :ensure t
  :bind ("C-c C-t " . vterm))

;; LSP（精简配置，仅针对 nix/c/c++/lua）
(use-package lsp-mode
  :ensure t
  :hook ((nix-mode . lsp)
         (c++-mode . lsp)
         (lua-mode . lsp))
  :custom (lsp-auto-guess-root t))

(use-package lsp-ui
  :ensure t
  :hook (lsp-mode . lsp-ui-mode))

;; 主要模式
(use-package markdown-mode :ensure t)
(use-package yaml-mode :ensure t)
(use-package json-mode :ensure t)

;; 编辑工具
(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C-S-c C-n" . mc/mark-next-like-this)
         ("C-S-c C-p" . mc/mark-previous-like-this)
         ("C-S-c C-a" . mc/mark-all-like-this)))

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

;; 文件树
(use-package treemacs
  :ensure t
  :bind ("C-c t" . treemacs-select-window))

;; UI 增强
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package emojify
  :ensure t)

(add-hook 'c++-mode-hook
          (lambda ()
            (c-set-style "linux")          ; 使用 Linux 内核风格，缩进 4 空格
            (setq c-basic-offset 4)        ; 缩进宽度 4
            (setq indent-tabs-mode nil)))    ; 使用空格代替 Tab

;; 9.
(my-load-font-config)
(load custom-file)
