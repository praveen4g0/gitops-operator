package argocd

import (
	"testing"

	"gotest.tools/assert"
	v1 "k8s.io/api/core/v1"
	resourcev1 "k8s.io/apimachinery/pkg/api/resource"
)

func TestArgoCD(t *testing.T) {
	testArgoCD, _ := NewCR("openshift-gitops", "openshift-gitops")

	testApplicationSetResources := &v1.ResourceRequirements{
		Requests: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("512Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("250m"),
		},
		Limits: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("1024Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("2000m"),
		},
	}
	assert.DeepEqual(t, testArgoCD.Spec.ApplicationSet.Resources, testApplicationSetResources)

	testControllerResources := &v1.ResourceRequirements{
		Requests: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("1024Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("250m"),
		},
		Limits: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("2048Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("2000m"),
		},
	}
	assert.DeepEqual(t, testArgoCD.Spec.Controller.Resources, testControllerResources)

	testDexResources := &v1.ResourceRequirements{
		Requests: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("128Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("250m"),
		},
		Limits: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("256Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("500m"),
		},
	}
	assert.DeepEqual(t, testArgoCD.Spec.Dex.Resources, testDexResources)

	testGrafanaResources := &v1.ResourceRequirements{
		Requests: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("128Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("250m"),
		},
		Limits: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("256Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("500m"),
		},
	}
	assert.DeepEqual(t, testArgoCD.Spec.Grafana.Resources, testGrafanaResources)

	testHAResources := &v1.ResourceRequirements{
		Requests: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("128Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("250m"),
		},
		Limits: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("256Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("500m"),
		},
	}
	assert.DeepEqual(t, testArgoCD.Spec.HA.Resources, testHAResources)
	assert.Equal(t, testArgoCD.Spec.HA.Enabled, false)

	testRedisResources := &v1.ResourceRequirements{
		Requests: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("128Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("250m"),
		},
		Limits: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("256Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("500m"),
		},
	}
	assert.DeepEqual(t, testArgoCD.Spec.Redis.Resources, testRedisResources)

	testRepoResources := &v1.ResourceRequirements{
		Requests: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("256Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("250m"),
		},
		Limits: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("1024Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("1000m"),
		},
	}
	assert.DeepEqual(t, testArgoCD.Spec.Repo.Resources, testRepoResources)

	testServerResources := &v1.ResourceRequirements{
		Requests: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("128Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("125m"),
		},
		Limits: v1.ResourceList{
			v1.ResourceMemory: resourcev1.MustParse("256Mi"),
			v1.ResourceCPU:    resourcev1.MustParse("500m"),
		},
	}
	assert.DeepEqual(t, testArgoCD.Spec.Server.Resources, testServerResources)
}