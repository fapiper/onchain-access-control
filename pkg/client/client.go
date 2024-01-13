package client

func Init() {
	// create DID
}

func CreateZkVP() (byte, error) {
	// get sd-jwt from authority
	sdjwt, err := getSDJWT()
	if err != nil {
		return 0, err
	}

	// get proof key and proof program
	artifacts, err := getProofArtifacts()
	if err != nil {
		return 0, err
	}

	// create zk proof with sd-jwt claims and proof key
	vp, err := createVP(sdjwt, artifacts)
	if err != nil {
		return 0, err
	}

	return vp, nil
}

func CreateSessionTokens() (byte, error) {
	// 1: create st
	// 2: sign st and create sts
	// 3: encode sts and create ste

	return 1, nil
}

func getSDJWT() (byte, error) {
	// get sd-jwt from authority

	// extract claim digest and signature from sd-jwt
	return 1, nil
}

func getProofArtifacts() (byte, error) {

	return 1, nil
}

func createVP(sdjwt byte, artefacts byte) (byte, error) {

	return 1, nil
}

func AddPolicy() {

}
