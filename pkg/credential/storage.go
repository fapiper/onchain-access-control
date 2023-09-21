package credential

import (
	"context"
	"fmt"
	"math/rand"
	"strings"

	"github.com/TBD54566975/ssi-sdk/credential"
	"github.com/TBD54566975/ssi-sdk/credential/integrity"
	statussdk "github.com/TBD54566975/ssi-sdk/credential/status"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/goccy/go-json"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
	"go.einride.tech/aip/filtering"

	"github.com/fapiper/onchain-access-control/pkg/common"
	credint "github.com/fapiper/onchain-access-control/pkg/internal/credential"
	"github.com/fapiper/onchain-access-control/pkg/internal/keyaccess"
	"github.com/fapiper/onchain-access-control/pkg/storage"
	"github.com/fapiper/onchain-access-control/pkg/util"
)

type StoreCredentialRequest struct {
	credint.Container
}

type StoredCredentials struct {
	StoredCredentials []StoredCredential
	NextPageToken     string
}

type StoredCredential struct {
	// This Key is generated by the storage module upon first write.
	Key string `json:"key"`

	// ID of the credential that identifies it within ssi service.
	LocalCredentialID string `json:"LocalCredentialId"`

	// only one of these fields should be present
	Credential    *credential.VerifiableCredential `json:"credential,omitempty"`
	CredentialJWT *keyaccess.JWT                   `json:"token,omitempty"`

	Issuer                             string `json:"issuer"`
	FullyQualifiedVerificationMethodID string `json:"fullyQualifiedVerificationMethodId"`
	Subject                            string `json:"subject"`
	Schema                             string `json:"schema"`
	IssuanceDate                       string `json:"issuanceDate"`
	Revoked                            bool   `json:"revoked"`
	Suspended                          bool   `json:"suspended"`
}

func (sc *StoredCredential) FilterVariablesMap() map[string]any {
	return map[string]any{
		"issuer":  sc.Issuer,
		"schema":  sc.Schema,
		"subject": sc.Subject,
	}
}

type WriteContext struct {
	namespace string
	key       string
	value     []byte
}

type StatusListCredentialMetadata struct {
	statusListCredentialWatchKey   storage.WatchKey
	statusListIndexPoolWatchKey    storage.WatchKey
	statusListCurrentIndexWatchKey storage.WatchKey
}

func (sc *StoredCredential) IsValid() bool {
	return sc.Key != "" && (sc.HasDataIntegrityCredential() || sc.HasJWTCredential())
}

func (sc *StoredCredential) HasDataIntegrityCredential() bool {
	return sc.Credential != nil && sc.Credential.Proof != nil
}

func (sc *StoredCredential) HasJWTCredential() bool {
	return sc.CredentialJWT != nil
}

func (sc *StoredCredential) HasCredentialStatus() bool {
	return sc != nil && sc.Credential != nil && sc.Credential.CredentialStatus != nil
}

func (sc *StoredCredential) GetStatusPurpose() string {
	return sc.Credential.CredentialStatus.(map[string]any)["statusPurpose"].(string)
}

const (
	credentialNamespace                    = "credential"
	statusListCredentialNamespace          = "status-list-credential"
	statusListCredentialIndexPoolNamespace = "status-list-index-pool"
	statusListCredentialCurrentIndex       = "status-list-current-index"

	// A a minimum revocation bitString length of 131,072, or 16KB uncompressed
	bitStringLength = 8 * 1024 * 16

	credentialNotFoundErrMsg = "credential not found"
)

type Storage struct {
	db storage.ServiceStorage
}

type StatusListIndex struct {
	Index int `json:"index"`
}

func NewCredentialStorage(db storage.ServiceStorage) (*Storage, error) {
	if db == nil {
		return nil, sdkutil.LoggingNewError("db reference is nil")
	}

	return &Storage{db: db}, nil
}

