(in-package :io.github.cl-sdk.openapi.test)

(def-suite io.github.cl-sdk.openapi-suite
  :description "Test suite for io.github.cl-sdk.openapi.")

(in-suite io.github.cl-sdk.openapi-suite)

(test sanity
  (is (= 1 1)))

;;; ── helpers ─────────────────────────────────────────────────────────────────

(defun minimal-doc ()
  "Return a minimal valid OpenAPI 3.0 document string."
  "{\"openapi\":\"3.0.0\",\"info\":{\"title\":\"Test API\",\"version\":\"1.0.0\"},\"paths\":{}}")

;;; ── parse ───────────────────────────────────────────────────────────────────

(test parse-returns-openapi-document
  (let ((doc (io.github.cl-sdk.openapi:parse (minimal-doc))))
    (is (typep doc 'io.github.cl-sdk.openapi:openapi-document))))

(test parse-openapi-version
  (let ((doc (io.github.cl-sdk.openapi:parse (minimal-doc))))
    (is (string= "3.0.0" (io.github.cl-sdk.openapi:openapi-version doc)))))

;;; ── info ────────────────────────────────────────────────────────────────────

(test parse-info
  (let* ((doc  (io.github.cl-sdk.openapi:parse (minimal-doc)))
         (info (io.github.cl-sdk.openapi:openapi-info doc)))
    (is (typep info 'io.github.cl-sdk.openapi:info))
    (is (string= "Test API" (io.github.cl-sdk.openapi:info-title info)))
    (is (string= "1.0.0"   (io.github.cl-sdk.openapi:info-version info)))))

(test parse-info-contact-and-license
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\",
                           \"contact\":{\"name\":\"Alice\",\"email\":\"a@example.com\"},
                           \"license\":{\"name\":\"MIT\",\"url\":\"https://mit-license.org\"}},
                 \"paths\":{}}")
         (info (io.github.cl-sdk.openapi:openapi-info (io.github.cl-sdk.openapi:parse json))))
    (is (typep (io.github.cl-sdk.openapi:info-contact info) 'io.github.cl-sdk.openapi:contact))
    (is (string= "Alice"          (io.github.cl-sdk.openapi:contact-name  (io.github.cl-sdk.openapi:info-contact info))))
    (is (string= "a@example.com"  (io.github.cl-sdk.openapi:contact-email (io.github.cl-sdk.openapi:info-contact info))))
    (is (typep (io.github.cl-sdk.openapi:info-license info) 'io.github.cl-sdk.openapi:license))
    (is (string= "MIT" (io.github.cl-sdk.openapi:license-name (io.github.cl-sdk.openapi:info-license info))))))

;;; ── servers ─────────────────────────────────────────────────────────────────

(test parse-servers
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"servers\":[{\"url\":\"https://api.example.com\",
                               \"description\":\"Production\"}],
                 \"paths\":{}}")
         (doc     (io.github.cl-sdk.openapi:parse json))
         (servers (io.github.cl-sdk.openapi:openapi-servers doc)))
    (is (= 1 (length servers)))
    (let ((srv (aref servers 0)))
      (is (typep srv 'io.github.cl-sdk.openapi:server))
      (is (string= "https://api.example.com" (io.github.cl-sdk.openapi:server-url srv)))
      (is (string= "Production"              (io.github.cl-sdk.openapi:server-description srv))))))

;;; ── paths ───────────────────────────────────────────────────────────────────

(test parse-paths-empty
  (let* ((doc   (io.github.cl-sdk.openapi:parse (minimal-doc)))
         (paths (io.github.cl-sdk.openapi:openapi-paths doc)))
    (is (hash-table-p paths))
    (is (zerop (hash-table-count paths)))))

(test parse-path-item-get-operation
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{\"/pets\":{\"get\":{\"operationId\":\"listPets\",
                                               \"summary\":\"List all pets\",
                                               \"responses\":{\"200\":{\"description\":\"OK\"}}}}}}")
         (doc      (io.github.cl-sdk.openapi:parse json))
         (path     (gethash "/pets" (io.github.cl-sdk.openapi:openapi-paths doc)))
         (get-op   (io.github.cl-sdk.openapi:path-item-get path)))
    (is (typep path  'io.github.cl-sdk.openapi:path-item))
    (is (typep get-op 'io.github.cl-sdk.openapi:operation))
    (is (string= "listPets"      (io.github.cl-sdk.openapi:operation-id get-op)))
    (is (string= "List all pets" (io.github.cl-sdk.openapi:operation-summary get-op)))))

(test parse-operation-parameters
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{\"/pets/{id}\":{\"get\":{
                   \"operationId\":\"getPet\",
                   \"parameters\":[{\"name\":\"id\",\"in\":\"path\",\"required\":true,
                                    \"schema\":{\"type\":\"integer\"}}],
                   \"responses\":{\"200\":{\"description\":\"OK\"}}}}}}")
         (doc    (io.github.cl-sdk.openapi:parse json))
         (op     (io.github.cl-sdk.openapi:path-item-get
                  (gethash "/pets/{id}" (io.github.cl-sdk.openapi:openapi-paths doc))))
         (params (io.github.cl-sdk.openapi:operation-parameters op))
         (param  (aref params 0)))
    (is (= 1 (length params)))
    (is (typep param 'io.github.cl-sdk.openapi:parameter))
    (is (string= "id"   (io.github.cl-sdk.openapi:parameter-name param)))
    (is (string= "path" (io.github.cl-sdk.openapi:parameter-in   param)))
    (is (eq t           (io.github.cl-sdk.openapi:parameter-required param)))))

(test parse-operation-request-body
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{\"/pets\":{\"post\":{
                   \"operationId\":\"createPet\",
                   \"requestBody\":{\"required\":true,
                                    \"content\":{\"application/json\":{\"schema\":{\"type\":\"object\"}}}},
                   \"responses\":{\"201\":{\"description\":\"Created\"}}}}}}")
         (doc  (io.github.cl-sdk.openapi:parse json))
         (op   (io.github.cl-sdk.openapi:path-item-post
                (gethash "/pets" (io.github.cl-sdk.openapi:openapi-paths doc))))
         (rb   (io.github.cl-sdk.openapi:operation-request-body op)))
    (is (typep rb 'io.github.cl-sdk.openapi:request-body))
    (is (eq t (io.github.cl-sdk.openapi:request-body-required rb)))
    (is (hash-table-p (io.github.cl-sdk.openapi:request-body-content rb)))
    (let ((mt (gethash "application/json" (io.github.cl-sdk.openapi:request-body-content rb))))
      (is (typep mt 'io.github.cl-sdk.openapi:media-type))
      (let ((schema (io.github.cl-sdk.openapi:media-type-schema mt)))
        (is (typep schema 'io.github.cl-sdk.openapi:schema))
        (is (string= "object" (io.github.cl-sdk.openapi:schema-type schema)))))))

;;; ── schemas ─────────────────────────────────────────────────────────────────

(test parse-schema-basic
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{},
                 \"components\":{\"schemas\":{\"Pet\":{
                   \"type\":\"object\",
                   \"required\":[\"id\",\"name\"],
                   \"properties\":{
                     \"id\":{\"type\":\"integer\"},
                     \"name\":{\"type\":\"string\"}}}}}}")
         (doc      (io.github.cl-sdk.openapi:parse json))
         (schemas  (io.github.cl-sdk.openapi:components-schemas
                    (io.github.cl-sdk.openapi:openapi-components doc)))
         (pet      (gethash "Pet" schemas)))
    (is (typep pet 'io.github.cl-sdk.openapi:schema))
    (is (string= "object" (io.github.cl-sdk.openapi:schema-type pet)))
    (is (hash-table-p (io.github.cl-sdk.openapi:schema-properties pet)))
    (let ((id-schema (gethash "id" (io.github.cl-sdk.openapi:schema-properties pet))))
      (is (typep id-schema 'io.github.cl-sdk.openapi:schema))
      (is (string= "integer" (io.github.cl-sdk.openapi:schema-type id-schema))))))

(test parse-schema-ref
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{},
                 \"components\":{\"schemas\":{
                   \"Pets\":{\"type\":\"array\",
                             \"items\":{\"$ref\":\"#/components/schemas/Pet\"}},
                   \"Pet\":{\"type\":\"object\"}}}}")
         (doc     (io.github.cl-sdk.openapi:parse json))
         (schemas (io.github.cl-sdk.openapi:components-schemas
                   (io.github.cl-sdk.openapi:openapi-components doc)))
         (pets    (gethash "Pets" schemas))
         (items   (io.github.cl-sdk.openapi:schema-items pets)))
    (is (typep pets  'io.github.cl-sdk.openapi:schema))
    (is (string= "array" (io.github.cl-sdk.openapi:schema-type pets)))
    (is (typep items 'io.github.cl-sdk.openapi:reference))
    (is (string= "#/components/schemas/Pet" (io.github.cl-sdk.openapi:reference-ref items)))))

(test parse-schema-composition
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{},
                 \"components\":{\"schemas\":{
                   \"Combined\":{\"allOf\":[
                     {\"type\":\"object\",\"properties\":{\"a\":{\"type\":\"string\"}}},
                     {\"$ref\":\"#/components/schemas/Other\"}
                   ]},
                   \"Other\":{\"type\":\"object\"}}}}")
         (doc      (io.github.cl-sdk.openapi:parse json))
         (schemas  (io.github.cl-sdk.openapi:components-schemas
                    (io.github.cl-sdk.openapi:openapi-components doc)))
         (combined (gethash "Combined" schemas))
         (all-of   (io.github.cl-sdk.openapi:schema-all-of combined)))
    (is (= 2 (length all-of)))
    (is (typep (aref all-of 0) 'io.github.cl-sdk.openapi:schema))
    (is (typep (aref all-of 1) 'io.github.cl-sdk.openapi:reference))))

;;; ── components ──────────────────────────────────────────────────────────────

(test parse-components-security-schemes
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{},
                 \"components\":{\"securitySchemes\":{
                   \"bearerAuth\":{\"type\":\"http\",\"scheme\":\"bearer\",
                                   \"bearerFormat\":\"JWT\"}}}}")
         (doc      (io.github.cl-sdk.openapi:parse json))
         (schemes  (io.github.cl-sdk.openapi:components-security-schemes
                    (io.github.cl-sdk.openapi:openapi-components doc)))
         (bearer   (gethash "bearerAuth" schemes)))
    (is (typep bearer 'io.github.cl-sdk.openapi:security-scheme))
    (is (string= "http"   (io.github.cl-sdk.openapi:security-scheme-type bearer)))
    (is (string= "bearer" (io.github.cl-sdk.openapi:security-scheme-scheme bearer)))
    (is (string= "JWT"    (io.github.cl-sdk.openapi:security-scheme-bearer-format bearer)))))

(test parse-tags
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{},
                 \"tags\":[{\"name\":\"pets\",\"description\":\"Everything about pets\"}]}")
         (doc  (io.github.cl-sdk.openapi:parse json))
         (tags (io.github.cl-sdk.openapi:openapi-tags doc)))
    (is (= 1 (length tags)))
    (let ((tag (aref tags 0)))
      (is (typep tag 'io.github.cl-sdk.openapi:tag))
      (is (string= "pets" (io.github.cl-sdk.openapi:tag-name tag)))
      (is (string= "Everything about pets" (io.github.cl-sdk.openapi:tag-description tag))))))

;;; ── response ────────────────────────────────────────────────────────────────

(test parse-response
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{\"/items\":{\"get\":{
                   \"operationId\":\"getItems\",
                   \"responses\":{
                     \"200\":{\"description\":\"OK\",
                              \"content\":{\"application/json\":{\"schema\":{\"type\":\"array\",\"items\":{\"type\":\"string\"}}}}},
                     \"404\":{\"description\":\"Not Found\"}}}}}}")
         (doc      (io.github.cl-sdk.openapi:parse json))
         (op       (io.github.cl-sdk.openapi:path-item-get
                    (gethash "/items" (io.github.cl-sdk.openapi:openapi-paths doc))))
         (resp-200 (gethash "200" (io.github.cl-sdk.openapi:operation-responses op)))
         (resp-404 (gethash "404" (io.github.cl-sdk.openapi:operation-responses op))))
    (is (typep resp-200 'io.github.cl-sdk.openapi:response))
    (is (string= "OK" (io.github.cl-sdk.openapi:response-description resp-200)))
    (is (typep resp-404 'io.github.cl-sdk.openapi:response))
    (is (string= "Not Found" (io.github.cl-sdk.openapi:response-description resp-404)))))

