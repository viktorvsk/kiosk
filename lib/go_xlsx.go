package main

import (
    "fmt"
    "github.com/tealeg/xlsx"
    "encoding/json"
    "os"
    "io/ioutil"
)

func parseXlsx(filePath string) []byte {
    xlFile, err := xlsx.OpenFile(filePath)
    var products [][]string

    if err != nil {
        fmt.Println("Error: " + err.Error())
    }
    for _, sheet := range xlFile.Sheets {
        for _, row := range sheet.Rows {
            var product []string
            for _, cell := range row.Cells {
                s, err := cell.String()
                if err != nil {
                    // fmt.Println("ERROR: " + err.Error())
                }
                product = append(product, s)
            }
            products = append(products, product)
        }
    }

    b, err := json.Marshal(products)
    if err != nil {
        fmt.Printf("Error: %s", err)
        // return;
    }

    return b
}

func main() {
    jsonBytes := parseXlsx(os.Args[1])
    resultFilePath := string(os.Args[1]) + ".go_result"

    err := ioutil.WriteFile(resultFilePath, jsonBytes, 0644)
    if err != nil {
        panic(err)
    }
}
