package main

import (
	"fmt"
	"log"
)

func tryout() []error {
	var err error

	// Get Header
	fmt.Print("Get Header... ")
	err = GetAndVerify(
		"http://localhost:80/api/query/getHeader",
		200,
		map[string]interface{}{
			"ccToolsVersion": "v0.7.2",
			"colors": []interface{}{
				"#4267B2",
				"#34495E",
				"#ECF0F1",
			},
			"name":     "CC Tools Demo",
			"orgMSP":   "org1MSP",
			"orgTitle": "CC Tools Demo",
			"version":  "1.0.0",
		},
	)
	if err != nil {
		fail()
		log.Fatalln(err)
	}
	pass()

	return nil
}
