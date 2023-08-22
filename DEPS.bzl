"Bazel go dependencies"

load("@bazel_gazelle//:deps.bzl", "go_repository")

def go_dependencies():
    """
        The go dependencies in this macro are auto-updated by gazelle
        To update run, bazel run //:gazelle-update-repos
    """
    go_repository(
        name = "com_github_bits_and_blooms_bitset",
        importpath = "github.com/bits-and-blooms/bitset",
        sum = "h1:YjAGVd3XmtK9ktAbX8Zg2g2PwLIMjGREZJHlV4j7NEo=",
        version = "v1.7.0",
    )
    go_repository(
        name = "com_github_btcsuite_btcd_btcec_v2",
        importpath = "github.com/btcsuite/btcd/btcec/v2",
        sum = "h1:5n0X6hX0Zk+6omWcihdYvdAlGf2DfasC0GMf7DClJ3U=",
        version = "v2.3.2",
    )
    go_repository(
        name = "com_github_btcsuite_btcd_chaincfg_chainhash",
        importpath = "github.com/btcsuite/btcd/chaincfg/chainhash",
        sum = "h1:KdUfX2zKommPRa+PD0sWZUyXe9w277ABlgELO7H04IM=",
        version = "v1.0.2",
    )
    go_repository(
        name = "com_github_cloudflare_circl",
        importpath = "github.com/cloudflare/circl",
        sum = "h1:fE/Qz0QdIGqeWfnwq0RE0R7MI51s0M2E4Ga9kq5AEMs=",
        version = "v1.3.3",
    )
    go_repository(
        name = "com_github_davecgh_go_spew",
        importpath = "github.com/davecgh/go-spew",
        sum = "h1:vj9j/u1bqnvCEfJOwUhtlOARqs3+rkHYY13jYWTU97c=",
        version = "v1.1.1",
    )
    go_repository(
        name = "com_github_decred_dcrd_dcrec_secp256k1_v4",
        importpath = "github.com/decred/dcrd/dcrec/secp256k1/v4",
        sum = "h1:8UrgZ3GkP4i/CLijOJx79Yu+etlyjdBU4sfcs2WYQMs=",
        version = "v4.2.0",
    )

    go_repository(
        name = "com_github_gin_contrib_sse",
        importpath = "github.com/gin-contrib/sse",
        sum = "h1:Y/yl/+YNO8GZSjAhjMsSuLt29uWRFHdHYUb5lYOV9qE=",
        version = "v0.1.0",
    )

    go_repository(
        name = "com_github_gin_gonic_gin",
        importpath = "github.com/gin-gonic/gin",
        sum = "h1:3DoBmSbJbZAWqXJC3SLjAPfutPJJRN1U5pALB7EeTTs=",
        version = "v1.7.7",
    )
    go_repository(
        name = "com_github_go_playground_assert_v2",
        importpath = "github.com/go-playground/assert/v2",
        sum = "h1:JvknZsQTYeFEAhQwI4qEt9cyV5ONwRHC+lYKSsYSR8s=",
        version = "v2.2.0",
    )

    go_repository(
        name = "com_github_go_playground_locales",
        importpath = "github.com/go-playground/locales",
        sum = "h1:EWaQ/wswjilfKLTECiXz7Rh+3BjFhfDFKv/oXslEjJA=",
        version = "v0.14.1",
    )

    go_repository(
        name = "com_github_go_playground_universal_translator",
        importpath = "github.com/go-playground/universal-translator",
        sum = "h1:Bcnm0ZwsGyWbCzImXv+pAJnYK9S473LQFuzCbDbfSFY=",
        version = "v0.18.1",
    )

    go_repository(
        name = "com_github_go_playground_validator_v10",
        importpath = "github.com/go-playground/validator/v10",
        sum = "h1:cFRQdfaSMCOSfGCCLB20MHvuoHb/s5G8L5pu2ppK5AQ=",
        version = "v10.13.0",
    )
    go_repository(
        name = "com_github_goccy_go_json",
        importpath = "github.com/goccy/go-json",
        sum = "h1:CrxCmQqYDkv1z7lO7Wbh2HN93uovUHgrECaO5ZrCXAU=",
        version = "v0.10.2",
    )

    go_repository(
        name = "com_github_golang_protobuf",
        importpath = "github.com/golang/protobuf",
        sum = "h1:ROPKBNFfQgOUMifHyP+KYbvpjbdoFNs+aK7DXlji0Tw=",
        version = "v1.5.2",
    )
    go_repository(
        name = "com_github_google_go_cmp",
        importpath = "github.com/google/go-cmp",
        sum = "h1:Khx7svrCpmxxtHBq5j2mp/xVjsi8hQMfNLvJFAlrGgU=",
        version = "v0.5.5",
    )
    go_repository(
        name = "com_github_google_gofuzz",
        importpath = "github.com/google/gofuzz",
        sum = "h1:A8PeW59pxE9IoFRqBp37U+mSNaQoZ46F1f0f863XSXw=",
        version = "v1.0.0",
    )
    go_repository(
        name = "com_github_google_uuid",
        importpath = "github.com/google/uuid",
        sum = "h1:t6JiXgmwXMjEs8VusXIJk2BXHsn+wx8BZdTaoZ5fu7I=",
        version = "v1.3.0",
    )
    go_repository(
        name = "com_github_gowebpki_jcs",
        importpath = "github.com/gowebpki/jcs",
        sum = "h1:0pZtOgGetfH/L7yXb4KWcJqIyZNA43WXFyMd7ftZACw=",
        version = "v1.0.0",
    )
    go_repository(
        name = "com_github_h2non_parth",
        importpath = "github.com/h2non/parth",
        sum = "h1:2VTzZjLZBgl62/EtslCrtky5vbi9dd7HrQPQIx6wqiw=",
        version = "v0.0.0-20190131123155-b4df798d6542",
    )
    go_repository(
        name = "com_github_hyperledger_aries_framework_go",
        importpath = "github.com/hyperledger/aries-framework-go",
        sum = "h1:44hOqFdVtXPRmfxK1dHds1g1mouJFNeP1D/PBjDxRv8=",
        version = "v0.3.1",
    )
    go_repository(
        name = "com_github_hyperledger_aries_framework_go_component_kmscrypto",
        importpath = "github.com/hyperledger/aries-framework-go/component/kmscrypto",
        sum = "h1:PCbDSujjQ6oTEnAHgtThNmbS7SPAYEDBlKOnZFE+Ujw=",
        version = "v0.0.0-20230427134832-0c9969493bd3",
    )
    go_repository(
        name = "com_github_hyperledger_aries_framework_go_component_log",
        importpath = "github.com/hyperledger/aries-framework-go/component/log",
        sum = "h1:x5qFQraTX86z9GCwF28IxfnPm6QH5YgHaX+4x97Jwvw=",
        version = "v0.0.0-20230427134832-0c9969493bd3",
    )
    go_repository(
        name = "com_github_hyperledger_aries_framework_go_component_models",
        importpath = "github.com/hyperledger/aries-framework-go/component/models",
        sum = "h1:oPGUCpmnm7yxsVllcMQnHF3uc3hy4jfrSCh7nvzXA00=",
        version = "v0.0.0-20230501135648-a9a7ad029347",
    )
    go_repository(
        name = "com_github_hyperledger_aries_framework_go_spi",
        importpath = "github.com/hyperledger/aries-framework-go/spi",
        sum = "h1:ytWmOQZIYQfVJ4msFvrqlp6d+ZLhT43wS8rgE2m+J1A=",
        version = "v0.0.0-20230427134832-0c9969493bd3",
    )
    go_repository(
        name = "com_github_jarcoal_httpmock",
        importpath = "github.com/jarcoal/httpmock",
        sum = "h1:2RJ8GP0IIaWwcC9Fp2BmVi8Kog3v2Hn7VXM3fTd+nuc=",
        version = "v1.3.0",
    )

    go_repository(
        name = "com_github_json_iterator_go",
        importpath = "github.com/json-iterator/go",
        sum = "h1:PV8peI4a0ysnczrg+LtxykD8LfKY9ML6u2jnxaEnrnM=",
        version = "v1.1.12",
    )
    go_repository(
        name = "com_github_kilic_bls12_381",
        importpath = "github.com/kilic/bls12-381",
        sum = "h1:kMJlf8z8wUcpyI+FQJIdGjAhfTww1y0AbQEv86bpVQI=",
        version = "v0.1.1-0.20210503002446-7b7597926c69",
    )
    go_repository(
        name = "com_github_klauspost_cpuid_v2",
        importpath = "github.com/klauspost/cpuid/v2",
        sum = "h1:lgaqFMSdTdQYdZ04uHyN2d/eKdOMyi2YLSvlQIBFYa4=",
        version = "v2.0.9",
    )

    go_repository(
        name = "com_github_leodido_go_urn",
        importpath = "github.com/leodido/go-urn",
        sum = "h1:6BE2vPT0lqoz3fmOesHZiaiFh7889ssCo2GMvLCfiuA=",
        version = "v1.2.3",
    )
    go_repository(
        name = "com_github_lestrrat_go_blackmagic",
        importpath = "github.com/lestrrat-go/blackmagic",
        sum = "h1:lS5Zts+5HIC/8og6cGHb0uCcNCa3OUt1ygh3Qz2Fe80=",
        version = "v1.0.1",
    )
    go_repository(
        name = "com_github_lestrrat_go_httpcc",
        importpath = "github.com/lestrrat-go/httpcc",
        sum = "h1:ydWCStUeJLkpYyjLDHihupbn2tYmZ7m22BGkcvZZrIE=",
        version = "v1.0.1",
    )
    go_repository(
        name = "com_github_lestrrat_go_httprc",
        importpath = "github.com/lestrrat-go/httprc",
        sum = "h1:bAZymwoZQb+Oq8MEbyipag7iSq6YIga8Wj6GOiJGdI8=",
        version = "v1.0.4",
    )
    go_repository(
        name = "com_github_lestrrat_go_iter",
        importpath = "github.com/lestrrat-go/iter",
        sum = "h1:gMXo1q4c2pHmC3dn8LzRhJfP1ceCbgSiT9lUydIzltI=",
        version = "v1.0.2",
    )
    go_repository(
        name = "com_github_lestrrat_go_jwx_v2",
        importpath = "github.com/lestrrat-go/jwx/v2",
        sum = "h1:jzU4xunmLFc7uF97O5PhEFmAuiRSuG7/RKrX2gkKWeY=",
        version = "v2.0.9-0.20230429214153-5090ec1bd2cd",
    )
    go_repository(
        name = "com_github_lestrrat_go_option",
        importpath = "github.com/lestrrat-go/option",
        sum = "h1:oAzP2fvZGQKWkvHa1/SAcFolBEca1oN+mQ7eooNBEYU=",
        version = "v1.0.1",
    )
    go_repository(
        name = "com_github_magefile_mage",
        importpath = "github.com/magefile/mage",
        sum = "h1:6QDX3g6z1YvJ4olPhT1wksUcSa/V0a1B+pJb73fBjyo=",
        version = "v1.14.0",
    )

    go_repository(
        name = "com_github_mattn_go_isatty",
        importpath = "github.com/mattn/go-isatty",
        sum = "h1:yVuAays6BHfxijgZPzw+3Zlu5yQgKGP2/hcQbHb7S9Y=",
        version = "v0.0.14",
    )
    go_repository(
        name = "com_github_minio_sha256_simd",
        importpath = "github.com/minio/sha256-simd",
        sum = "h1:v1ta+49hkWZyvaKwrQB8elexRqm6Y0aMLjCNsrYxo6g=",
        version = "v1.0.0",
    )

    go_repository(
        name = "com_github_modern_go_concurrent",
        importpath = "github.com/modern-go/concurrent",
        sum = "h1:TRLaZ9cD/w8PVh93nsPXa1VrQ6jlwL5oN8l14QlcNfg=",
        version = "v0.0.0-20180306012644-bacd9c7ef1dd",
    )

    go_repository(
        name = "com_github_modern_go_reflect2",
        importpath = "github.com/modern-go/reflect2",
        sum = "h1:xBagoLtFs94CBntxluKeaWgTMpvLxC4ur3nMaC9Gz0M=",
        version = "v1.0.2",
    )
    go_repository(
        name = "com_github_mr_tron_base58",
        importpath = "github.com/mr-tron/base58",
        sum = "h1:T/HDJBh4ZCPbU39/+c3rRvE0uKBQlU27+QI8LJ4t64o=",
        version = "v1.2.0",
    )
    go_repository(
        name = "com_github_multiformats_go_base32",
        importpath = "github.com/multiformats/go-base32",
        sum = "h1:pVx9xoSPqEIQG8o+UbAe7DNi51oej1NtK+aGkbLYxPE=",
        version = "v0.1.0",
    )
    go_repository(
        name = "com_github_multiformats_go_base36",
        importpath = "github.com/multiformats/go-base36",
        sum = "h1:JR6TyF7JjGd3m6FbLU2cOxhC0Li8z8dLNGQ89tUg4F4=",
        version = "v0.1.0",
    )
    go_repository(
        name = "com_github_multiformats_go_multibase",
        importpath = "github.com/multiformats/go-multibase",
        sum = "h1:isdYCVLvksgWlMW9OZRYJEa9pZETFivncJHmHnnd87g=",
        version = "v0.2.0",
    )
    go_repository(
        name = "com_github_multiformats_go_multicodec",
        importpath = "github.com/multiformats/go-multicodec",
        sum = "h1:pb/dlPnzee/Sxv/j4PmkDRxCOi3hXTz3IbPKOXWJkmg=",
        version = "v0.9.0",
    )
    go_repository(
        name = "com_github_multiformats_go_multihash",
        importpath = "github.com/multiformats/go-multihash",
        sum = "h1:aem8ZT0VA2nCHHk7bPJ1BjUbHNciqZC/d16Vve9l108=",
        version = "v0.2.1",
    )
    go_repository(
        name = "com_github_multiformats_go_varint",
        importpath = "github.com/multiformats/go-varint",
        sum = "h1:sWSGR+f/eu5ABZA2ZpYKBILXTTs9JWpdEM/nEGOHFS8=",
        version = "v0.0.7",
    )
    go_repository(
        name = "com_github_oliveagle_jsonpath",
        importpath = "github.com/oliveagle/jsonpath",
        sum = "h1:Yl0tPBa8QPjGmesFh1D0rDy+q1Twx6FyU7VWHi8wZbI=",
        version = "v0.0.0-20180606110733-2e52cf6e6852",
    )
    go_repository(
        name = "com_github_piprate_json_gold",
        importpath = "github.com/piprate/json-gold",
        sum = "h1:RmGh1PYboCFcchVFuh2pbSWAZy4XJaqTMU4KQYsApbM=",
        version = "v0.5.0",
    )
    go_repository(
        name = "com_github_pkg_errors",
        importpath = "github.com/pkg/errors",
        sum = "h1:FEBLx1zS214owpjy7qsBeixbURkuhQAwrK5UwLGTwt4=",
        version = "v0.9.1",
    )
    go_repository(
        name = "com_github_pmezard_go_difflib",
        importpath = "github.com/pmezard/go-difflib",
        sum = "h1:4DBwDE0NGyQoBHbLQYPwSUPoCMWR5BEzIk/f1lZbAQM=",
        version = "v1.0.0",
    )
    go_repository(
        name = "com_github_pquerna_cachecontrol",
        importpath = "github.com/pquerna/cachecontrol",
        sum = "h1:yJMy84ti9h/+OEWa752kBTKv4XC30OtVVHYv/8cTqKc=",
        version = "v0.1.0",
    )
    go_repository(
        name = "com_github_santhosh_tekuri_jsonschema_v5",
        importpath = "github.com/santhosh-tekuri/jsonschema/v5",
        sum = "h1:uIkTLo0AGRc8l7h5l9r+GcYi9qfVPt6lD4/bhmzfiKo=",
        version = "v5.3.0",
    )
    go_repository(
        name = "com_github_sirupsen_logrus",
        importpath = "github.com/sirupsen/logrus",
        sum = "h1:trlNQbNUG3OdDrDil03MCb1H2o9nJ1x4/5LYw7byDE0=",
        version = "v1.9.0",
    )
    go_repository(
        name = "com_github_spaolacci_murmur3",
        importpath = "github.com/spaolacci/murmur3",
        sum = "h1:7c1g84S4BPRrfL5Xrdp6fOJ206sU9y293DDHaoy0bLI=",
        version = "v1.1.0",
    )
    go_repository(
        name = "com_github_stretchr_objx",
        importpath = "github.com/stretchr/objx",
        sum = "h1:1zr/of2m5FGMsad5YfcqgdqdWrIhu+EBEJRhR1U7z/c=",
        version = "v0.5.0",
    )
    go_repository(
        name = "com_github_stretchr_testify",
        importpath = "github.com/stretchr/testify",
        sum = "h1:+h33VjcLVPDHtOdpUCuF+7gSuG3yGIftsP1YvFihtJ8=",
        version = "v1.8.2",
    )
    go_repository(
        name = "com_github_tbd54566975_ssi_sdk",
        importpath = "github.com/TBD54566975/ssi-sdk",
        sum = "h1:GbZG0S3xeaWQi2suWw2VjGRhM/S2RrIsfiubxSHlViE=",
        version = "v0.0.4-alpha",
    )

    go_repository(
        name = "com_github_ugorji_go",
        importpath = "github.com/ugorji/go",
        sum = "h1:qYhyWUUd6WbiM+C6JZAUkIJt/1WrjzNHY9+KCIjVqTo=",
        version = "v1.2.7",
    )

    go_repository(
        name = "com_github_ugorji_go_codec",
        importpath = "github.com/ugorji/go/codec",
        sum = "h1:YPXUKf7fYbp/y8xloBqZOw2qaVggbfwMlI8WM3wZUJ0=",
        version = "v1.2.7",
    )
    go_repository(
        name = "com_lukechampine_blake3",
        importpath = "lukechampine.com/blake3",
        sum = "h1:H3cROdztr7RCfoaTpGZFQsrqvweFLrqS73j7L7cmR5c=",
        version = "v1.1.6",
    )
    go_repository(
        name = "in_gopkg_check_v1",
        importpath = "gopkg.in/check.v1",
        sum = "h1:yhCVgyC4o1eVCa2tZl7eS0r+SDo693bJlVdllGtEeKM=",
        version = "v0.0.0-20161208181325-20d25e280405",
    )
    go_repository(
        name = "in_gopkg_h2non_gock_v1",
        importpath = "gopkg.in/h2non/gock.v1",
        sum = "h1:jBbHXgGBK/AoPVfJh5x4r/WxIrElvbLel8TCZkkZJoY=",
        version = "v1.1.2",
    )

    go_repository(
        name = "in_gopkg_yaml_v2",
        importpath = "gopkg.in/yaml.v2",
        sum = "h1:D8xgwECY7CYvx+Y2n4sBz93Jn9JRvxdiyyo8CTfuKaY=",
        version = "v2.4.0",
    )
    go_repository(
        name = "in_gopkg_yaml_v3",
        importpath = "gopkg.in/yaml.v3",
        sum = "h1:fxVm/GzAzEWqLHuvctI91KS9hhNmmWOoWu0XTYJS7CA=",
        version = "v3.0.1",
    )

    go_repository(
        name = "org_golang_google_protobuf",
        importpath = "google.golang.org/protobuf",
        sum = "h1:w43yiav+6bVFTBQFZX0r7ipe9JQ1QsbMgHwbBziscLw=",
        version = "v1.28.0",
    )

    go_repository(
        name = "org_golang_x_crypto",
        importpath = "golang.org/x/crypto",
        sum = "h1:pd9TJtTueMTVQXzk8E2XESSMQDj/U7OUu0PqJqPXQjQ=",
        version = "v0.8.0",
    )
    go_repository(
        name = "org_golang_x_mod",
        importpath = "golang.org/x/mod",
        sum = "h1:LUYupSeNrTNCGzR/hVBk2NHZO4hXcVaW1k4Qx7rjPx8=",
        version = "v0.8.0",
    )
    go_repository(
        name = "org_golang_x_net",
        importpath = "golang.org/x/net",
        sum = "h1:aWJ/m6xSmxWBx+V0XRHTlrYrPG56jKsLdTFmsSsCzOM=",
        version = "v0.9.0",
    )

    go_repository(
        name = "org_golang_x_sys",
        importpath = "golang.org/x/sys",
        sum = "h1:EBmGv8NaZBZTWvrbjNoL6HVt+IVy3QDQpJs7VRIw3tU=",
        version = "v0.8.0",
    )
    go_repository(
        name = "org_golang_x_term",
        importpath = "golang.org/x/term",
        sum = "h1:n5xxQn2i3PC0yLAbjTpNT85q/Kgzcr2gIoX9OrJUols=",
        version = "v0.8.0",
    )

    go_repository(
        name = "org_golang_x_text",
        importpath = "golang.org/x/text",
        sum = "h1:2sjJmO8cDvYveuX97RDLsxlyUxLl+GHoLxBiRdHllBE=",
        version = "v0.9.0",
    )
    go_repository(
        name = "org_golang_x_tools",
        importpath = "golang.org/x/tools",
        sum = "h1:BOw41kyTf3PuCW1pVQf8+Cyg8pMlkYB1oo9iJ6D/lKM=",
        version = "v0.6.0",
    )
    go_repository(
        name = "org_golang_x_xerrors",
        importpath = "golang.org/x/xerrors",
        sum = "h1:E7g+9GITq07hpfrRu66IVDexMakfv52eLZ2CXBWiKr4=",
        version = "v0.0.0-20191204190536-9bdfabe68543",
    )
