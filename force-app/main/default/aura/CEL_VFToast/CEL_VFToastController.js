({
    doInit : function(component, event, helper) {
        console.log('Oops , i m still in doInit ');
        var toast = component.get("v.toastType"); 
        console.log(toast);
        if(toast == 'error'){
           component.set("v.toastcss",'slds-notify slds-notify_toast slds-theme_error');
        }
        else if(toast == 'success'){
            component.set("v.toastcss",'slds-notify slds-notify_toast slds-theme_success');
        }
        else if(toast == 'warning'){
            component.set("v.toastcss",'slds-notify slds-notify_toast slds-theme_warning');
        }
        if(document.getElementById("toastCmp"))
            document.getElementById("toastCmp").style.display = component.get("v.toastcss");
    },
    
    closeIcon : function(component, event, helper) {
        console.log('Oops , i m still alive :O ');
        if(document.getElementById("toastCmp"))
            document.getElementById("toastCmp").style.display = "none";
    }
})