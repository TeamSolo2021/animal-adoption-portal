param resourceLocation string = 'southeastasia'
param tenantGuid string
param appServicePlanName string
param keyVaultName string
param webAppName string
param resourceGroupServicePrincipalManagedApplicationObjectId string

var keyVaultSecretNameSimulatedFailureChance = 'SimulatedFailureChance'
var keyVaultSecretNameGlobalPassword = 'GlobalPassword'

resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  location: resourceLocation
  name: 'containeracrunique'
  sku: {
    name: 'Basic'
  }
}

resource ai_resource 'Microsoft.Insights/components@2020-02-02' = {
  name: '${webAppName}-ai'
  location: resourceLocation
  kind: 'web'
  properties: {
    RetentionInDays: 30
    SamplingPercentage: 100
    Application_Type: 'web'
  }
}

resource keyVaultName_resource 'Microsoft.KeyVault/vaults@2018-02-14' = {
  name: keyVaultName
  location: resourceLocation
  tags: {}
  properties: {
    enabledForDeployment: false
    enabledForTemplateDeployment: false
    enabledForDiskEncryption: false
    enableRbacAuthorization: false
    accessPolicies: [
      {
        tenantId: tenantGuid
        objectId: resourceGroupServicePrincipalManagedApplicationObjectId
        permissions: {
          keys: []
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          certificates: []
        }
      }
      {
        objectId: 'ad8197ec-29a0-4087-bfb3-fe0a52b383dc'
        tenantId: tenantGuid
        permissions: {
          keys: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          certificates: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
            'managecontacts'
            'manageissuers'
            'getissuers'
            'listissuers'
            'setissuers'
            'deleteissuers'
          ]
        }
      }
    ]
    tenantId: tenantGuid
    sku: {
      name: 'standard'
      family: 'A'
    }
    enableSoftDelete: true
    softDeleteRetentionInDays: '90'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
      ipRules: []
      virtualNetworkRules: []
    }
  }
  dependsOn: []
}

resource appServicePlanName_resource 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: appServicePlanName
  location: resourceLocation
  sku: {
    Tier: 'Standard'
    Name: 'S1'
  }
  kind: 'linux'
  properties: {
    name: appServicePlanName
    workerSize: '0'
    workerSizeId: '0'
    numberOfWorkers: '1'
    reserved: true
  }
  dependsOn: []
}

resource webAppName_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: webAppName
  location: resourceLocation
  kind: 'app,linux'
  properties: {
    name: webAppName
    siteConfig: {
      appSettings: []
      linuxFxVersion: 'DOTNETCORE|3.1'
      alwaysOn: true
    }
    serverFarmId: appServicePlanName_resource.id
    clientAffinityEnabled: false
  }
}
