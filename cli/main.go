package main

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"flag"
	"fmt"
)

func main() {
	var architecture string
	var regions string
	var creationDate string
	var os string

	flag.StringVar(&creationDate, "creationDate", "", "AMI creation date in RFC3339 format (e.g., 2023-07-10T05:00:00Z)")
	flag.StringVar(&architecture, "architecture", "", "AMI architecture (e.g., x86_64, arm64)")
	flag.StringVar(&regions, "regions", "", "Comma separated list of AWS regions")
	flag.StringVar(&os, "os", "", "Operating System (e.g., Windows, Linux)")
	flag.Parse()

	regionList := splitRegions(regions)

	for _, region := range regionList {
		fmt.Printf("Region: %s\n", region)

		// Create AWS session
		sess, err := session.NewSession(&aws.Config{
			Region: aws.String(region),
		})

		if err != nil {
			fmt.Printf("Error creating AWS session for region %s: %v\n", region, err)
			continue
		}

		// Create an EC2 service client
		svc := ec2.New(sess)

		filters := []*ec2.Filter{
			{
				Name:   aws.String("state"),
				Values: []*string{aws.String("available")},
			},
		}

		if creationDate != "" {
			filters = append(filters, &ec2.Filter{
				Name:   aws.String("creation-date"),
				Values: []*string{aws.String(creationDate)},
			})
		}

		if architecture != "" {
			filters = append(filters, &ec2.Filter{
				Name:   aws.String("architecture"),
				Values: []*string{aws.String(architecture)},
			})
		}

		if os != "" {
			filters = append(filters, &ec2.Filter{
				Name:   aws.String("platform"),
				Values: []*string{aws.String(os)},
			})
		}

		// List AMIs with the specified filters
		result, err := svc.DescribeImages(&ec2.DescribeImagesInput{
			Filters: filters,
		})

		if err != nil {
			fmt.Printf("Error describing images in region %s: %v\n", region, err)
			continue
		}

		// Print the AMI IDs and names
		for _, image := range result.Images {
			fmt.Printf("AMI ID: %s\n", *image.ImageId)
			fmt.Printf("Name: %s\n", *image.Name)
			fmt.Println("------------------------------")
		}
	}
}

func splitRegions(regionString string) []string {
	// Split the comma-separated region list
	regions := make([]string, 0)
	regionSlice := []rune(regionString)
	start := 0

	for i, r := range regionSlice {
		if r == ',' {
			regions = append(regions, string(regionSlice[start:i]))
			start = i + 1
		}
	}

	// Add the last region (or the only region if there is no comma)
	regions = append(regions, string(regionSlice[start:]))

	return regions
}
