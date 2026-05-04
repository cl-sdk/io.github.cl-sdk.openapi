(asdf:defsystem #:cl-openapi.test
  :description "FiveAM test suite for cl-openapi."
  :license "Unlicense"
  :version "0.0.1"
  :depends-on (#:fiveam
               #:cl-openapi)
  :pathname "t"
  :serial t
  :components ((:file "package")
               (:file "cl-openapi-tests")))
