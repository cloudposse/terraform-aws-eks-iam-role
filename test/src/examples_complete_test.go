package test

import (
	"math/rand"
	"strconv"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	rand.Seed(time.Now().UnixNano())

	randId := strconv.Itoa(rand.Intn(100000))
	attributes := []string{randId}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	autoscalerRoleName := terraform.Output(t, terraformOptions, "autoscaler_role")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "eg-ue2-test-eks-"+randId+"-autoscaler@kube-system", autoscalerRoleName)

	// Run `terraform output` to get the value of an output variable
	autoscalerPolicy := terraform.Output(t, terraformOptions, "autoscaler_policy")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, autoscalerPolicy, "AllowToScaleEKSNodeGroupAutoScalingGroup")

	// Run `terraform output` to get the value of an output variable
	certManagerRoleName := terraform.Output(t, terraformOptions, "cert-manager_role")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "eg-ue2-test-eks-"+randId+"-blue-cert-manager", certManagerRoleName)

	// Run `terraform output` to get the value of an output variable
	certManagerPolicy := terraform.Output(t, terraformOptions, "cert-manager_policy")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, certManagerPolicy, "GrantListHostedZonesListResourceRecordSets")

}
