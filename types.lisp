(in-package #:io.github.cl-sdk.openapi)

;;; CLOS class definitions for the OpenAPI 3.0 Specification objects.
;;;
;;; Each class mirrors an object defined in the OAS 3.0 specification.
;;; Slots are named after the specification field names, converted to
;;; Lisp kebab-case.  All slots have a corresponding accessor whose name
;;; is <class>-<slot>.  Slots are unbound by default; use SLOT-BOUNDP to
;;; test whether an optional field was present in the source document.

;;; ── Reference Object ────────────────────────────────────────────────────────

(defclass reference ()
  ((ref :initarg :ref :accessor reference-ref))
  (:documentation "An OpenAPI Reference Object ($ref pointer)."))

;;; ── Info Objects ────────────────────────────────────────────────────────────

(defclass contact ()
  ((name  :initarg :name  :accessor contact-name)
   (url   :initarg :url   :accessor contact-url)
   (email :initarg :email :accessor contact-email))
  (:documentation "Contact information for the exposed API."))

(defclass license ()
  ((name :initarg :name :accessor license-name)
   (url  :initarg :url  :accessor license-url))
  (:documentation "License information for the exposed API."))

(defclass info ()
  ((title             :initarg :title             :accessor info-title)
   (description       :initarg :description       :accessor info-description)
   (terms-of-service  :initarg :terms-of-service  :accessor info-terms-of-service)
   (contact           :initarg :contact           :accessor info-contact)
   (license           :initarg :license           :accessor info-license)
   (version           :initarg :version           :accessor info-version))
  (:documentation "Metadata about the API."))

;;; ── Server Objects ──────────────────────────────────────────────────────────

(defclass server-variable ()
  ((enum        :initarg :enum        :accessor server-variable-enum)
   (default     :initarg :default     :accessor server-variable-default)
   (description :initarg :description :accessor server-variable-description))
  (:documentation "An object representing a Server Variable for server URL template substitution."))

(defclass server ()
  ((url         :initarg :url         :accessor server-url)
   (description :initarg :description :accessor server-description)
   (variables   :initarg :variables   :accessor server-variables))
  (:documentation "An object representing a Server."))

;;; ── External Documentation ──────────────────────────────────────────────────

(defclass external-documentation ()
  ((description :initarg :description :accessor external-documentation-description)
   (url         :initarg :url         :accessor external-documentation-url))
  (:documentation "Allows referencing an external resource for extended documentation."))

;;; ── Tag ─────────────────────────────────────────────────────────────────────

(defclass tag ()
  ((name          :initarg :name          :accessor tag-name)
   (description   :initarg :description   :accessor tag-description)
   (external-docs :initarg :external-docs :accessor tag-external-docs))
  (:documentation "Adds metadata to a single tag used by the Operation Object."))

;;; ── Schema Objects ──────────────────────────────────────────────────────────

(defclass discriminator ()
  ((property-name :initarg :property-name :accessor discriminator-property-name)
   (mapping       :initarg :mapping       :accessor discriminator-mapping))
  (:documentation "Adds support for polymorphism by specifying the discriminator field."))

(defclass xml ()
  ((name      :initarg :name      :accessor xml-name)
   (namespace :initarg :namespace :accessor xml-namespace)
   (prefix    :initarg :prefix    :accessor xml-prefix)
   (attribute :initarg :attribute :accessor xml-attribute)
   (wrapped   :initarg :wrapped   :accessor xml-wrapped))
  (:documentation "Metadata that allows for more fine-tuned XML model definitions."))

(defclass schema ()
  (;; $ref
   (ref                   :initarg :ref                   :accessor schema-ref)
   ;; Metadata
   (title                 :initarg :title                 :accessor schema-title)
   (description           :initarg :description           :accessor schema-description)
   (default               :initarg :default               :accessor schema-default)
   (example               :initarg :example               :accessor schema-example)
   (deprecated            :initarg :deprecated            :accessor schema-deprecated)
   ;; Type
   (type                  :initarg :type                  :accessor schema-type)
   (format                :initarg :format                :accessor schema-format)
   (nullable              :initarg :nullable              :accessor schema-nullable)
   ;; Number constraints
   (multiple-of           :initarg :multiple-of           :accessor schema-multiple-of)
   (maximum               :initarg :maximum               :accessor schema-maximum)
   (exclusive-maximum     :initarg :exclusive-maximum     :accessor schema-exclusive-maximum)
   (minimum               :initarg :minimum               :accessor schema-minimum)
   (exclusive-minimum     :initarg :exclusive-minimum     :accessor schema-exclusive-minimum)
   ;; String constraints
   (max-length            :initarg :max-length            :accessor schema-max-length)
   (min-length            :initarg :min-length            :accessor schema-min-length)
   (pattern               :initarg :pattern               :accessor schema-pattern)
   ;; Array constraints
   (max-items             :initarg :max-items             :accessor schema-max-items)
   (min-items             :initarg :min-items             :accessor schema-min-items)
   (unique-items          :initarg :unique-items          :accessor schema-unique-items)
   (items                 :initarg :items                 :accessor schema-items)
   ;; Object constraints
   (max-properties        :initarg :max-properties        :accessor schema-max-properties)
   (min-properties        :initarg :min-properties        :accessor schema-min-properties)
   (required              :initarg :required              :accessor schema-required)
   (properties            :initarg :properties            :accessor schema-properties)
   (additional-properties :initarg :additional-properties :accessor schema-additional-properties)
   ;; Enum
   (enum                  :initarg :enum                  :accessor schema-enum)
   ;; Composition
   (all-of                :initarg :all-of                :accessor schema-all-of)
   (one-of                :initarg :one-of                :accessor schema-one-of)
   (any-of                :initarg :any-of                :accessor schema-any-of)
   (not                   :initarg :not                   :accessor schema-not)
   ;; Validation hints
   (read-only             :initarg :read-only             :accessor schema-read-only)
   (write-only            :initarg :write-only            :accessor schema-write-only)
   ;; Extended
   (discriminator         :initarg :discriminator         :accessor schema-discriminator)
   (xml                   :initarg :xml                   :accessor schema-xml)
   (external-docs         :initarg :external-docs         :accessor schema-external-docs))
  (:documentation "The Schema Object allows the definition of input and output data types."))

;;; ── Parameter / Header ──────────────────────────────────────────────────────

(defclass parameter ()
  ((name              :initarg :name              :accessor parameter-name)
   (in                :initarg :in                :accessor parameter-in)
   (description       :initarg :description       :accessor parameter-description)
   (required          :initarg :required          :accessor parameter-required)
   (deprecated        :initarg :deprecated        :accessor parameter-deprecated)
   (allow-empty-value :initarg :allow-empty-value :accessor parameter-allow-empty-value)
   (style             :initarg :style             :accessor parameter-style)
   (explode           :initarg :explode           :accessor parameter-explode)
   (allow-reserved    :initarg :allow-reserved    :accessor parameter-allow-reserved)
   (schema            :initarg :schema            :accessor parameter-schema)
   (example           :initarg :example           :accessor parameter-example)
   (examples          :initarg :examples          :accessor parameter-examples)
   (content           :initarg :content           :accessor parameter-content))
  (:documentation "Describes a single operation parameter."))

(defclass header ()
  ((description       :initarg :description       :accessor header-description)
   (required          :initarg :required          :accessor header-required)
   (deprecated        :initarg :deprecated        :accessor header-deprecated)
   (allow-empty-value :initarg :allow-empty-value :accessor header-allow-empty-value)
   (style             :initarg :style             :accessor header-style)
   (explode           :initarg :explode           :accessor header-explode)
   (allow-reserved    :initarg :allow-reserved    :accessor header-allow-reserved)
   (schema            :initarg :schema            :accessor header-schema)
   (example           :initarg :example           :accessor header-example)
   (examples          :initarg :examples          :accessor header-examples)
   (content           :initarg :content           :accessor header-content))
  (:documentation "Follows the structure of the Parameter Object with some changes."))

;;; ── Example ─────────────────────────────────────────────────────────────────

(defclass example ()
  ((summary        :initarg :summary        :accessor example-summary)
   (description    :initarg :description    :accessor example-description)
   (value          :initarg :value          :accessor example-value)
   (external-value :initarg :external-value :accessor example-external-value))
  (:documentation "Example Object."))

;;; ── Encoding ────────────────────────────────────────────────────────────────

(defclass encoding ()
  ((content-type    :initarg :content-type    :accessor encoding-content-type)
   (headers         :initarg :headers         :accessor encoding-headers)
   (style           :initarg :style           :accessor encoding-style)
   (explode         :initarg :explode         :accessor encoding-explode)
   (allow-reserved  :initarg :allow-reserved  :accessor encoding-allow-reserved))
  (:documentation "A single encoding definition applied to a single schema property."))

;;; ── Media Type ──────────────────────────────────────────────────────────────

(defclass media-type ()
  ((schema   :initarg :schema   :accessor media-type-schema)
   (example  :initarg :example  :accessor media-type-example)
   (examples :initarg :examples :accessor media-type-examples)
   (encoding :initarg :encoding :accessor media-type-encoding))
  (:documentation "Each Media Type Object provides schema and examples for the media type."))

;;; ── Request Body ────────────────────────────────────────────────────────────

(defclass request-body ()
  ((description :initarg :description :accessor request-body-description)
   (content     :initarg :content     :accessor request-body-content)
   (required    :initarg :required    :accessor request-body-required))
  (:documentation "Describes a single request body."))

;;; ── Link ────────────────────────────────────────────────────────────────────

(defclass link ()
  ((operation-ref :initarg :operation-ref :accessor link-operation-ref)
   (operation-id  :initarg :operation-id  :accessor link-operation-id)
   (parameters    :initarg :parameters    :accessor link-parameters)
   (request-body  :initarg :request-body  :accessor link-request-body)
   (description   :initarg :description   :accessor link-description)
   (server        :initarg :server        :accessor link-server))
  (:documentation "The Link object represents a possible design-time link for a response."))

;;; ── Response ────────────────────────────────────────────────────────────────

(defclass response ()
  ((description :initarg :description :accessor response-description)
   (headers     :initarg :headers     :accessor response-headers)
   (content     :initarg :content     :accessor response-content)
   (links       :initarg :links       :accessor response-links))
  (:documentation "Describes a single response from an API Operation."))

;;; ── Operation ───────────────────────────────────────────────────────────────

(defclass operation ()
  ((tags          :initarg :tags          :accessor operation-tags)
   (summary       :initarg :summary       :accessor operation-summary)
   (description   :initarg :description   :accessor operation-description)
   (external-docs :initarg :external-docs :accessor operation-external-docs)
   (operation-id  :initarg :operation-id  :accessor operation-id)
   (parameters    :initarg :parameters    :accessor operation-parameters)
   (request-body  :initarg :request-body  :accessor operation-request-body)
   (responses     :initarg :responses     :accessor operation-responses)
   (callbacks     :initarg :callbacks     :accessor operation-callbacks)
   (deprecated    :initarg :deprecated    :accessor operation-deprecated)
   (security      :initarg :security      :accessor operation-security)
   (servers       :initarg :servers       :accessor operation-servers))
  (:documentation "Describes a single API operation on a path."))

;;; ── Path Item ───────────────────────────────────────────────────────────────

(defclass path-item ()
  ((ref         :initarg :ref         :accessor path-item-ref)
   (summary     :initarg :summary     :accessor path-item-summary)
   (description :initarg :description :accessor path-item-description)
   (get         :initarg :get         :accessor path-item-get)
   (put         :initarg :put         :accessor path-item-put)
   (post        :initarg :post        :accessor path-item-post)
   (delete      :initarg :delete      :accessor path-item-delete)
   (options     :initarg :options     :accessor path-item-options)
   (head        :initarg :head        :accessor path-item-head)
   (patch       :initarg :patch       :accessor path-item-patch)
   (trace       :initarg :trace       :accessor path-item-trace)
   (servers     :initarg :servers     :accessor path-item-servers)
   (parameters  :initarg :parameters  :accessor path-item-parameters))
  (:documentation "Describes the operations available on a single path."))

;;; ── Security Scheme ─────────────────────────────────────────────────────────

(defclass oauth-flow ()
  ((authorization-url :initarg :authorization-url :accessor oauth-flow-authorization-url)
   (token-url         :initarg :token-url         :accessor oauth-flow-token-url)
   (refresh-url       :initarg :refresh-url       :accessor oauth-flow-refresh-url)
   (scopes            :initarg :scopes            :accessor oauth-flow-scopes))
  (:documentation "Configuration details for a supported OAuth Flow."))

(defclass oauth-flows ()
  ((implicit             :initarg :implicit             :accessor oauth-flows-implicit)
   (password             :initarg :password             :accessor oauth-flows-password)
   (client-credentials   :initarg :client-credentials   :accessor oauth-flows-client-credentials)
   (authorization-code   :initarg :authorization-code   :accessor oauth-flows-authorization-code))
  (:documentation "Allows configuration of the supported OAuth Flows."))

(defclass security-scheme ()
  ((type                :initarg :type                :accessor security-scheme-type)
   (description         :initarg :description         :accessor security-scheme-description)
   (name                :initarg :name                :accessor security-scheme-name)
   (in                  :initarg :in                  :accessor security-scheme-in)
   (scheme              :initarg :scheme              :accessor security-scheme-scheme)
   (bearer-format       :initarg :bearer-format       :accessor security-scheme-bearer-format)
   (flows               :initarg :flows               :accessor security-scheme-flows)
   (open-id-connect-url :initarg :open-id-connect-url :accessor security-scheme-open-id-connect-url))
  (:documentation "Defines a security scheme that can be used by the operations."))

;;; ── Components ──────────────────────────────────────────────────────────────

(defclass components ()
  ((schemas          :initarg :schemas          :accessor components-schemas)
   (responses        :initarg :responses        :accessor components-responses)
   (parameters       :initarg :parameters       :accessor components-parameters)
   (examples         :initarg :examples         :accessor components-examples)
   (request-bodies   :initarg :request-bodies   :accessor components-request-bodies)
   (headers          :initarg :headers          :accessor components-headers)
   (security-schemes :initarg :security-schemes :accessor components-security-schemes)
   (links            :initarg :links            :accessor components-links)
   (callbacks        :initarg :callbacks        :accessor components-callbacks))
  (:documentation "Holds a set of reusable objects for different aspects of the OAS."))

;;; ── OpenAPI Document ────────────────────────────────────────────────────────

(defclass openapi-document ()
  ((openapi       :initarg :openapi       :accessor openapi-version)
   (info          :initarg :info          :accessor openapi-info)
   (servers       :initarg :servers       :accessor openapi-servers)
   (paths         :initarg :paths         :accessor openapi-paths)
   (components    :initarg :components    :accessor openapi-components)
   (security      :initarg :security      :accessor openapi-security)
   (tags          :initarg :tags          :accessor openapi-tags)
   (external-docs :initarg :external-docs :accessor openapi-external-docs))
  (:documentation "The root document object of the OpenAPI document."))
