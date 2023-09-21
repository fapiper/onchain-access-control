package operation

import (
	"context"
	"testing"

	"github.com/goccy/go-json"
	"github.com/google/go-cmp/cmp"
	"github.com/google/go-cmp/cmp/cmpopts"
	"github.com/stretchr/testify/require"

	manifeststg "github.com/fapiper/onchain-access-control/pkg/manifest/storage"
	"github.com/fapiper/onchain-access-control/pkg/operation/credential"
	opstorage "github.com/fapiper/onchain-access-control/pkg/operation/storage"
	"github.com/fapiper/onchain-access-control/pkg/operation/storage/namespace"
	"github.com/fapiper/onchain-access-control/pkg/storage"
	"github.com/fapiper/onchain-access-control/pkg/testutil"
)

func TestStorage_CancelOperation(t *testing.T) {
	for _, test := range testutil.TestDatabases {
		t.Run(test.Name, func(t *testing.T) {
			s := test.ServiceStorage(t)
			data, err := json.Marshal(manifeststg.StoredApplication{})
			require.NoError(t, err)
			require.NoError(t, s.Write(context.Background(), credential.ApplicationNamespace, "hello", data))

			type fields struct {
				db storage.ServiceStorage
			}
			type args struct {
				id string
			}
			tests := []struct {
				name    string
				fields  fields
				args    args
				want    *opstorage.StoredOperation
				wantErr bool
				done    bool
			}{
				{
					name: "bad id returns error",
					fields: fields{
						db: s,
					},
					args: args{
						id: "hello",
					},
					wantErr: true,
				},
				{
					name: "operation for application can be cancelled",
					fields: fields{
						db: s,
					},
					args: args{
						id: "credentials/responses/hello",
					},
					want: &opstorage.StoredOperation{
						ID:   "credentials/responses/hello",
						Done: true,
					},
				},
				{
					name: "done operation returns error on cancellation",
					done: true,
					fields: fields{
						db: s,
					},
					args: args{
						id: "credentials/responses/hello",
					},
					wantErr: true,
				},
			}
			for _, tt := range tests {
				t.Run(tt.name, func(t *testing.T) {

					opData, err := json.Marshal(opstorage.StoredOperation{
						ID:   "credentials/responses/hello",
						Done: tt.done,
					})
					require.NoError(t, err)
					require.NoError(t, s.Write(context.Background(), namespace.FromParent("credentials/responses"), "credentials/responses/hello", opData))

					b := Storage{
						db: tt.fields.db,
					}
					got, err := b.CancelOperation(context.Background(), tt.args.id)
					if (err != nil) != tt.wantErr {
						t.Errorf("CancelOperation() error = %v, wantErr %v", err, tt.wantErr)
						return
					}
					if diff := cmp.Diff(got, tt.want, cmpopts.IgnoreFields(opstorage.StoredOperation{}, "Response")); diff != "" {
						t.Errorf("CancelOperation() -got, +want:\n%s", diff)
					}
				})
			}
		})
	}
}
