//go:build ignore

package main

//go:generate oapi-codegen -package api -generate types,server,spec ../api/openapi.yaml