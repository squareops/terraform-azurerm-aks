## Roles Required

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
Permissions required are:

```json
{
  "createTlsPrivateKey": {
    "Microsoft.Authorization/roleAssignments/write": "Allow",
    "Microsoft.ManagedIdentity/userAssignedIdentities/write": "Allow"
  },
  "createUserAssignedIdentity": {
    "Microsoft.Authorization/roleAssignments/write": "Allow",
    "Microsoft.ManagedIdentity/userAssignedIdentities/write": "Allow"
  },
  "fetchSubscriptionInformation": {
    "Microsoft.Authorization/roleAssignments/read": "Allow",
    "Microsoft.Authorization/roleDefinitions/read": "Allow",
    "Microsoft.Authorization/roleAssignments/list": "Allow"
  },
  "assignRoleToPrincipal": {
    "Microsoft.Authorization/roleAssignments/write": "Allow",
    "Microsoft.Authorization/roleDefinitions/read": "Allow",
    "Microsoft.Authorization/roleAssignments/read": "Allow"
  },
  "vnet": {
    "Microsoft.Network/virtualNetworks/write": "Allow",
    "Microsoft.Network/virtualNetworks/subnets/write": "Allow",
    "Microsoft.Network/virtualNetworks/subnets/read": "Allow"
  },
  "routetable_public": {
    "Microsoft.Network/routeTables/write": "Allow",
    "Microsoft.Network/routeTables/read": "Allow"
  },
  "routetable_private": {
    "Microsoft.Network/routeTables/write": "Allow",
    "Microsoft.Network/routeTables/read": "Allow"
  },
  "routetable_database": {
    "Microsoft.Network/routeTables/write": "Allow",
    "Microsoft.Network/routeTables/read": "Allow"
  },
  "network_security_group": {
    "Microsoft.Network/networkSecurityGroups/write": "Allow",
    "Microsoft.Network/networkSecurityGroups/read": "Allow",
    "Microsoft.Network/networkSecurityGroups/securityRules/write": "Allow",
    "Microsoft.Network/networkSecurityGroups/securityRules/read": "Allow"
  },
  "nat_gateway": {
    "Microsoft.Network/publicIPAddresses/write": "Allow",
    "Microsoft.Network/publicIPAddresses/read": "Allow",
    "Microsoft.Network/publicIPAddresses/delete": "Allow",
    "Microsoft.Network/publicIPAddresses/move/action": "Allow",
    "Microsoft.Network/virtualNetworks/subnets/join/action": "Allow",
    "Microsoft.Network/virtualNetworks/subnets/read": "Allow",
    "Microsoft.Network/virtualNetworks/subnets/delete": "Allow",
    "Microsoft.Network/virtualNetworks/subnets/move/action": "Allow",
    "Microsoft.Network/natGateways/write": "Allow",
    "Microsoft.Network/natGateways/read": "Allow",
    "Microsoft.Network/natGateways/delete": "Allow",
    "Microsoft.Network/natGateways/move/action": "Allow"
  },
  "createAKSCluster": {
    "Microsoft.ContainerService/managedClusters/write": "Allow",
    "Microsoft.Network/virtualNetworks/subnets/join/action": "Allow",
    "Microsoft.Network/virtualNetworks/subnets/read": "Allow",
    "Microsoft.Network/networkSecurityGroups/read": "Allow",
    "Microsoft.Network/publicIPAddresses/read": "Allow",
    "Microsoft.Compute/disks/read": "Allow",
    "Microsoft.Compute/virtualMachines/read": "Allow",
    "Microsoft.Compute/images/read": "Allow",
    "Microsoft.Compute/availabilitySets/read": "Allow",
    "Microsoft.Compute/virtualMachines/extensions/read": "Allow",
    "Microsoft.Compute/virtualMachines/extensions/write": "Allow",
    "Microsoft.Storage/storageAccounts/read": "Allow",
    "Microsoft.Storage/storageAccounts/listKeys/action": "Allow",
    "Microsoft.Storage/storageAccounts/listAccountSas/action": "Allow",
    "Microsoft.Storage/storageAccounts/regenerateKey/action": "Allow",
    "Microsoft.Authorization/roleAssignments/read": "Allow",
    "Microsoft.Authorization/roleAssignments/write": "Allow",
    "Microsoft.ManagedIdentity/userAssignedIdentities/read": "Allow",
    "Microsoft.ManagedIdentity/userAssignedIdentities/write": "Allow"
  },
  "createKubernetesClusterNodePool": {
    "Microsoft.ContainerService/managedClusters/write": "Allow",
    "Microsoft.ContainerService/agentPoolProfiles/write": "Allow",
    "Microsoft.Network/virtualNetworks/subnets/join/action": "Allow",
    "Microsoft.Network/virtualNetworks/subnets/read": "Allow",
    "Microsoft.Network/networkSecurityGroups/read": "Allow",
    "Microsoft.Network/publicIPAddresses/read": "Allow",
    "Microsoft.Compute/disks/read": "Allow",
    "Microsoft.Compute/virtualMachines/read": "Allow",
    "Microsoft.Compute/virtualMachines/write": "Allow",
    "Microsoft.Compute/virtualMachines/extensions/read": "Allow",
    "Microsoft.Compute/virtualMachines/extensions/write": "Allow",
    "Microsoft.Compute/virtualMachineScaleSets/read": "Allow",
    "Microsoft.Compute/virtualMachineScaleSets/write": "Allow",
    "Microsoft.Compute/availabilitySets/read": "Allow",
    "Microsoft.Storage/storageAccounts/read": "Allow",
    "Microsoft.Storage/storageAccounts/listKeys/action": "Allow",
    "Microsoft.Storage/storageAccounts/listAccountSas/action": "Allow",
    "Microsoft.Storage/storageAccounts/regenerateKey/action": "Allow",
    "Microsoft.Authorization/roleAssignments/read": "Allow",
    "Microsoft.Authorization/roleAssignments/write": "Allow",
    "Microsoft.ManagedIdentity/userAssignedIdentities/read": "Allow",
    "Microsoft.ManagedIdentity/userAssignedIdentities/write": "Allow"
  }
}
```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->