func (cs *Storage) GetNextStatusListRandomIndex(ctx context.Context, slcMetadata StatusListCredentialMetadata) (int, error) {
	gotUniqueNumBytes, err := cs.db.Read(ctx, slcMetadata.statusListIndexPoolWatchKey.Namespace, slcMetadata.statusListIndexPoolWatchKey.Key)
	if err != nil {
		return -1, sdkutil.LoggingErrorMsgf(err, "reading status list")
	}

	if len(gotUniqueNumBytes) == 0 {
		return -1, sdkutil.LoggingNewErrorf("could not get unique numbers from db")
	}

	var uniqueNums []int
	if err = json.Unmarshal(gotUniqueNumBytes, &uniqueNums); err != nil {
		return -1, sdkutil.LoggingErrorMsgf(err, "unmarshalling unique numbers")
	}

	gotCurrentListIndexBytes, err := cs.db.Read(ctx, slcMetadata.statusListCurrentIndexWatchKey.Namespace, slcMetadata.statusListCurrentIndexWatchKey.Key)
	if err != nil {
		return -1, sdkutil.LoggingErrorMsgf(err, "could not get list index")
	}

	var statusListIndex StatusListIndex
	if err = json.Unmarshal(gotCurrentListIndexBytes, &statusListIndex); err != nil {
		return -1, sdkutil.LoggingErrorMsgf(err, "unmarshalling unique numbers")
	}

	return uniqueNums[statusListIndex.Index], nil
}

func (cs *Storage) WriteMany(ctx context.Context, writeContexts []WriteContext) error {
	namespaces := make([]string, 0)
	keys := make([]string, 0)
	values := make([][]byte, 0)

	for i := range writeContexts {
		namespaces = append(namespaces, writeContexts[i].namespace)
		keys = append(keys, writeContexts[i].key)
		values = append(values, writeContexts[i].value)
	}

	return cs.db.WriteMany(ctx, namespaces, keys, values)
}

func (cs *Storage) IncrementStatusListIndexTx(ctx context.Context, tx storage.Tx, slcMetadata StatusListCredentialMetadata) error {
	gotCurrentListIndexBytes, err := cs.db.Read(ctx, slcMetadata.statusListCurrentIndexWatchKey.Namespace, slcMetadata.statusListCurrentIndexWatchKey.Key)
	if err != nil {
		return sdkutil.LoggingErrorMsg(err, "could not get list index")
	}

	var statusListIndex StatusListIndex
	if err = json.Unmarshal(gotCurrentListIndexBytes, &statusListIndex); err != nil {
		return sdkutil.LoggingErrorMsg(err, "unmarshalling unique numbers")
	}

	if statusListIndex.Index >= bitStringLength-1 {
		return sdkutil.LoggingErrorMsg(err, "no more indexes available for status list index")
	}

	statusListIndexBytes, err := json.Marshal(StatusListIndex{Index: statusListIndex.Index + 1})
	if err != nil {
		return sdkutil.LoggingErrorMsg(err, "could not marshal status list index bytes")
	}

	if err := tx.Write(ctx, slcMetadata.statusListCurrentIndexWatchKey.Namespace, slcMetadata.statusListCurrentIndexWatchKey.Key, statusListIndexBytes); err != nil {
		return sdkutil.LoggingErrorMsg(err, "problem writing current list index to db")
	}

	return nil
}

func (cs *Storage) StoreCredentialTx(ctx context.Context, tx storage.Tx, request StoreCredentialRequest) error {
	wc, err := cs.getStoreCredentialWriteContext(request, credentialNamespace)
	if err != nil {
		return errors.Wrap(err, "building stored credential")

	}
	return tx.Write(ctx, wc.namespace, wc.key, wc.value)
}

