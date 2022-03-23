package txdefs

import (
	"encoding/json"

	"github.com/goledgerdev/cc-tools/assets"
	"github.com/goledgerdev/cc-tools/errors"
	sw "github.com/goledgerdev/cc-tools/stubwrapper"
	tx "github.com/goledgerdev/cc-tools/transactions"
)

// CreateNewCar creates a new car on channel
// POST Method
var CreateNewCar = tx.Transaction{
	Tag:         "createNewCar",
	Label:       "Create New Car",
	Description: "Create New Car",
	Method:      "POST",

	Args: []tx.Argument{
		{
			Required: true,
			Tag:      "make",
			Label:    "Make",
			DataType: "string",
		},
		{
			Required: true,
			Tag:      "model",
			Label:    "Model",
			DataType: "string",
		},
		{
			Required: true,
			Tag:      "colour",
			Label:    "Colour",
			DataType: "string",
		},
		{
			Tag:      "owner",
			Label:    "Owner",
			DataType: "->person",
		},
	},
	Routine: func(stub *sw.StubWrapper, req map[string]interface{}) ([]byte, errors.ICCError) {
		make, _ := req["make"].(string)
		model, _ := req["model"].(string)
		colour, _ := req["colour"].(string)
		owner, _ := req["owner"].(assets.Key)

		// TODO: Add verification if owner already has a car

		carMap := map[string]interface{}{
			"@assetType": "car",
			"make":       make,
			"model":      model,
			"colour":     colour,
			"owner":      owner,
		}

		carAsset, err := assets.NewAsset(carMap)
		if err != nil {
			return nil, errors.WrapError(err, "Failed to create a new asset")
		}

		// Save the new library on channel
		_, err = carAsset.PutNew(stub)
		if err != nil {
			return nil, errors.WrapError(err, "Error saving asset on blockchain")
		}

		// Marshal asset back to JSON format
		carJSON, nerr := json.Marshal(carAsset)
		if nerr != nil {
			return nil, errors.WrapError(nil, "failed to encode asset to JSON format")
		}

		return carJSON, nil
	},
}
