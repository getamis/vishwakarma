package test

import (
	"crypto/tls"
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
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

const (
	// MaxRetries is the max retry time for testing
	MaxRetries = 30
	// TimeBetweenRetries is the time interval between retry
	TimeBetweenRetries = 10 * time.Second
)

const nginxYAML = `
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.15.7
        ports:
        - containerPort: 80
---
kind: Service
apiVersion: v1
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    targetPort: 80
    port: 80
  type: ClusterIP
`

func configureTerraformOptions(t *testing.T, exampleFolder string, target string, uniqueID string, awsRegion string) *terraform.Options {
	environment := "test"
	project := uniqueID
	keyPairName := fmt.Sprintf("test-%s-k8s", uniqueID)

	ret := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: exampleFolder,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"aws_region":             awsRegion,
			"environment":            environment,
			"project":                project,
			"key_pair_name":          keyPairName,
			"endpoint_public_access": "true",
		},
	}

	if target != "" {
		ret.Targets = []string{target}
	}
	return ret
}

func configureKubectlOptions(t *testing.T, exampleFolder string, ignitionS3Bucket string, awsRegion string, kubeconfigContext string) *k8s.KubectlOptions {
	kubeconfig := aws.GetS3ObjectContents(t, awsRegion, ignitionS3Bucket, "admin.conf")
	kubeconfigPath, _ := createKubeconfig(t, exampleFolder, kubeconfig)
	return k8s.NewKubectlOptions(kubeconfigContext, kubeconfigPath, "")
}

func createKubeconfig(t *testing.T, source string, kubeconfig string) (string, error) {
	kubeconfigPath := fmt.Sprintf("%s/.test-data/kubeconfig", source)

	f, err := os.Create(kubeconfigPath)
	if err != nil {
		return "", err
	}
	l, err := f.WriteString(kubeconfig)
	if err != nil {
		defer f.Close()
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
	description := fmt.Sprintf("SSH with Agent to bastion host %s", bastionPublicIP)

	// Run a simple echo command on the server
	expectedText := "Hello, World"
	command := fmt.Sprintf("echo -n '%s'", expectedText)

	// Verify that we can SSH to the Instance and run commands
	retry.DoWithRetry(t, description, MaxRetries, TimeBetweenRetries, func() (string, error) {
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
	description := "Access Kubernetes cluster"

	// Waiting for all the nodes' status is ready
	retry.DoWithRetry(t, description, MaxRetries, TimeBetweenRetries, func() (string, error) {
		nodesReady, err := k8s.AreAllNodesReadyE(t, kubectlOptions)
		if err != nil {
			return "", err
		}

		if !nodesReady {
			return "", fmt.Errorf("Cannot check all the Kubernetes nodes ready or not: %s", err)
		}
		return "", nil
	})

	// Check coreDNS is ready for serving request
	kubectlOptions.Namespace = "kube-system"
	coreDNSServiceName := "kube-dns"
	coreDNSReousrceName := "kube-dns"
	k8s.WaitUntilServiceAvailable(t, kubectlOptions, coreDNSServiceName, MaxRetries, TimeBetweenRetries)

	// Get pod and wait for it to be avaialable
	// To get the pod, we need to filter it using the labels that the helm chart creates
	filters := metav1.ListOptions{
		LabelSelector: fmt.Sprintf("k8s-app=%s", coreDNSReousrceName),
	}
	k8s.WaitUntilNumPodsCreated(t, kubectlOptions, filters, 2, MaxRetries, TimeBetweenRetries)
	pods := k8s.ListPods(t, kubectlOptions, filters)
	for _, pod := range pods {
		k8s.WaitUntilPodAvailable(t, kubectlOptions, pod.Name, MaxRetries, TimeBetweenRetries)
	}

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
	k8s.KubectlApplyFromString(t, kubectlOptions, nginxYAML)

	// This will wait up to 10 seconds for the service to become available, to ensure that we can access it.
	k8s.WaitUntilServiceAvailable(t, kubectlOptions, testServiceName, MaxRetries, TimeBetweenRetries)

	// Get pod and wait for it to be avaialable
	// To get the pod, we need to filter it using the labels that the helm chart creates
	filters = metav1.ListOptions{
		LabelSelector: fmt.Sprintf("app=%s", testResourceName),
	}
	k8s.WaitUntilNumPodsCreated(t, kubectlOptions, filters, 2, MaxRetries, TimeBetweenRetries)
	pods = k8s.ListPods(t, kubectlOptions, filters)
	for _, pod := range pods {
		k8s.WaitUntilPodAvailable(t, kubectlOptions, pod.Name, MaxRetries, TimeBetweenRetries)
	}

	// Now we verify that the service will successfully boot and start serving requests
	kubeTunnel := k8s.NewTunnel(kubectlOptions, k8s.ResourceTypeService, testServiceName, testServiceLocal, testServiceRemote)
	kubeTunnel.ForwardPort(t)
	defer kubeTunnel.Close()

	// Setup a TLS configuration to submit with the helper, a blank struct is acceptable
	tlsConfig := &tls.Config{}

	// Test the endpoint for up to 5 minutes. This will only fail if we timeout waiting for the service to return a 200
	// response.
	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		fmt.Sprintf("http://%s", kubeTunnel.Endpoint()),
		tlsConfig,
		MaxRetries,
		TimeBetweenRetries,
		func(statusCode int, body string) bool {
			return statusCode == 200
		},
	)
}
