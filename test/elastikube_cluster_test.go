package test

import (
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func TestElastikubeCluster(t *testing.T) {

	t.Parallel()

	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/elastikube-cluster")

	// A unique ID we can use to namespace resources so we don't clash with anything already in the AWS account or
	// tests running in parallel
	// uniqueID := "rn2ws0"
	uniqueID := strings.ToLower(random.UniqueId())
	awsRegion := "us-west-2"

	// Preapre all terraform options
	terraformOptionsNetwork := configureTerraformOptions(t, exampleFolder, "module.network", uniqueID, awsRegion)
	terraformOptionsKubernetes := configureTerraformOptions(t, exampleFolder, "module.kubernetes", uniqueID, awsRegion)
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
		keyPairName := fmt.Sprintf("test-k8s-%s", uniqueID)
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
		kubeconfig := aws.GetS3ObjectContents(t, awsRegion, ignitionS3Bucket, "kubeconfig")
		kubeconfigPath, _ := createKubeconfig(t, exampleFolder, kubeconfig)
		kubeconfigContext := "default"
		kubectlOptions := k8s.NewKubectlOptions(kubeconfigContext, kubeconfigPath)
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

func configureTerraformOptions(t *testing.T, exampleFolder string, target string, uniqueID string, awsRegion string) (ret *terraform.Options) {

	phase := "test"
	project := fmt.Sprintf("k8s-%s", uniqueID)
	keyPairName := fmt.Sprintf("test-k8s-%s", uniqueID)

	ret = &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: exampleFolder,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"aws_region":             awsRegion,
			"phase":                  phase,
			"project":                project,
			"key_pair_name":          keyPairName,
			"endpoint_public_access": "true",
		},
	}

	if target != "" {
		ret.Targets = []string{target}
	}

	return
}

func createKubeconfig(t *testing.T, source string, kubeconfig string) (string, error) {
	kubeconfigPath := fmt.Sprintf("%s/.test-data/kubeconfig", source)

	f, err := os.Create(kubeconfigPath)
	if err != nil {
		return "", err
	}
	l, err := f.WriteString(kubeconfig)
	if err != nil {
		f.Close()
		return "", err
	}
	fmt.Println(l, "bytes written successfully")
	err = f.Close()
	if err != nil {
		return "", err
	}

	return kubeconfigPath, nil
}

func testBastionHost(t *testing.T, terraformOptions *terraform.Options, keyPair *aws.Ec2Keypair) {

	bastionPublicIP := terraform.Output(t, terraformOptions, "bastion_public_ip")

	// start the ssh agent
	sshAgent := ssh.SshAgentWithKeyPair(t, keyPair.KeyPair)
	defer sshAgent.Stop()

	// We're going to try to SSH to the instance IP, using the Key Pair we created earlier. Instead of
	// directly using the SSH key in the SSH connection, we're going to rely on an existing SSH agent that we
	// programatically emulate within this test. We're going to use the user "ubuntu" as we know the Instance
	// is running an Ubuntu AMI that has such a user
	bastionHost := &ssh.Host{
		Hostname:         bastionPublicIP,
		SshUserName:      "ubuntu",
		OverrideSshAgent: sshAgent,
	}

	// It can take a minute or so for the Instance to boot up, so retry a few times
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second
	description := fmt.Sprintf("SSH with Agent to bastion host %s", bastionPublicIP)

	// Run a simple echo command on the server
	expectedText := "Hello, World"
	command := fmt.Sprintf("echo -n '%s'", expectedText)

	// Verify that we can SSH to the Instance and run commands
	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {

		actualText, err := ssh.CheckSshCommandE(t, *bastionHost, command)

		if err != nil {
			return "", err
		}

		if strings.TrimSpace(actualText) != expectedText {
			return "", fmt.Errorf("Expected SSH command to return '%s' but got '%s'", expectedText, actualText)
		}

		return "", nil
	})
}

func testKubernetes(t *testing.T, kubectlOptions *k8s.KubectlOptions, exampleFolder string) {

	// It can take several minutes for the Kubernetes cluster to boot up, so retry a few times
	maxRetries := 30
	timeBetweenRetries := 30 * time.Second
	description := fmt.Sprint("Access Kubernetes cluster")

	// Verify that we can access Kubernetes cluster by kubectl
	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {

		nodesReady, err := k8s.AreAllNodesReadyE(t, kubectlOptions)

		if err != nil {
			return "", err
		}

		if !nodesReady {
			return "", fmt.Errorf("Cannot check all the Kubernetes nodes ready or not: %s", err)
		}
		return "", nil
	})

	// Path to the Kubernetes resource config we will test

	kubeResourcePath := fmt.Sprintf("%s/k8s/nginx.yml", exampleFolder)

	// To ensure we can reuse the resource config on the same cluster to test different scenarios, we setup a unique
	// namespace for the resources for this test.
	// Note that namespaces must be lowercase.
	namespaceName := strings.ToLower(random.UniqueId())
	testResourceName := "nginx"
	testServiceName := fmt.Sprintf("%s-service", testResourceName)
	testServiceLocal := random.Random(9000, 9999)
	testServiceRemote := 80

	k8s.CreateNamespace(t, kubectlOptions, namespaceName)
	// Make sure we set the namespace on the options
	kubectlOptions.Namespace = namespaceName
	// ... and make sure to delete the namespace at the end of the test
	defer k8s.DeleteNamespace(t, kubectlOptions, namespaceName)

	// This will run `kubectl apply -f RESOURCE_CONFIG` and fail the test if there are any errors
	k8s.KubectlApply(t, kubectlOptions, kubeResourcePath)

	// This will wait up to 10 seconds for the service to become available, to ensure that we can access it.
	k8s.WaitUntilServiceAvailable(t, kubectlOptions, testServiceName, 10, 1*time.Second)

	// Get pod and wait for it to be avaialable
	// To get the pod, we need to filter it using the labels that the helm chart creates
	filters := metav1.ListOptions{
		LabelSelector: fmt.Sprintf("app=%s", testResourceName),
	}
	k8s.WaitUntilNumPodsCreated(t, kubectlOptions, filters, 1, 30, 10*time.Second)
	pods := k8s.ListPods(t, kubectlOptions, filters)
	for _, pod := range pods {
		k8s.WaitUntilPodAvailable(t, kubectlOptions, pod.Name, 30, 10*time.Second)
	}

	// Now we verify that the service will successfully boot and start serving requests
	kubeTunnel := k8s.NewTunnel(kubectlOptions, k8s.ResourceTypeService, testServiceName, testServiceLocal, testServiceRemote)
	kubeTunnel.ForwardPort(t)
	defer kubeTunnel.Close()

	// Test the endpoint for up to 5 minutes. This will only fail if we timeout waiting for the service to return a 200
	// response.
	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		fmt.Sprintf("http://%s", kubeTunnel.Endpoint()),
		30,
		10*time.Second,
		func(statusCode int, body string) bool {
			return statusCode == 200
		},
	)
}
