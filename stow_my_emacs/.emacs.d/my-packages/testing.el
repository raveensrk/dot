;; Creating a new menu pane in the menu bar to the right of “Tools” menu

(define-key-after
  global-map
  [menu-bar mymenu]
  (cons "MyMenu" (make-sparse-keymap "hoot hoot"))
  'tools )


;; creating another menu item
(define-key
  global-map
  [menu-bar mymenu pl]
  '("Previous Line" . previous-line))
arst

