package main

import (
	tx "github.com/goledgerdev/cc-tools/transactions"
	"github.com/goledgerdev/gofabcar-cc/chaincode/txdefs"
)

var txList = []tx.Transaction{
	tx.CreateAsset,
	tx.UpdateAsset,
	tx.DeleteAsset,
	txdefs.CreateNewCar,
}