// CreateStatusListCredentialTx creates a new status list credential with the provided metadata and stores it in the database as a transaction.
// The function generates a unique random number and stores it along with the metadata in the database and then returns it
func (cs *Storage) CreateStatusListCredentialTx(ctx context.Context, tx storage.Tx, request StoreCredentialRequest, slcMetadata StatusListCredentialMetadata) (int, error) {

	randUniqueList := randomUniqueNum(bitStringLength)
	uniqueNumBytes, err := json.Marshal(randUniqueList)
	if err != nil {
		return -1, sdkutil.LoggingErrorMsg(err, "could not marshal random unique numbers")
	}

	if err := tx.Write(context.Background(), slcMetadata.statusListIndexPoolWatchKey.Namespace, slcMetadata.statusListIndexPoolWatchKey.Key, uniqueNumBytes); err != nil {
		return -1, sdkutil.LoggingErrorMsg(err, "problem writing status list indexes to db")
	}

	// Set the index to 1 since this is a new statusListCredential
	statusListIndexBytes, err := json.Marshal(StatusListIndex{Index: 1})
	if err != nil {
		return -1, sdkutil.LoggingErrorMsg(err, "could not marshal status list index bytes")
	}

	if err := tx.Write(context.Background(), slcMetadata.statusListCurrentIndexWatchKey.Namespace, slcMetadata.statusListCurrentIndexWatchKey.Key, statusListIndexBytes); err != nil {
		return -1, sdkutil.LoggingErrorMsg(err, "problem writing current list index to db")
	}

	return randUniqueList[0], cs.StoreStatusListCredentialTx(ctx, tx, request, slcMetadata)
}

func (cs *Storage) StoreStatusListCredentialTx(ctx context.Context, tx storage.Tx, request StoreCredentialRequest, slcMetadata StatusListCredentialMetadata) error {
	if !request.IsValid() {
		return sdkutil.LoggingNewError("store request request is not valid")
	}

	// transform the credential into its denormalized form for storage
	storedCredential, err := buildStoredCredential(request)
	if err != nil {
		return errors.Wrap(err, "building stored credential")
	}

	storedCredBytes, err := json.Marshal(storedCredential)
	if err != nil {
		return sdkutil.LoggingErrorMsgf(err, "could not store request: %s", storedCredential.LocalCredentialID)
	}

	return tx.Write(ctx, slcMetadata.statusListCredentialWatchKey.Namespace, slcMetadata.statusListCredentialWatchKey.Key, storedCredBytes)
}

func (cs *Storage) GetStatusListCredential(ctx context.Context, id string) (*StoredCredential, error) {
	keys, err := cs.db.ReadAllKeys(ctx, statusListCredentialNamespace)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsgf(err, "could not read credential storage while searching for cred with id: %s", id)
	}

	var storedCreds []StoredCredential
	for _, key := range keys {
		credBytes, err := cs.db.Read(ctx, statusListCredentialNamespace, key)
		if err != nil {
			logrus.WithError(err).Errorf("could not read credential with key: %s", key)
			continue
		}
		var cred StoredCredential
		if err = json.Unmarshal(credBytes, &cred); err != nil {
			logrus.WithError(err).Errorf("unmarshalling credential with key: %s", key)
		}
		if cred.LocalCredentialID == id {
			storedCreds = append(storedCreds, cred)
		}
	}

	if len(storedCreds) == 0 {
		logrus.Infof("no credentials able to be retrieved for id: %s", id)
		return nil, errors.Errorf("status list credential not found for id: %s", id)
	}

	if len(storedCreds) > 1 {
		logrus.Error("there should only be status list credential per <issuer,schema,statuspurpose> tripple, bad state")
	}

	return &storedCreds[0], nil
}

func (cs *Storage) getStoreCredentialWriteContext(request StoreCredentialRequest, namespace string) (*WriteContext, error) {
	if !request.IsValid() {
		return nil, sdkutil.LoggingNewError("store request request is not valid")
	}

	// transform the credential into its denormalized form for storage
	storedCredential, err := buildStoredCredential(request)
	if err != nil {
		return nil, errors.Wrap(err, "building stored credential")
	}

	storedCredBytes, err := json.Marshal(storedCredential)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsgf(err, "could not store request: %s", storedCredential.LocalCredentialID)
	}

	wc := WriteContext{
		namespace: namespace,
		key:       storedCredential.Key,
		value:     storedCredBytes,
	}

	return &wc, nil
}

