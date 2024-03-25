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

        let merchantNameTags = etreeStrings.findall('./string[@name="merchant_name"]');
        for (let i = 0; i < merchantNameTags.length; i++) {
            merchantNameTags[i].text = merchant_name;
        }

        let merchantCountryTags = etreeStrings.findall('./string[@name="merchant_country_code"]');
        for (let i = 0; i < merchantCountryTags.length; i++) {
            merchantCountryTags[i].text = merchant_country_code;
        }

        let allowedNetworksTags = etreeStrings.findall('./string[@name="payment_allowed_networks"]');
        for (let i = 0; i < allowedNetworksTags.length; i++) {
            allowedNetworksTags[i].text = payment_allowed_networks;
        }

        let supportedCapabilitiesTags = etreeStrings.findall('./string[@name="payment_supported_capabilities"]');
        for (let i = 0; i < supportedCapabilitiesTags.length; i++) {
            supportedCapabilitiesTags[i].text = payment_supported_capabilities;
        }

        let supportedCardCountriesTags = etreeStrings.findall('./string[@name="payment_supported_card_countries"]');
        for (let i = 0; i < supportedCardCountriesTags.length; i++) {
            supportedCardCountriesTags[i].text = payment_supported_card_countries;
        }

        let shippingContactsTags = etreeStrings.findall('./string[@name="shipping_supported_contacts"]');
        for (let i = 0; i < shippingContactsTags.length; i++) {
            shippingContactsTags[i].text = shipping_supported_contacts;
        }

        let shippingCountriesTags = etreeStrings.findall('./string[@name="shipping_country_codes"]');
        for (let i = 0; i < shippingCountriesTags.length; i++) {
            shippingCountriesTags[i].text = shipping_country_codes;
        }

        let billingContactsTags = etreeStrings.findall('./string[@name="billing_supported_contacts"]');
        for (let i = 0; i < billingContactsTags.length; i++) {
            billingContactsTags[i].text = billing_supported_contacts;
        }

        let gatewayTags = etreeStrings.findall('./string[@name="gateway"]');
        for (let i = 0; i < gatewayTags.length; i++) {
            gatewayTags[i].text = gateway;
        }

        let backendUrlTags = etreeStrings.findall('./string[@name="backend_url"]');
        for (let i = 0; i < backendUrlTags.length; i++) {
            backendUrlTags[i].text = backend_url;
        }

        let gatewayMerchantIdTags = etreeStrings.findall('./string[@name="gateway_merchant_id"]');
        for (let i = 0; i < gatewayMerchantIdTags.length; i++) {
            gatewayMerchantIdTags[i].text = gateway_merchant_id;
        }

        let stripeVersionTags = etreeStrings.findall('./string[@name="stripe_version"]');
        for (let i = 0; i < stripeVersionTags.length; i++) {
            stripeVersionTags[i].text = stripe_version;
        }

        let stripePubKeyTags = etreeStrings.findall('./string[@name="stripe_pub_key"]');
        for (let i = 0; i < stripePubKeyTags.length; i++) {
            stripePubKeyTags[i].text = stripe_pub_key;
        }
    
        let resultXmlStrings = etreeStrings.write();
        fs.writeFileSync(stringsXmlPath, resultXmlStrings);
    }

};