const et = require('elementtree');
const path = require('path');
const fs = require('fs');

module.exports = function (context) {

    const ServiceEnum = Object.freeze({"ApplePay":"1", "GooglePay":"2"})
    const configFileName = 'json-config/PaymentsPluginConfiguration.json';
    let projectRoot = context.opts.cordova.project ? context.opts.cordova.project.root : context.opts.projectRoot;

    let hasGooglePay = false;

    let merchant_name = "";
    let merchant_country_code = "";
    let payment_allowed_networks = [];
    let payment_supported_capabilities = [];
    let payment_supported_card_countries = [];
    let shipping_supported_contacts = [];
    let shipping_country_codes = [];
    let billing_supported_contacts = [];
    let gateway = "";
    let backend_url = "";
    //only for PSPs other than Stripe
    let gateway_merchant_id = "";
    //only for stripe
    let stripe_version = "";
    let stripe_pub_key = "";

    let wwwFolder = "www";
    let platformPath = path.join(projectRoot, `platforms/android/www`);
          
    if(!fs.existsSync(platformPath)){
        platformPath = path.join(projectRoot, wwwFolder);
    }

    let jsonConfig = "";
    let jsonParsed;
    try {
        jsonConfig = path.join(platformPath, configFileName);
        let jsonConfigFile = fs.readFileSync(jsonConfig).toString();
        jsonParsed = JSON.parse(jsonConfigFile);
    }
    catch {
        throw new Error("OUTSYSTEMS_PLUGIN_ERROR: Missing configuration file or error trying to obtain the configuration.");
    }

    jsonParsed.app_configurations.forEach((configItem) => {
        if (configItem.service_id == ServiceEnum.GooglePay) {
            hasGooglePay = true;
            let error_list = [];

            if(configItem.merchant_name && configItem.merchant_name !== ""){
                merchant_name = configItem.merchant_name;
            }
            else{
                error_list.push('Merchant Name');
            }

            if(configItem.merchant_country_code && configItem.merchant_country_code !== ""){
                merchant_country_code = configItem.merchant_country_code;
            }
            else{
                error_list.push('Merchant Country');
            }

            if(configItem.payment_allowed_networks && configItem.payment_allowed_networks.length > 0){
                payment_allowed_networks = configItem.payment_allowed_networks;
            }
            else{
                error_list.push('Payment Allowed Networks');
            }

            if(configItem.payment_supported_capabilities && configItem.payment_supported_capabilities.length > 0){
                payment_supported_capabilities = configItem.payment_supported_capabilities;
            }
            else{
                error_list.push('Payment Supported Capabilities');
            }

            if(configItem.payment_supported_card_countries && configItem.payment_supported_card_countries.length > 0){
                payment_supported_card_countries = configItem.payment_supported_card_countries;
            }

            if(configItem.shipping_supported_contacts && configItem.shipping_supported_contacts.length > 0){
                shipping_supported_contacts = configItem.shipping_supported_contacts;
            }

            if(configItem.shipping_country_codes && configItem.shipping_country_codes.length > 0){
                shipping_country_codes = configItem.shipping_country_codes;
            }

            if(configItem.billing_supported_contacts && configItem.billing_supported_contacts.length > 0){
                billing_supported_contacts = configItem.billing_supported_contacts;
            }

            if(configItem.tokenization){
                gateway = configItem.tokenization.gateway;
                backend_url = configItem.tokenization.requestURL;
                if(gateway.toUpperCase() == "STRIPE"){
                    stripe_version = configItem.tokenization.stripeVersion;
                    stripe_pub_key = configItem.tokenization.stripePublishableKey;
                }
                else{
                    gateway_merchant_id = configItem.tokenization.gatewayMerchantId;
                }
            }
            else{
                error_list.push('PSP information');
            }

            if (error_list.length > 0) {
                console.error("Missing fields: " + error_list);
                throw new Error("OUTSYSTEMS_PLUGIN_ERROR: Payments configuration is missing some fields. Please check build logs to know more.");
            }
        }
    });

    if(hasGooglePay){
        let stringsXmlPath = path.join(projectRoot, 'platforms/android/app/src/main/res/values/strings.xml');
        let stringsXmlContents = fs.readFileSync(stringsXmlPath).toString();
        let etreeStrings = et.parse(stringsXmlContents);
        const resources = etreeStrings.getroot();

        upsertStringEntry(resources, 'merchant_name', merchant_name);
        upsertStringEntry(resources, 'merchant_country_code', merchant_country_code);
        upsertStringEntry(resources, 'payment_allowed_networks', payment_allowed_networks);
        upsertStringEntry(resources, 'payment_supported_capabilities', payment_supported_capabilities);
        upsertStringEntry(resources, 'payment_supported_card_countries', payment_supported_card_countries);
        upsertStringEntry(resources, 'shipping_supported_contacts', shipping_supported_contacts);
        upsertStringEntry(resources, 'shipping_country_codes', shipping_country_codes);
        upsertStringEntry(resources, 'billing_supported_contacts', billing_supported_contacts);
        upsertStringEntry(resources, 'gateway', gateway);
        upsertStringEntry(resources, 'backend_url', backend_url);
        upsertStringEntry(resources, 'gateway_merchant_id', gateway_merchant_id);
        upsertStringEntry(resources, 'stripe_version', stripe_version);
        upsertStringEntry(resources, 'stripe_pub_key', stripe_pub_key);
    
        let resultXmlStrings = etreeStrings.write();
        fs.writeFileSync(stringsXmlPath, resultXmlStrings);
    }

    function upsertStringEntry(resourcesNode, key, value) {
        const matches = resourcesNode.findall(`./string[@name="${key}"]`);
        if (matches.length > 0) {
            // Update the first match
            matches[0].text = value;

            // Remove any duplicates
            for (let i = 1; i < matches.length; i++) {
                resourcesNode.remove(matches[i]);
            }
        } else {
            // Create new element
            const newElement = new et.Element('string');
            newElement.set('name', key);
            newElement.text = value;
            resourcesNode.append(newElement);
        }
    }

};