// buildStoredCredential generically parses a store credential request and returns the object to be stored
func buildStoredCredential(request StoreCredentialRequest) (*StoredCredential, error) {
	// assume we have a Data Integrity credential
	cred := request.Credential
	if request.HasJWTCredential() {
		_, _, parsedCred, err := integrity.ParseVerifiableCredentialFromJWT(request.CredentialJWT.String())
		if err != nil {
			return nil, errors.Wrap(err, "could not parse credential from jwt")
		}

		// if we have a JWT credential, update the reference
		cred = parsedCred
	}

	credID := request.Container.ID
	// Note: we assume the issuer is always a string for now
	issuer := cred.Issuer.(string)
	subject := cred.CredentialSubject.GetID()

	// schema is not a required field, so we must do this check
	schema := ""
	if cred.CredentialSchema != nil {
		schema = cred.CredentialSchema.ID
	}
	return &StoredCredential{
		Key:                                createPrefixKey(credID, issuer, subject, schema),
		LocalCredentialID:                  credID,
		Credential:                         cred,
		CredentialJWT:                      request.CredentialJWT,
		Issuer:                             issuer,
		FullyQualifiedVerificationMethodID: request.FullyQualifiedVerificationMethodID,
		Subject:                            subject,
		Schema:                             schema,
		IssuanceDate:                       cred.IssuanceDate,
		Revoked:                            request.Revoked,
		Suspended:                          request.Suspended,
	}, nil
}

func (cs *Storage) GetCredential(ctx context.Context, id string) (*StoredCredential, error) {
	return cs.getCredential(ctx, id, credentialNamespace)
}

func (cs *Storage) getCredential(ctx context.Context, id string, namespace string) (*StoredCredential, error) {
	prefixValues, err := cs.db.ReadPrefix(ctx, namespace, id)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsgf(err, "could not get credential from storage: %s", id)
	}
	if len(prefixValues) > 1 {
		return nil, sdkutil.LoggingNewErrorf("could not get credential from storage; multiple prefix values matched credential id: %s", id)
	}

	// since we know the map now only has a single value, we break after the first element
	var credBytes []byte
	for _, v := range prefixValues {
		credBytes = v
		break
	}
	if len(credBytes) == 0 {
		return nil, sdkutil.LoggingNewErrorf("could not get credential from storage %s with id: %s", credentialNotFoundErrMsg, id)
	}

	var stored StoredCredential
	if err = json.Unmarshal(credBytes, &stored); err != nil {
		return nil, sdkutil.LoggingErrorMsgf(err, "unmarshalling stored credential: %s", id)
	}
	return &stored, nil
}

func (cs *Storage) ListCredentials(ctx context.Context, filter filtering.Filter, page *common.Page) (*StoredCredentials, error) {
	token, size := page.ToStorageArgs()
	creds, nextPageToken, err := cs.db.ReadPage(ctx, credentialNamespace, token, size)
	if err != nil {
		return nil, errors.Wrap(err, "reading all creds before filtering")
	}

	shouldInclude, err := storage.NewIncludeFunc(filter)
	if err != nil {
		return nil, err
	}

	storedCreds := make([]StoredCredential, 0, len(creds))
	for i, cred := range creds {
		var nextCred StoredCredential
		if err = json.Unmarshal(cred, &nextCred); err != nil {
			logrus.WithError(err).WithField("idx", i).Warnf("Skipping operation")
		}
		include, err := shouldInclude(&nextCred)
		// We explicitly ignore evaluation errors and simply include them in the result.
		if err != nil || include {
			storedCreds = append(storedCreds, nextCred)
		}
	}

	return &StoredCredentials{
		StoredCredentials: storedCreds,
		NextPageToken:     nextPageToken,
	}, nil
}

