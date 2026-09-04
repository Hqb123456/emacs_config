;; -*- lexical-binding: t; -*-

;; ============================================================
;; early-init.el - Emacs 启动加速配置
;; 在 init.el 之前加载
;; ============================================================

;; 1. GC 优化 - 启动时增大阈值，减少 GC 次数
(setq gc-cons-threshold 100000000   ; 100 MB
      gc-cons-percentage 0.6)

;; 2. 减少文件系统检查（大幅加速启动）
(setq file-name-handler-alist nil)

;; 3. 禁用不必要的 UI 元素
(setq inhibit-x-resources t
      inhibit-startup-message t
      inhibit-startup-echo-area-message t
      inhibit-splash-screen t
      initial-scratch-message nil
      inhibit-default-init t)

;; 4. 原生编译优化（Emacs 28+）
(when (fboundp 'native-comp-available-p)
  (setq native-comp-async-report-warnings-errors nil
        native-comp-deferred-compilation t
        native-comp-speed 2            ; 编译优化级别 1-3
        native-comp-verbose 0
        comp-deferred-compilation t))

;; 5. 更快的 JSON 解析
(setq json-serializer 'native)

;; 6. 加载新版本优先
(setq load-prefer-newer t)

;; 7. 禁用包签名检查（加速）
(setq package-check-signature nil
      package-unsigned-archives nil)

;; 8. 字体优化
(setq xft-ignore-color-fonts t)

;; 9. 启动后恢复 GC 和文件处理器
(add-hook 'after-init-hook
          (lambda ()
            (setq gc-cons-threshold 800000    ; 800 KB
                  gc-cons-percentage 0.1
                  file-name-handler-alist
                  (let ((default file-name-handler-alist))
                    (append default file-name-handler-alist)))
            ;; 显示启动时间（可选）
            (message "Emacs loaded in %s seconds" (emacs-init-time))))

;; 10. 记录加载时间（调试用）
(message "Early-init.el loaded at %s" (current-time-string))
