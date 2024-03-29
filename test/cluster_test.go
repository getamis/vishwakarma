package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestKubernetesCluster(t *testing.T) {
	t.Parallel()

	// Copy example to temp folder
	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../", os.Getenv("TF_FOLDER_PATH"))

	// A unique ID we can use to namespace resources so we don't clash with anything already in the AWS account or
	// tests running in parallel
	// uniqueID := "rn2ws0"
	uniqueID := strings.ToLower(random.UniqueId())
	awsRegion := "us-west-2"

	// Preapre all terraform options
	terraformOptionsNetwork := configureTerraformOptions(t, exampleFolder, "module.network", uniqueID, awsRegion)
	terraformOptionsKubernetes := configureTerraformOptions(t, exampleFolder, "module.master", uniqueID, awsRegion)
	terraformOptionsWorkerSpot := configureTerraformOptions(t, exampleFolder, "module.worker_spot", uniqueID, awsRegion)
	terraformOptionsWorkerOnDemand := configureTerraformOptions(t, exampleFolder, "module.worker_on_demand", uniqueID, awsRegion)
	terraformOptionsAll := configureTerraformOptions(t, exampleFolder, "", uniqueID, awsRegion)
	test_structure.SaveTerraformOptions(t, exampleFolder, terraformOptionsAll)

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer test_structure.RunTestStage(t, "teardown", func() {
		terraform.Destroy(t, terraformOptionsWorkerOnDemand)
		terraform.Destroy(t, terraformOptionsWorkerSpot)
		terraform.Destroy(t, terraformOptionsKubernetes)
		terraform.Destroy(t, terraformOptionsNetwork)

		keyPair := test_structure.LoadEc2KeyPair(t, exampleFolder)
		aws.DeleteEC2KeyPair(t, keyPair)
		testData := fmt.Sprintf("%s/.test-data", exampleFolder)
		os.Remove(testData)
	})

	// Deploy the example
	test_structure.RunTestStage(t, "setup", func() {

		// Create an EC2 KeyPair that we can use for SSH access
		//keyPair := test_structure.LoadEc2KeyPair(t, exampleFolder)
		keyPairName := fmt.Sprintf("test-%s-k8s", uniqueID)
		keyPair := aws.CreateAndImportEC2KeyPair(t, awsRegion, keyPairName)
		test_structure.SaveEc2KeyPair(t, exampleFolder, keyPair)

		// Create network module first
		terraform.InitAndApply(t, terraformOptionsNetwork)

		// Create kubernetes master compoment
		terraform.InitAndApply(t, terraformOptionsKubernetes)

		// Create kubernetes worker (both on_demand and spot)
		terraform.InitAndApply(t, terraformOptionsAll)

		// Prepare kubectl options
		ignitionS3Bucket := terraform.Output(t, terraformOptionsAll, "ignition_s3_bucket")
		kubeconfigContext := "kubernetes-admin@kubernetes"
		kubectlOptions := configureKubectlOptions(t, exampleFolder, ignitionS3Bucket, awsRegion, kubeconfigContext)
		test_structure.SaveKubectlOptions(t, exampleFolder, kubectlOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		keyPair := test_structure.LoadEc2KeyPair(t, exampleFolder)
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleFolder)
		kubectlOptions := test_structure.LoadKubectlOptions(t, exampleFolder)

		testBastionHost(t, terraformOptions, keyPair)
		testKubernetes(t, kubectlOptions, exampleFolder)
	})
}
