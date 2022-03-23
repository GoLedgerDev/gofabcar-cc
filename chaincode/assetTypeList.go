package main

import (
	"github.com/goledgerdev/cc-tools/assets"
	"github.com/goledgerdev/gofabcar-cc/chaincode/assettypes"
)

var assetTypeList = []assets.AssetType{
	assettypes.Person,
	assettypes.Book,
	assettypes.Library,
	assettypes.Secret,
}