// GetCredentialsByIssuerAndSchema gets all credentials stored with a prefix key containing the issuer value
// The method is greedy, meaning if multiple values are found...and some fail during processing, we will
// return only the successful values and log an error for the failures.
func (cs *Storage) GetCredentialsByIssuerAndSchema(ctx context.Context, issuer string, schema string) ([]StoredCredential, error) {
	return cs.getCredentialsByIssuerAndSchema(ctx, issuer, schema, credentialNamespace)
}

func (cs *Storage) GetStatusListCredentialsByIssuerSchemaPurpose(ctx context.Context, issuer string, schema string, statusPurpose statussdk.StatusPurpose) ([]StoredCredential, error) {
	keys, err := cs.db.ReadAllKeys(ctx, statusListCredentialNamespace)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsgf(err, "could not read credential storage while searching for creds for issuer: %s", issuer)
	}

	query := storage.Join("sc", schema, "sp", string(statusPurpose))
	var issuerSchemaKeys []string
	for _, k := range keys {
		if strings.Contains(k, issuer) && strings.HasSuffix(k, query) {
			issuerSchemaKeys = append(issuerSchemaKeys, k)
		}
	}

	if len(issuerSchemaKeys) == 0 {
		logrus.Warnf("no status list credentials found for issuer: %s schema %s and status purpose %s", util.SanitizeLog(issuer), util.SanitizeLog(schema), util.SanitizeLog(string(statusPurpose)))
		return nil, nil
	}

	// now get each credential by key
	storedCreds := make([]StoredCredential, 0, len(issuerSchemaKeys))
	for _, key := range issuerSchemaKeys {
		credBytes, err := cs.db.Read(ctx, statusListCredentialNamespace, key)
		if err != nil {
			logrus.WithError(err).Errorf("could not read credential with key: %s", key)
			return nil, err
		}

		var cred StoredCredential
		if err = json.Unmarshal(credBytes, &cred); err != nil {
			logrus.WithError(err).Errorf("unmarshalling credential with key: %s", key)
		}

		storedCreds = append(storedCreds, cred)
	}

	if len(storedCreds) == 0 {
		logrus.Infof("no credentials able to be retrieved for issuer: %s", issuerSchemaKeys)
	}

	return storedCreds, nil
}

func (cs *Storage) getCredentialsByIssuerAndSchema(ctx context.Context, issuer string, schema string, namespace string) ([]StoredCredential, error) {
	keys, err := cs.db.ReadAllKeys(ctx, namespace)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsgf(err, "could not read credential storage while searching for creds for issuer: %s", issuer)
	}

	query := storage.Join("sc", schema)
	var issuerSchemaKeys []string
	for _, k := range keys {
		if strings.Contains(k, issuer) && strings.HasSuffix(k, query) {
			issuerSchemaKeys = append(issuerSchemaKeys, k)
		}
	}

	if len(issuerSchemaKeys) == 0 {
		logrus.Warnf("no credentials found for issuer: %s and schema %s", util.SanitizeLog(issuer), util.SanitizeLog(schema))
		return nil, nil
	}

	// now get each credential by key
	var storedCreds []StoredCredential
	for _, key := range issuerSchemaKeys {
		credBytes, err := cs.db.Read(ctx, namespace, key)
		if err != nil {
			logrus.WithError(err).Errorf("could not read credential with key: %s", key)
		} else {
			var cred StoredCredential
			if err = json.Unmarshal(credBytes, &cred); err != nil {
				logrus.WithError(err).Errorf("unmarshalling credential with key: %s", key)
			}
			storedCreds = append(storedCreds, cred)
		}
	}

	if len(storedCreds) == 0 {
		logrus.Infof("no credentials able to be retrieved for issuer: %s", issuerSchemaKeys)
	}

	return storedCreds, nil
}

func (cs *Storage) DeleteCredential(ctx context.Context, id string) error {
	return cs.deleteCredential(ctx, id, credentialNamespace)
}

