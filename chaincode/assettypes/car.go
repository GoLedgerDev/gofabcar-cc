package assettypes

import (
	"github.com/goledgerdev/cc-tools/assets"
)

var Car = assets.AssetType{
	Tag:         "car",
	Label:       "Car",
	Description: "Registry of a Car",

	Props: []assets.AssetProp{
		{
			// Primary key
			Required: true,
			IsKey:    true,
			Tag:      "make",
			Label:    "Make",
			DataType: "string",
		},
		{
			// Primary key
			Required: true,
			IsKey:    true,
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
}
