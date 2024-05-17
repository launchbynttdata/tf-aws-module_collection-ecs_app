package common

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ecs"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/require"
)

func TestDoesEcsAppExist(t *testing.T, ctx types.TestContext) {
	ecsClient := ecs.NewFromConfig(GetAWSConfig(t))
	ecsClusterName := terraform.Output(t, ctx.TerratestTerraformOptions(), "ecs_cluster_name")
	ecsClusterArn := terraform.Output(t, ctx.TerratestTerraformOptions(), "ecs_cluster_arn")

	t.Run("TestDoesClusterExist", func(t *testing.T) {
		output, err := ecsClient.DescribeClusters(context.TODO(), &ecs.DescribeClustersInput{Clusters: []string{ecsClusterArn}})
		if err != nil {
			t.Errorf("Error getting cluster description: %v", err)
		}

		require.Equal(t, 1, len(output.Clusters), "Expected 1 cluster to be returned")
		require.Equal(t, ecsClusterArn, *output.Clusters[0].ClusterArn, "Expected cluster ARN to match")
		require.Equal(t, ecsClusterName, *output.Clusters[0].ClusterName, "Expected cluster name to match")
	})
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}
