resource_groups=(
  "MC_tf_aks_acr_rg_aks-gen1-cluster_northeurope"
  "terraformstorage"
  "tf_aks_acr_rg"
  
)

for resource_group in "${resource_groups[@]}"
do
  echo "Deleting Resource Group: $resource_group"
  az group delete --name $resource_group --yes
done