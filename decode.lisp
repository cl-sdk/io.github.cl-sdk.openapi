(in-package #:io.github.cl-sdk.openapi)

;;; JSON decoding for OpenAPI objects.
;;;
;;; Each OpenAPI object type gets a JSON:DECODE-JSON method dispatched on its
;;; class symbol.  The top-level PARSE function calls JSON:PARSE to produce a
;;; raw hash-table and then calls JSON:DECODE-JSON to convert it to a typed
;;; OPENAPI-DOCUMENT.
;;;
;;; Absent optional fields are left unbound on the resulting instance.
;;; Boolean fields (e.g. required, deprecated) are stored as T or NIL as
;;; returned by the JSON reader.

;;; ── helpers ─────────────────────────────────────────────────────────────────

(defun %ht (ht key)
  "Return the value for KEY string in hash-table HT, or NIL when absent."
  (gethash key ht))

(defmacro %set-when (instance accessor ht key)
  "Set ACCESSOR on INSTANCE to (gethash KEY HT) when the key is present."
  (let ((val   (gensym "VAL"))
        (found (gensym "FOUND")))
    `(multiple-value-bind (,val ,found) (gethash ,key ,ht)
       (when ,found
         (setf (,accessor ,instance) ,val)))))

(defmacro %set-decoded (instance accessor ht key decoder)
  "Set ACCESSOR on INSTANCE to (DECODER (gethash KEY HT)) when the key is present."
  (let ((val   (gensym "VAL"))
        (found (gensym "FOUND")))
    `(multiple-value-bind (,val ,found) (gethash ,key ,ht)
       (when ,found
         (setf (,accessor ,instance) (funcall ,decoder ,val))))))

(defun %decode-or-ref (ht decoder)
  "Return a REFERENCE when HT contains \"$ref\", otherwise call DECODER on HT."
  (if (gethash "$ref" ht)
      (make-instance 'reference :ref (gethash "$ref" ht))
      (funcall decoder ht)))

(defun %decode-array (arr decoder)
  "Decode a JSON array (vector) by applying DECODER to each element."
  (when arr
    (map 'vector decoder arr)))

(defun %decode-map (ht decoder)
  "Decode a JSON object (hash-table) into a new hash-table with values decoded by DECODER."
  (when ht
    (let ((result (make-hash-table :test 'equal)))
      (maphash (lambda (k v)
                 (setf (gethash k result) (funcall decoder v)))
               ht)
      result)))

(defun %decode-schema-or-ref (val)
  "Decode VAL as a SCHEMA or a REFERENCE (if $ref is present)."
  (when val
    (%decode-or-ref val (lambda (ht) (json:decode-json 'schema ht)))))

(defun %decode-param-or-ref (val)
  "Decode VAL as a PARAMETER or a REFERENCE."
  (when val
    (%decode-or-ref val (lambda (ht) (json:decode-json 'parameter ht)))))

(defun %decode-response-or-ref (val)
  "Decode VAL as a RESPONSE or a REFERENCE."
  (when val
    (%decode-or-ref val (lambda (ht) (json:decode-json 'response ht)))))

(defun %decode-header-or-ref (val)
  "Decode VAL as a HEADER or a REFERENCE."
  (when val
    (%decode-or-ref val (lambda (ht) (json:decode-json 'header ht)))))

(defun %decode-example-or-ref (val)
  "Decode VAL as an EXAMPLE or a REFERENCE."
  (when val
    (%decode-or-ref val (lambda (ht) (json:decode-json 'example ht)))))

(defun %decode-link-or-ref (val)
  "Decode VAL as a LINK or a REFERENCE."
  (when val
    (%decode-or-ref val (lambda (ht) (json:decode-json 'link ht)))))

(defun %decode-request-body-or-ref (val)
  "Decode VAL as a REQUEST-BODY or a REFERENCE."
  (when val
    (%decode-or-ref val (lambda (ht) (json:decode-json 'request-body ht)))))

(defun %decode-security-scheme-or-ref (val)
  "Decode VAL as a SECURITY-SCHEME or a REFERENCE."
  (when val
    (%decode-or-ref val (lambda (ht) (json:decode-json 'security-scheme ht)))))

;;; ── Reference ───────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'reference)) ht)
  (make-instance 'reference :ref (gethash "$ref" ht)))

;;; ── Contact ─────────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'contact)) ht)
  (let ((obj (make-instance 'contact)))
    (%set-when obj contact-name  ht "name")
    (%set-when obj contact-url   ht "url")
    (%set-when obj contact-email ht "email")
    obj))

;;; ── License ─────────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'license)) ht)
  (let ((obj (make-instance 'license)))
    (%set-when obj license-name ht "name")
    (%set-when obj license-url  ht "url")
    obj))

;;; ── Info ────────────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'info)) ht)
  (let ((obj (make-instance 'info)))
    (%set-when obj info-title            ht "title")
    (%set-when obj info-description      ht "description")
    (%set-when obj info-terms-of-service ht "termsOfService")
    (%set-when obj info-version          ht "version")
    (%set-decoded obj info-contact ht "contact"
                  (lambda (v) (json:decode-json 'contact v)))
    (%set-decoded obj info-license ht "license"
                  (lambda (v) (json:decode-json 'license v)))
    obj))

;;; ── Server Variable ─────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'server-variable)) ht)
  (let ((obj (make-instance 'server-variable)))
    (%set-when obj server-variable-enum        ht "enum")
    (%set-when obj server-variable-default     ht "default")
    (%set-when obj server-variable-description ht "description")
    obj))

;;; ── Server ──────────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'server)) ht)
  (let ((obj (make-instance 'server)))
    (%set-when obj server-url         ht "url")
    (%set-when obj server-description ht "description")
    (%set-decoded obj server-variables ht "variables"
                  (lambda (vars)
                    (%decode-map vars
                                 (lambda (v) (json:decode-json 'server-variable v)))))
    obj))

;;; ── External Documentation ──────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'external-documentation)) ht)
  (let ((obj (make-instance 'external-documentation)))
    (%set-when obj external-documentation-description ht "description")
    (%set-when obj external-documentation-url         ht "url")
    obj))

;;; ── Tag ─────────────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'tag)) ht)
  (let ((obj (make-instance 'tag)))
    (%set-when obj tag-name        ht "name")
    (%set-when obj tag-description ht "description")
    (%set-decoded obj tag-external-docs ht "externalDocs"
                  (lambda (v) (json:decode-json 'external-documentation v)))
    obj))

;;; ── Discriminator ───────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'discriminator)) ht)
  (let ((obj (make-instance 'discriminator)))
    (%set-when obj discriminator-property-name ht "propertyName")
    (%set-when obj discriminator-mapping       ht "mapping")
    obj))

;;; ── XML ─────────────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'xml)) ht)
  (let ((obj (make-instance 'xml)))
    (%set-when obj xml-name      ht "name")
    (%set-when obj xml-namespace ht "namespace")
    (%set-when obj xml-prefix    ht "prefix")
    (%set-when obj xml-attribute ht "attribute")
    (%set-when obj xml-wrapped   ht "wrapped")
    obj))

;;; ── Schema ──────────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'schema)) ht)
  ;; A $ref at this level means the whole schema is a reference.
  (when (gethash "$ref" ht)
    (return-from json:decode-json
      (make-instance 'reference :ref (gethash "$ref" ht))))
  (let ((obj (make-instance 'schema)))
    ;; Metadata
    (%set-when obj schema-title       ht "title")
    (%set-when obj schema-description ht "description")
    (%set-when obj schema-deprecated  ht "deprecated")
    ;; Type & format
    (%set-when obj schema-type     ht "type")
    (%set-when obj schema-format   ht "format")
    (%set-when obj schema-nullable ht "nullable")
    ;; Number constraints
    (%set-when obj schema-multiple-of       ht "multipleOf")
    (%set-when obj schema-maximum           ht "maximum")
    (%set-when obj schema-exclusive-maximum ht "exclusiveMaximum")
    (%set-when obj schema-minimum           ht "minimum")
    (%set-when obj schema-exclusive-minimum ht "exclusiveMinimum")
    ;; String constraints
    (%set-when obj schema-max-length ht "maxLength")
    (%set-when obj schema-min-length ht "minLength")
    (%set-when obj schema-pattern    ht "pattern")
    ;; Array constraints
    (%set-when obj schema-max-items    ht "maxItems")
    (%set-when obj schema-min-items    ht "minItems")
    (%set-when obj schema-unique-items ht "uniqueItems")
    (%set-decoded obj schema-items ht "items"
                  #'%decode-schema-or-ref)
    ;; Object constraints
    (%set-when obj schema-max-properties ht "maxProperties")
    (%set-when obj schema-min-properties ht "minProperties")
    (%set-when obj schema-required       ht "required")
    (%set-decoded obj schema-properties ht "properties"
                  (lambda (props)
                    (%decode-map props #'%decode-schema-or-ref)))
    (multiple-value-bind (ap ap-present) (gethash "additionalProperties" ht)
      (when ap-present
        (setf (schema-additional-properties obj)
              ;; additionalProperties can be a boolean or a schema/ref.
              (if (typep ap 'hash-table)
                  (%decode-schema-or-ref ap)
                  ap))))
    ;; Enum & default
    (%set-when obj schema-enum    ht "enum")
    (%set-when obj schema-default ht "default")
    (%set-when obj schema-example ht "example")
    ;; Composition
    (%set-decoded obj schema-all-of ht "allOf"
                  (lambda (arr) (%decode-array arr #'%decode-schema-or-ref)))
    (%set-decoded obj schema-one-of ht "oneOf"
                  (lambda (arr) (%decode-array arr #'%decode-schema-or-ref)))
    (%set-decoded obj schema-any-of ht "anyOf"
                  (lambda (arr) (%decode-array arr #'%decode-schema-or-ref)))
    (%set-decoded obj schema-not ht "not"
                  #'%decode-schema-or-ref)
    ;; Validation hints
    (%set-when obj schema-read-only  ht "readOnly")
    (%set-when obj schema-write-only ht "writeOnly")
    ;; Extended
    (%set-decoded obj schema-discriminator ht "discriminator"
                  (lambda (v) (json:decode-json 'discriminator v)))
    (%set-decoded obj schema-xml ht "xml"
                  (lambda (v) (json:decode-json 'xml v)))
    (%set-decoded obj schema-external-docs ht "externalDocs"
                  (lambda (v) (json:decode-json 'external-documentation v)))
    obj))

;;; ── Example ─────────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'example)) ht)
  (let ((obj (make-instance 'example)))
    (%set-when obj example-summary        ht "summary")
    (%set-when obj example-description    ht "description")
    (%set-when obj example-value          ht "value")
    (%set-when obj example-external-value ht "externalValue")
    obj))

;;; ── Encoding ────────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'encoding)) ht)
  (let ((obj (make-instance 'encoding)))
    (%set-when obj encoding-content-type   ht "contentType")
    (%set-decoded obj encoding-headers ht "headers"
                  (lambda (headers)
                    (%decode-map headers #'%decode-header-or-ref)))
    (%set-when obj encoding-style          ht "style")
    (%set-when obj encoding-explode        ht "explode")
    (%set-when obj encoding-allow-reserved ht "allowReserved")
    obj))

;;; ── Media Type ──────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'media-type)) ht)
  (let ((obj (make-instance 'media-type)))
    (%set-decoded obj media-type-schema ht "schema"
                  #'%decode-schema-or-ref)
    (%set-when obj media-type-example ht "example")
    (%set-decoded obj media-type-examples ht "examples"
                  (lambda (exs)
                    (%decode-map exs #'%decode-example-or-ref)))
    (%set-decoded obj media-type-encoding ht "encoding"
                  (lambda (encs)
                    (%decode-map encs
                                 (lambda (v) (json:decode-json 'encoding v)))))
    obj))

;;; ── Parameter ───────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'parameter)) ht)
  (when (gethash "$ref" ht)
    (return-from json:decode-json
      (make-instance 'reference :ref (gethash "$ref" ht))))
  (let ((obj (make-instance 'parameter)))
    (%set-when obj parameter-name              ht "name")
    (%set-when obj parameter-in                ht "in")
    (%set-when obj parameter-description       ht "description")
    (%set-when obj parameter-required          ht "required")
    (%set-when obj parameter-deprecated        ht "deprecated")
    (%set-when obj parameter-allow-empty-value ht "allowEmptyValue")
    (%set-when obj parameter-style             ht "style")
    (%set-when obj parameter-explode           ht "explode")
    (%set-when obj parameter-allow-reserved    ht "allowReserved")
    (%set-decoded obj parameter-schema ht "schema"
                  #'%decode-schema-or-ref)
    (%set-when obj parameter-example ht "example")
    (%set-decoded obj parameter-examples ht "examples"
                  (lambda (exs)
                    (%decode-map exs #'%decode-example-or-ref)))
    (%set-decoded obj parameter-content ht "content"
                  (lambda (content)
                    (%decode-map content
                                 (lambda (v) (json:decode-json 'media-type v)))))
    obj))

;;; ── Header ──────────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'header)) ht)
  (when (gethash "$ref" ht)
    (return-from json:decode-json
      (make-instance 'reference :ref (gethash "$ref" ht))))
  (let ((obj (make-instance 'header)))
    (%set-when obj header-description       ht "description")
    (%set-when obj header-required          ht "required")
    (%set-when obj header-deprecated        ht "deprecated")
    (%set-when obj header-allow-empty-value ht "allowEmptyValue")
    (%set-when obj header-style             ht "style")
    (%set-when obj header-explode           ht "explode")
    (%set-when obj header-allow-reserved    ht "allowReserved")
    (%set-decoded obj header-schema ht "schema"
                  #'%decode-schema-or-ref)
    (%set-when obj header-example ht "example")
    (%set-decoded obj header-examples ht "examples"
                  (lambda (exs)
                    (%decode-map exs #'%decode-example-or-ref)))
    (%set-decoded obj header-content ht "content"
                  (lambda (content)
                    (%decode-map content
                                 (lambda (v) (json:decode-json 'media-type v)))))
    obj))

;;; ── Request Body ────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'request-body)) ht)
  (when (gethash "$ref" ht)
    (return-from json:decode-json
      (make-instance 'reference :ref (gethash "$ref" ht))))
  (let ((obj (make-instance 'request-body)))
    (%set-when obj request-body-description ht "description")
    (%set-when obj request-body-required    ht "required")
    (%set-decoded obj request-body-content ht "content"
                  (lambda (content)
                    (%decode-map content
                                 (lambda (v) (json:decode-json 'media-type v)))))
    obj))

;;; ── Link ────────────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'link)) ht)
  (when (gethash "$ref" ht)
    (return-from json:decode-json
      (make-instance 'reference :ref (gethash "$ref" ht))))
  (let ((obj (make-instance 'link)))
    (%set-when obj link-operation-ref ht "operationRef")
    (%set-when obj link-operation-id  ht "operationId")
    (%set-when obj link-parameters    ht "parameters")
    (%set-when obj link-request-body  ht "requestBody")
    (%set-when obj link-description   ht "description")
    (%set-decoded obj link-server ht "server"
                  (lambda (v) (json:decode-json 'server v)))
    obj))

;;; ── Response ────────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'response)) ht)
  (when (gethash "$ref" ht)
    (return-from json:decode-json
      (make-instance 'reference :ref (gethash "$ref" ht))))
  (let ((obj (make-instance 'response)))
    (%set-when obj response-description ht "description")
    (%set-decoded obj response-headers ht "headers"
                  (lambda (headers)
                    (%decode-map headers #'%decode-header-or-ref)))
    (%set-decoded obj response-content ht "content"
                  (lambda (content)
                    (%decode-map content
                                 (lambda (v) (json:decode-json 'media-type v)))))
    (%set-decoded obj response-links ht "links"
                  (lambda (links)
                    (%decode-map links #'%decode-link-or-ref)))
    obj))

;;; ── Operation ───────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'operation)) ht)
  (let ((obj (make-instance 'operation)))
    (%set-when obj operation-tags        ht "tags")
    (%set-when obj operation-summary     ht "summary")
    (%set-when obj operation-description ht "description")
    (%set-when obj operation-id          ht "operationId")
    (%set-when obj operation-deprecated  ht "deprecated")
    (%set-when obj operation-security    ht "security")
    (%set-decoded obj operation-external-docs ht "externalDocs"
                  (lambda (v) (json:decode-json 'external-documentation v)))
    (%set-decoded obj operation-parameters ht "parameters"
                  (lambda (params)
                    (%decode-array params #'%decode-param-or-ref)))
    (%set-decoded obj operation-request-body ht "requestBody"
                  #'%decode-request-body-or-ref)
    (%set-decoded obj operation-responses ht "responses"
                  (lambda (responses)
                    (%decode-map responses #'%decode-response-or-ref)))
    (%set-decoded obj operation-callbacks ht "callbacks"
                  (lambda (cbs)
                    (%decode-map cbs
                                 (lambda (v)
                                   (%decode-or-ref v
                                                   (lambda (aa)
                                                     (%decode-map aa
                                                                  (lambda (item)
                                                                    (%decode-or-ref item (lambda (bb) (json:decode-json 'path-item bb)))))))))))
    (%set-decoded obj operation-servers ht "servers"
                  (lambda (servers)
                    (%decode-array servers
                                   (lambda (v) (json:decode-json 'server v)))))
    obj))

;;; ── Path Item ───────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'path-item)) ht)
  (let ((obj (make-instance 'path-item)))
    (%set-when obj path-item-ref         ht "$ref")
    (%set-when obj path-item-summary     ht "summary")
    (%set-when obj path-item-description ht "description")
    (flet ((decode-op (v) (json:decode-json 'operation v)))
      (%set-decoded obj path-item-get     ht "get"     #'decode-op)
      (%set-decoded obj path-item-put     ht "put"     #'decode-op)
      (%set-decoded obj path-item-post    ht "post"    #'decode-op)
      (%set-decoded obj path-item-delete  ht "delete"  #'decode-op)
      (%set-decoded obj path-item-options ht "options" #'decode-op)
      (%set-decoded obj path-item-head    ht "head"    #'decode-op)
      (%set-decoded obj path-item-patch   ht "patch"   #'decode-op)
      (%set-decoded obj path-item-trace   ht "trace"   #'decode-op))
    (%set-decoded obj path-item-servers ht "servers"
                  (lambda (servers)
                    (%decode-array servers
                                   (lambda (v) (json:decode-json 'server v)))))
    (%set-decoded obj path-item-parameters ht "parameters"
                  (lambda (params)
                    (%decode-array params #'%decode-param-or-ref)))
    obj))

;;; ── Security Scheme ─────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'oauth-flow)) ht)
  (let ((obj (make-instance 'oauth-flow)))
    (%set-when obj oauth-flow-authorization-url ht "authorizationUrl")
    (%set-when obj oauth-flow-token-url         ht "tokenUrl")
    (%set-when obj oauth-flow-refresh-url       ht "refreshUrl")
    (%set-when obj oauth-flow-scopes            ht "scopes")
    obj))

(defmethod json:decode-json ((type (eql 'oauth-flows)) ht)
  (let ((obj (make-instance 'oauth-flows)))
    (flet ((decode-flow (v) (json:decode-json 'oauth-flow v)))
      (%set-decoded obj oauth-flows-implicit             ht "implicit"            #'decode-flow)
      (%set-decoded obj oauth-flows-password             ht "password"            #'decode-flow)
      (%set-decoded obj oauth-flows-client-credentials   ht "clientCredentials"   #'decode-flow)
      (%set-decoded obj oauth-flows-authorization-code   ht "authorizationCode"   #'decode-flow))
    obj))

(defmethod json:decode-json ((type (eql 'security-scheme)) ht)
  (when (gethash "$ref" ht)
    (return-from json:decode-json
      (make-instance 'reference :ref (gethash "$ref" ht))))
  (let ((obj (make-instance 'security-scheme)))
    (%set-when obj security-scheme-type                ht "type")
    (%set-when obj security-scheme-description         ht "description")
    (%set-when obj security-scheme-name                ht "name")
    (%set-when obj security-scheme-in                  ht "in")
    (%set-when obj security-scheme-scheme              ht "scheme")
    (%set-when obj security-scheme-bearer-format       ht "bearerFormat")
    (%set-when obj security-scheme-open-id-connect-url ht "openIdConnectUrl")
    (%set-decoded obj security-scheme-flows ht "flows"
                  (lambda (v) (json:decode-json 'oauth-flows v)))
    obj))

;;; ── Components ──────────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'components)) ht)
  (let ((obj (make-instance 'components)))
    (%set-decoded obj components-schemas ht "schemas"
                  (lambda (schemas)
                    (%decode-map schemas #'%decode-schema-or-ref)))
    (%set-decoded obj components-responses ht "responses"
                  (lambda (responses)
                    (%decode-map responses #'%decode-response-or-ref)))
    (%set-decoded obj components-parameters ht "parameters"
                  (lambda (params)
                    (%decode-map params #'%decode-param-or-ref)))
    (%set-decoded obj components-examples ht "examples"
                  (lambda (exs)
                    (%decode-map exs #'%decode-example-or-ref)))
    (%set-decoded obj components-request-bodies ht "requestBodies"
                  (lambda (rbs)
                    (%decode-map rbs #'%decode-request-body-or-ref)))
    (%set-decoded obj components-headers ht "headers"
                  (lambda (headers)
                    (%decode-map headers #'%decode-header-or-ref)))
    (%set-decoded obj components-security-schemes ht "securitySchemes"
                  (lambda (schemes)
                    (%decode-map schemes #'%decode-security-scheme-or-ref)))
    (%set-decoded obj components-links ht "links"
                  (lambda (links)
                    (%decode-map links #'%decode-link-or-ref)))
    (%set-decoded obj components-callbacks ht "callbacks"
                  (lambda (cbs)
                    (%decode-map cbs
                                 (lambda (v)
                                   (%decode-or-ref v
                                                   (lambda (aa)
                                                     (%decode-map aa
                                                                  (lambda (item)
                                                                    (%decode-or-ref item (lambda (bb) (json:decode-json 'path-item bb)))))))))))
    obj))

;;; ── OpenAPI Document ────────────────────────────────────────────────────────

(defmethod json:decode-json ((type (eql 'openapi-document)) ht)
  (let ((doc (make-instance 'openapi-document)))
    (%set-when doc openapi-version ht "openapi")
    (%set-decoded doc openapi-info ht "info"
                  (lambda (v) (json:decode-json 'info v)))
    (%set-decoded doc openapi-servers ht "servers"
                  (lambda (servers)
                    (%decode-array servers
                                   (lambda (v) (json:decode-json 'server v)))))
    (%set-decoded doc openapi-paths ht "paths"
                  (lambda (paths)
                    (%decode-map paths
                                 (lambda (v)
                                   (%decode-or-ref v
                                                   (lambda (aa) (json:decode-json 'path-item aa)))))))
    (%set-decoded doc openapi-components ht "components"
                  (lambda (v) (json:decode-json 'components v)))
    (%set-when doc openapi-security ht "security")
    (%set-decoded doc openapi-tags ht "tags"
                  (lambda (tags)
                    (%decode-array tags
                                   (lambda (v) (json:decode-json 'tag v)))))
    (%set-decoded doc openapi-external-docs ht "externalDocs"
                  (lambda (v) (json:decode-json 'external-documentation v)))
    doc))

;;; ── Public API ──────────────────────────────────────────────────────────────

(defun parse (input)
  "Parse an OpenAPI 3.0 document from INPUT and return an OPENAPI-DOCUMENT.

INPUT may be a JSON string, a character stream, or a binary (octet) stream.
Binary streams are decoded as UTF-8 via flexi-streams (delegated to cl-json).

Example:
  (io.github.cl-sdk.openapi:parse \"{\\\"openapi\\\":\\\"3.0.0\\\",\\\"info\\\":{...},...}\")"
  (json:decode-json 'openapi-document (json:parse input)))
