# VARIABLES

K8S_Context="--context $1"
K8S_Namespace="-n $2"
K8S_Deployment="$3"
S=s

# FUNCTION

GetObjects(){

    echo ""
    ObjectTypePlural=$(echo "$ObjectType$S")
    OutputDeployObject=$(kubectl $K8S_Context $K8S_Namespace get deploy $K8S_Deployment -o=jsonpath=$JSONPathOutput)
    
    echo "#### $ObjectTypePlural in use ####"
    ObjectInUse=$(echo "$OutputDeployObject" | awk '{print $1}')
    echo $ObjectInUse

    echo ""

    echo "#### all $ObjectTypePlural  ####"
    ObjectName=$(echo $ObjectInUse | sed 's/...........$//')
    AllObjects=$(kubectl $K8S_Context $K8S_Namespace get $ObjectTypePlural | grep $ObjectName | awk '{print $1}')
    echo $AllObjects

    echo ""

    notUsedObjects=$(echo "$AllObjects" | sed "s/$ObjectInUse//")

    if [ -n "$notUsedObjects" ]; then

        echo "#### $ObjectTypePlural NOT in use ####"
        echo $notUsedObjects

        echo ""

        echo "#### Suggested command to execute and delete ####"
                echo "#kubectl $K8S_Context $K8S_Namespace delete $ObjectTypePlural \\"
        echo "$notUsedObjects" | sed ':a;N;$!ba;s/\n/ /g'

    else

        echo "Nothing to clean! ✨🧹 "

    fi

    echo ""
    echo "##################################################"
    echo ""
}

# EXECUTE

if ( kubectl get deploy $K8S_Context $K8S_Namespace $K8S_Deployment >> /dev/null ); then

    ObjectType=configmap
    JSONPathOutput='{.spec.template.spec.containers[*].envFrom[*].configMapRef.name}{"\n"}'
    GetObjects $K8S_Context $K8S_Namespace $K8S_Deployment $ObjectType

    ObjectType=secret
    JSONPathOutput='{.spec.template.spec.containers[*].envFrom[*].secretRef.name}{"\n"}'
    GetObjects $K8S_Context $K8S_Namespace $K8S_Deployment $ObjectType

else
    echo "" ; echo "Something went wrong, please check the parameters and the message below!"
fi