func (cs *Storage) DeleteStatusListCredential(ctx context.Context, id string) error {
	return cs.deleteCredential(ctx, id, statusListCredentialNamespace)
}

func (cs *Storage) deleteCredential(ctx context.Context, id string, namespace string) error {
	credDoesNotExistMsg := fmt.Sprintf("credential does not exist, cannot delete: %s", id)

	// first get the credential to regenerate the prefix key
	gotCred, err := cs.GetCredential(ctx, id)
	if err != nil {
		// no error on deletion for a non-existent credential
		if strings.Contains(err.Error(), credentialNotFoundErrMsg) {
			logrus.Warn(credDoesNotExistMsg)
			return nil
		}

		return sdkutil.LoggingErrorMsgf(err, "could not get credential<%s> before deletion", id)
	}

	// no error on deletion for a non-existent credential
	if gotCred == nil {
		logrus.Warn(credDoesNotExistMsg)
		return nil
	}

	// re-create the prefix key to delete
	prefix := createPrefixKey(id, gotCred.Issuer, gotCred.Subject, gotCred.Schema)
	if err = cs.db.Delete(ctx, namespace, prefix); err != nil {
		return sdkutil.LoggingErrorMsgf(err, "could not delete credential: %s", id)
	}
	return nil
}

func (cs *Storage) GetStatusListCredentialWatchKey(issuer, schema, statusPurpose string) storage.WatchKey {
	return storage.WatchKey{Namespace: statusListCredentialNamespace, Key: getStatusListKey(issuer, schema, statusPurpose)}
}

func (cs *Storage) GetStatusListIndexPoolWatchKey(issuer, schema, statusPurpose string) storage.WatchKey {
	return storage.WatchKey{Namespace: statusListCredentialIndexPoolNamespace, Key: getStatusListKey(issuer, schema, statusPurpose)}
}

func (cs *Storage) GetStatusListCurrentIndexWatchKey(issuer, schema, statusPurpose string) storage.WatchKey {
	return storage.WatchKey{Namespace: statusListCredentialCurrentIndex, Key: getStatusListKey(issuer, schema, statusPurpose)}
}

func (cs *Storage) GetStatusListCredentialKeyData(ctx context.Context, issuer string, schema string, statusPurpose statussdk.StatusPurpose) (*StoredCredential, error) {
	storedStatusListCreds, err := cs.GetStatusListCredentialsByIssuerSchemaPurpose(ctx, issuer, schema, statusPurpose)
	if err != nil {
		return nil, sdkutil.LoggingNewErrorf("getting status list credential for issuer: %s schema: %s", issuer, schema)
	}

	// This should never happen, there should always be only 1 status list credential per <issuer,schema, statusPurpose> triplet
	if len(storedStatusListCreds) > 1 {
		return nil, sdkutil.LoggingNewErrorf("only one status list credential per <issuer,schema> pair allowed. issuer: %s schema: %s", issuer, schema)
	}

	// No Status List Credential Exists, create a new uuid
	if storedStatusListCreds == nil || len(storedStatusListCreds) == 0 {
		logrus.Warn("No Status List Credential Exists, create a new uuid")
		return nil, nil
	}

	return &storedStatusListCreds[0], nil
}

func getStatusListKey(issuer, schema, statusPurpose string) string {
	return storage.Join("is", issuer, "sc", schema, "sp", statusPurpose)
}

// unique key for a credential
func createPrefixKey(id, issuer, subject, schema string) string {
	return storage.Join(id, "is", issuer, "su", subject, "sc", schema)
}

func randomUniqueNum(count int) []int {
	randomNumbers := make([]int, 0, count)

	for i := 1; i <= count; i++ {
		randomNumbers = append(randomNumbers, i)
	}

	rand.Shuffle(len(randomNumbers), func(i, j int) {
		randomNumbers[i], randomNumbers[j] = randomNumbers[j], randomNumbers[i]
	})

	return randomNumbers
}
