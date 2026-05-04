(in-package :cl-openapi.test)

(def-suite cl-openapi-suite
  :description "Test suite for cl-openapi.")

(in-suite cl-openapi-suite)

(test sanity
  (is (= 1 1)))

;;; ── helpers ─────────────────────────────────────────────────────────────────

(defun minimal-doc ()
  "Return a minimal valid OpenAPI 3.0 document string."
  "{\"openapi\":\"3.0.0\",\"info\":{\"title\":\"Test API\",\"version\":\"1.0.0\"},\"paths\":{}}")

;;; ── parse ───────────────────────────────────────────────────────────────────

(test parse-returns-openapi-document
  (let ((doc (cl-openapi:parse (minimal-doc))))
    (is (typep doc 'cl-openapi:openapi-document))))

(test parse-openapi-version
  (let ((doc (cl-openapi:parse (minimal-doc))))
    (is (string= "3.0.0" (cl-openapi:openapi-version doc)))))

;;; ── info ────────────────────────────────────────────────────────────────────

(test parse-info
  (let* ((doc  (cl-openapi:parse (minimal-doc)))
         (info (cl-openapi:openapi-info doc)))
    (is (typep info 'cl-openapi:info))
    (is (string= "Test API" (cl-openapi:info-title info)))
    (is (string= "1.0.0"   (cl-openapi:info-version info)))))

(test parse-info-contact-and-license
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\",
                           \"contact\":{\"name\":\"Alice\",\"email\":\"a@example.com\"},
                           \"license\":{\"name\":\"MIT\",\"url\":\"https://mit-license.org\"}},
                 \"paths\":{}}")
         (info (cl-openapi:openapi-info (cl-openapi:parse json))))
    (is (typep (cl-openapi:info-contact info) 'cl-openapi:contact))
    (is (string= "Alice"          (cl-openapi:contact-name  (cl-openapi:info-contact info))))
    (is (string= "a@example.com"  (cl-openapi:contact-email (cl-openapi:info-contact info))))
    (is (typep (cl-openapi:info-license info) 'cl-openapi:license))
    (is (string= "MIT" (cl-openapi:license-name (cl-openapi:info-license info))))))

;;; ── servers ─────────────────────────────────────────────────────────────────

(test parse-servers
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"servers\":[{\"url\":\"https://api.example.com\",
                               \"description\":\"Production\"}],
                 \"paths\":{}}")
         (doc     (cl-openapi:parse json))
         (servers (cl-openapi:openapi-servers doc)))
    (is (= 1 (length servers)))
    (let ((srv (aref servers 0)))
      (is (typep srv 'cl-openapi:server))
      (is (string= "https://api.example.com" (cl-openapi:server-url srv)))
      (is (string= "Production"              (cl-openapi:server-description srv))))))

;;; ── paths ───────────────────────────────────────────────────────────────────

(test parse-paths-empty
  (let* ((doc   (cl-openapi:parse (minimal-doc)))
         (paths (cl-openapi:openapi-paths doc)))
    (is (hash-table-p paths))
    (is (zerop (hash-table-count paths)))))

(test parse-path-item-get-operation
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{\"/pets\":{\"get\":{\"operationId\":\"listPets\",
                                               \"summary\":\"List all pets\",
                                               \"responses\":{\"200\":{\"description\":\"OK\"}}}}}}")
         (doc      (cl-openapi:parse json))
         (path     (gethash "/pets" (cl-openapi:openapi-paths doc)))
         (get-op   (cl-openapi:path-item-get path)))
    (is (typep path  'cl-openapi:path-item))
    (is (typep get-op 'cl-openapi:operation))
    (is (string= "listPets"      (cl-openapi:operation-id get-op)))
    (is (string= "List all pets" (cl-openapi:operation-summary get-op)))))

(test parse-operation-parameters
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{\"/pets/{id}\":{\"get\":{
                   \"operationId\":\"getPet\",
                   \"parameters\":[{\"name\":\"id\",\"in\":\"path\",\"required\":true,
                                    \"schema\":{\"type\":\"integer\"}}],
                   \"responses\":{\"200\":{\"description\":\"OK\"}}}}}}")
         (doc    (cl-openapi:parse json))
         (op     (cl-openapi:path-item-get
                  (gethash "/pets/{id}" (cl-openapi:openapi-paths doc))))
         (params (cl-openapi:operation-parameters op))
         (param  (aref params 0)))
    (is (= 1 (length params)))
    (is (typep param 'cl-openapi:parameter))
    (is (string= "id"   (cl-openapi:parameter-name param)))
    (is (string= "path" (cl-openapi:parameter-in   param)))
    (is (eq t           (cl-openapi:parameter-required param)))))

(test parse-operation-request-body
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{\"/pets\":{\"post\":{
                   \"operationId\":\"createPet\",
                   \"requestBody\":{\"required\":true,
                                    \"content\":{\"application/json\":{\"schema\":{\"type\":\"object\"}}}},
                   \"responses\":{\"201\":{\"description\":\"Created\"}}}}}}")
         (doc  (cl-openapi:parse json))
         (op   (cl-openapi:path-item-post
                (gethash "/pets" (cl-openapi:openapi-paths doc))))
         (rb   (cl-openapi:operation-request-body op)))
    (is (typep rb 'cl-openapi:request-body))
    (is (eq t (cl-openapi:request-body-required rb)))
    (is (hash-table-p (cl-openapi:request-body-content rb)))
    (let ((mt (gethash "application/json" (cl-openapi:request-body-content rb))))
      (is (typep mt 'cl-openapi:media-type))
      (let ((schema (cl-openapi:media-type-schema mt)))
        (is (typep schema 'cl-openapi:schema))
        (is (string= "object" (cl-openapi:schema-type schema)))))))

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
         (doc      (cl-openapi:parse json))
         (schemas  (cl-openapi:components-schemas
                    (cl-openapi:openapi-components doc)))
         (pet      (gethash "Pet" schemas)))
    (is (typep pet 'cl-openapi:schema))
    (is (string= "object" (cl-openapi:schema-type pet)))
    (is (hash-table-p (cl-openapi:schema-properties pet)))
    (let ((id-schema (gethash "id" (cl-openapi:schema-properties pet))))
      (is (typep id-schema 'cl-openapi:schema))
      (is (string= "integer" (cl-openapi:schema-type id-schema))))))

(test parse-schema-ref
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{},
                 \"components\":{\"schemas\":{
                   \"Pets\":{\"type\":\"array\",
                             \"items\":{\"$ref\":\"#/components/schemas/Pet\"}},
                   \"Pet\":{\"type\":\"object\"}}}}")
         (doc     (cl-openapi:parse json))
         (schemas (cl-openapi:components-schemas
                   (cl-openapi:openapi-components doc)))
         (pets    (gethash "Pets" schemas))
         (items   (cl-openapi:schema-items pets)))
    (is (typep pets  'cl-openapi:schema))
    (is (string= "array" (cl-openapi:schema-type pets)))
    (is (typep items 'cl-openapi:reference))
    (is (string= "#/components/schemas/Pet" (cl-openapi:reference-ref items)))))

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
         (doc      (cl-openapi:parse json))
         (schemas  (cl-openapi:components-schemas
                    (cl-openapi:openapi-components doc)))
         (combined (gethash "Combined" schemas))
         (all-of   (cl-openapi:schema-all-of combined)))
    (is (= 2 (length all-of)))
    (is (typep (aref all-of 0) 'cl-openapi:schema))
    (is (typep (aref all-of 1) 'cl-openapi:reference))))

;;; ── components ──────────────────────────────────────────────────────────────

(test parse-components-security-schemes
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{},
                 \"components\":{\"securitySchemes\":{
                   \"bearerAuth\":{\"type\":\"http\",\"scheme\":\"bearer\",
                                   \"bearerFormat\":\"JWT\"}}}}")
         (doc      (cl-openapi:parse json))
         (schemes  (cl-openapi:components-security-schemes
                    (cl-openapi:openapi-components doc)))
         (bearer   (gethash "bearerAuth" schemes)))
    (is (typep bearer 'cl-openapi:security-scheme))
    (is (string= "http"   (cl-openapi:security-scheme-type bearer)))
    (is (string= "bearer" (cl-openapi:security-scheme-scheme bearer)))
    (is (string= "JWT"    (cl-openapi:security-scheme-bearer-format bearer)))))

(test parse-tags
  (let* ((json "{\"openapi\":\"3.0.0\",
                 \"info\":{\"title\":\"A\",\"version\":\"0\"},
                 \"paths\":{},
                 \"tags\":[{\"name\":\"pets\",\"description\":\"Everything about pets\"}]}")
         (doc  (cl-openapi:parse json))
         (tags (cl-openapi:openapi-tags doc)))
    (is (= 1 (length tags)))
    (let ((tag (aref tags 0)))
      (is (typep tag 'cl-openapi:tag))
      (is (string= "pets" (cl-openapi:tag-name tag)))
      (is (string= "Everything about pets" (cl-openapi:tag-description tag))))))

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
         (doc      (cl-openapi:parse json))
         (op       (cl-openapi:path-item-get
                    (gethash "/items" (cl-openapi:openapi-paths doc))))
         (resp-200 (gethash "200" (cl-openapi:operation-responses op)))
         (resp-404 (gethash "404" (cl-openapi:operation-responses op))))
    (is (typep resp-200 'cl-openapi:response))
    (is (string= "OK" (cl-openapi:response-description resp-200)))
    (is (typep resp-404 'cl-openapi:response))
    (is (string= "Not Found" (cl-openapi:response-description resp-404)))))

